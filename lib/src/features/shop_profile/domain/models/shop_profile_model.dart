import 'package:flutter/foundation.dart';

/// Domain class representing operating schedule for a single day of the week.
@immutable
class DayOperatingSchedule {
  const DayOperatingSchedule({
    required this.day,
    required this.isOpen,
    this.openTime = '10:00 AM',
    this.closeTime = '08:30 PM',
  });

  final String day;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  DayOperatingSchedule copyWith({
    String? day,
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return DayOperatingSchedule(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory DayOperatingSchedule.fromMap(Map<String, dynamic> map, String defaultDay) {
    return DayOperatingSchedule(
      day: map['day'] as String? ?? defaultDay,
      isOpen: map['isOpen'] as bool? ?? true,
      openTime: map['openTime'] as String? ?? '10:00 AM',
      closeTime: map['closeTime'] as String? ?? '08:30 PM',
    );
  }
}

/// Domain class representing structured weekly operating hours per day.
@immutable
class OperatingHoursModel {
  const OperatingHoursModel({
    required this.dailySchedules,
  });

  /// Map of day name to individual DayOperatingSchedule
  final Map<String, DayOperatingSchedule> dailySchedules;

  static const List<String> allWeekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const OperatingHoursModel defaultSchedule = OperatingHoursModel(
    dailySchedules: {
      'Monday': DayOperatingSchedule(day: 'Monday', isOpen: true),
      'Tuesday': DayOperatingSchedule(day: 'Tuesday', isOpen: true),
      'Wednesday': DayOperatingSchedule(day: 'Wednesday', isOpen: true),
      'Thursday': DayOperatingSchedule(day: 'Thursday', isOpen: true),
      'Friday': DayOperatingSchedule(day: 'Friday', isOpen: true),
      'Saturday': DayOperatingSchedule(day: 'Saturday', isOpen: true),
      'Sunday': DayOperatingSchedule(day: 'Sunday', isOpen: false),
    },
  );

  /// Helper to generate a human-readable summary.
  String get summary {
    final openDays = dailySchedules.entries.where((e) => e.value.isOpen).toList();
    if (openDays.isEmpty) return 'Closed All Days';

    final monSatOpen = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        .every((d) => dailySchedules[d]?.isOpen == true);
    final sunOpen = dailySchedules['Sunday']?.isOpen == true;

    final firstOpen = openDays.first.value;
    if (monSatOpen && !sunOpen) {
      return 'Mon - Sat: ${firstOpen.openTime} - ${firstOpen.closeTime} (Sun Closed)';
    } else if (monSatOpen && sunOpen) {
      return 'Mon - Sun: ${firstOpen.openTime} - ${firstOpen.closeTime} (All Days Open)';
    }

    return '${openDays.length} Days Open (Tap for Timings)';
  }

  /// Calculates whether the studio is currently OPEN or CLOSED right now.
  bool isCurrentlyOpen([DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDay = dayNames[now.weekday - 1];

    final schedule = dailySchedules[currentDay];
    if (schedule == null || !schedule.isOpen) return false;

    final openMinutes = _parseTimeToMinutes(schedule.openTime);
    final closeMinutes = _parseTimeToMinutes(schedule.closeTime);
    final currentMinutes = now.hour * 60 + now.minute;

    if (openMinutes == null || closeMinutes == null) return true;

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  int? _parseTimeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final isAm = clean.endsWith('AM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      if (parts.isEmpty) return null;

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'dailySchedules': dailySchedules.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory OperatingHoursModel.fromMap(Map<String, dynamic> map) {
    if (map['dailySchedules'] != null && map['dailySchedules'] is Map) {
      final rawMap = Map<String, dynamic>.from(map['dailySchedules'] as Map);
      final schedules = <String, DayOperatingSchedule>{};
      for (final day in allWeekDays) {
        if (rawMap[day] != null && rawMap[day] is Map) {
          schedules[day] = DayOperatingSchedule.fromMap(
            Map<String, dynamic>.from(rawMap[day] as Map),
            day,
          );
        } else {
          schedules[day] = DayOperatingSchedule(
            day: day,
            isOpen: day != 'Sunday',
          );
        }
      }
      return OperatingHoursModel(dailySchedules: schedules);
    }

    // Fallback if legacy map structure
    final openTime = map['openTime'] as String? ?? '10:00 AM';
    final closeTime = map['closeTime'] as String? ?? '08:30 PM';
    final openDaysList = (map['openDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    final schedules = <String, DayOperatingSchedule>{};
    for (final day in allWeekDays) {
      final isOpen = openDaysList.contains(day);
      schedules[day] = DayOperatingSchedule(
        day: day,
        isOpen: isOpen,
        openTime: openTime,
        closeTime: closeTime,
      );
    }
    return OperatingHoursModel(dailySchedules: schedules);
  }

  OperatingHoursModel copyWith({
    Map<String, DayOperatingSchedule>? dailySchedules,
  }) {
    return OperatingHoursModel(
      dailySchedules: dailySchedules ?? this.dailySchedules,
    );
  }
}

/// Singleton domain model representing Kapada Creation shop profile.
@immutable
class ShopProfileModel {
  const ShopProfileModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.phone,
    this.email,
    this.address,
    this.openingHours,
    this.operatingHours,
    this.logoUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? phone;
  final String? email;
  final String? address;
  final String? openingHours;
  final OperatingHoursModel? operatingHours;
  final String? logoUrl;
  final bool isActive;

  static const String defaultId = 'boutique_01';

  static const ShopProfileModel defaultProfile = ShopProfileModel(
    id: defaultId,
    name: 'Kapada Creation',
    subtitle: 'Luxury Bespoke Designer Apparel & Custom Tailoring',
    phone: '+91 98765 43210',
    email: 'contact@kapadacreation.com',
    address: 'Main Market, M.G. Road, Jaipur, Rajasthan 302001',
    openingHours: 'Mon - Sat: 10:00 AM - 8:30 PM',
    operatingHours: OperatingHoursModel.defaultSchedule,
    logoUrl: null,
    isActive: true,
  );

  ShopProfileModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? phone,
    String? email,
    String? address,
    String? openingHours,
    OperatingHoursModel? operatingHours,
    String? logoUrl,
    bool? isActive,
  }) {
    return ShopProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      operatingHours: operatingHours ?? this.operatingHours,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (openingHours != null) 'openingHours': openingHours,
      if (operatingHours != null) 'operatingHours': operatingHours!.toMap(),
      if (logoUrl != null) 'logoUrl': logoUrl,
      'isActive': isActive,
    };
  }

  factory ShopProfileModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    OperatingHoursModel? opHours;
    if (map['operatingHours'] != null && map['operatingHours'] is Map) {
      opHours = OperatingHoursModel.fromMap(
        Map<String, dynamic>.from(map['operatingHours'] as Map),
      );
    } else {
      opHours = OperatingHoursModel.defaultSchedule;
    }

    return ShopProfileModel(
      id: map['id'] as String? ?? docId ?? defaultId,
      name: map['name'] as String? ?? 'Kapada Creation',
      subtitle: map['subtitle'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      openingHours: map['openingHours'] as String? ?? opHours.summary,
      operatingHours: opHours,
      logoUrl: map['logoUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShopProfileModel &&
        other.id == id &&
        other.name == name &&
        other.subtitle == subtitle &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.openingHours == openingHours &&
        other.operatingHours == operatingHours &&
        other.logoUrl == logoUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      subtitle,
      phone,
      email,
      address,
      openingHours,
      operatingHours,
      logoUrl,
      isActive,
    );
  }
}

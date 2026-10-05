import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/features/shop_profile/domain/models/shop_profile_model.dart';
import 'package:kc_admin/src/features/shop_profile/presentation/widgets/store_info_card.dart';

void main() {
  group('StoreInfoCard Tests', () {
    testWidgets(
      'renders location icon, phone icon, and SINCE with white color',
      (tester) async {
        const testProfile = ShopProfileModel(
          id: 'boutique_01',
          name: 'Kapada Creation',
          subtitle: 'Luxury Designer Apparel',
          phone: '+91 99999 88888',
          address: 'MG Road, Jaipur',
          establishedYear: '2020',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: StoreInfoCard(shopProfile: testProfile)),
          ),
        );
        await tester.pump();

        // Find Location icon and check color
        final locationIconFinder = find.byIcon(Icons.location_on_outlined);
        expect(locationIconFinder, findsOneWidget);
        final locationIcon = tester.widget<Icon>(locationIconFinder);
        expect(locationIcon.color, equals(Colors.white));

        // Find Phone icon and check color
        final phoneIconFinder = find.byIcon(Icons.phone_outlined);
        expect(phoneIconFinder, findsOneWidget);
        final phoneIcon = tester.widget<Icon>(phoneIconFinder);
        expect(phoneIcon.color, equals(Colors.white));

        // Find SINCE text and check color
        final sinceTextFinder = find.text('SINCE 2020');
        expect(sinceTextFinder, findsOneWidget);
        final sinceText = tester.widget<Text>(sinceTextFinder);
        expect(sinceText.style?.color, equals(Colors.white));
      },
    );

    testWidgets('displays dynamic current day hours based on operatingHours', (
      tester,
    ) async {
      final now = DateTime.now();
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final todayName = dayNames[now.weekday - 1];

      // Custom schedule with unique timing for today
      final customSchedules = <String, DayOperatingSchedule>{};
      for (final day in OperatingHoursModel.allWeekDays) {
        if (day == todayName) {
          customSchedules[day] = DayOperatingSchedule(
            day: day,
            isOpen: true,
            openTime: '11:15 AM',
            closeTime: '07:45 PM',
          );
        } else {
          customSchedules[day] = DayOperatingSchedule(day: day, isOpen: false);
        }
      }

      final profileWithCustomToday = ShopProfileModel(
        id: 'boutique_01',
        name: 'Kapada Creation',
        subtitle: 'Luxury Designer Apparel',
        operatingHours: OperatingHoursModel(dailySchedules: customSchedules),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoreInfoCard(shopProfile: profileWithCustomToday),
          ),
        ),
      );
      await tester.pump();

      // Check that the current day's timing is displayed
      expect(find.text('11:15 AM to 07:45 PM'), findsOneWidget);
    });

    testWidgets('displays Closed Today when today is marked closed', (
      tester,
    ) async {
      final now = DateTime.now();
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final todayName = dayNames[now.weekday - 1];

      final customSchedules = <String, DayOperatingSchedule>{};
      for (final day in OperatingHoursModel.allWeekDays) {
        customSchedules[day] = DayOperatingSchedule(
          day: day,
          isOpen: day != todayName,
          openTime: '10:00 AM',
          closeTime: '08:30 PM',
        );
      }

      final profileClosedToday = ShopProfileModel(
        id: 'boutique_01',
        name: 'Kapada Creation',
        subtitle: 'Luxury Designer Apparel',
        operatingHours: OperatingHoursModel(dailySchedules: customSchedules),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StoreInfoCard(shopProfile: profileClosedToday)),
        ),
      );
      await tester.pump();

      expect(find.text('Closed Today'), findsOneWidget);
    });
  });
}

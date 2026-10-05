import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../domain/models/shop_profile_model.dart';

enum StudioOpenStatus { open, closingSoon, closed }

/// Ultra-Luxury High-End Organic Green Leather Card representing Store Info in KC-Admin.
/// Parity with Customer App StoreInfoCard.
class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({super.key, this.shopProfile});

  final ShopProfileModel? shopProfile;

  ({StudioOpenStatus status, String displayHours}) _getTodayTimingAndStatus(
    ShopProfileModel? shopProfile,
  ) {
    final opHours =
        shopProfile?.operatingHours ?? OperatingHoursModel.defaultSchedule;
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

    final todaySched = opHours.dailySchedules[todayName];

    if (todaySched == null || !todaySched.isOpen) {
      return (status: StudioOpenStatus.closed, displayHours: 'Closed Today');
    }

    final openMin =
        OperatingHoursModel.parseTimeToMinutes(todaySched.openTime) ??
        (10 * 60);
    final closeMin =
        OperatingHoursModel.parseTimeToMinutes(todaySched.closeTime) ??
        (20 * 60 + 30);
    final currentMinutes = now.hour * 60 + now.minute;

    StudioOpenStatus status;
    if (currentMinutes < openMin || currentMinutes >= closeMin) {
      status = StudioOpenStatus.closed;
    } else if (closeMin - currentMinutes <= 60) {
      status = StudioOpenStatus.closingSoon;
    } else {
      status = StudioOpenStatus.open;
    }

    return (
      status: status,
      displayHours: '${todaySched.openTime} to ${todaySched.closeTime}',
    );
  }

  Widget _buildStoreLogoImage(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      if (logoUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: const Color(0xFFFAF6EF),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF162D20),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallbackLogo(),
        );
      } else if (logoUrl.startsWith('assets/')) {
        return Image.asset(
          logoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
        );
      }
    }
    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Text(
        'KC',
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF162D20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = shopProfile?.name ?? 'Kapada Creation';
    final subtitle =
        (shopProfile?.subtitle != null && shopProfile!.subtitle.isNotEmpty)
        ? shopProfile!.subtitle
        : 'Luxury Designer Apparel & Custom Tailoring';
    final address =
        (shopProfile?.address != null && shopProfile!.address!.isNotEmpty)
        ? shopProfile!.address!
        : 'Main Market, M.G. Road, Jaipur';
    final establishedYear =
        (shopProfile?.establishedYear != null &&
            shopProfile!.establishedYear!.isNotEmpty)
        ? shopProfile!.establishedYear!
        : '2022';
    final phone = (shopProfile?.phone != null && shopProfile!.phone!.isNotEmpty)
        ? shopProfile!.phone!
        : '+91 98765 43210';
    final logoUrl = shopProfile?.logoUrl;

    final timingInfo = _getTodayTimingAndStatus(shopProfile);
    final status = timingInfo.status;
    final statusText = timingInfo.displayHours;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF244633), // Specular emerald sheen
                Color(0xFF162D20), // Executive forest green base
                Color(0xFF0D1C13), // Rich leather shadow depth
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF0F1E15).withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomPaint(
              painter: _LeatherGrainTexturePainter(),
              foregroundPainter: _LeatherTopstitchPainter(
                borderRadius: 22,
                stitchColor: AppColors.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── LEFT COLUMN: Dynamic Image Box + Since Badge Below ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Portrait Studio Logo Image Box
                        Container(
                          width: 72,
                          height: 86,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildStoreLogoImage(logoUrl),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 2. Since Tag (Underneath Image Box)
                        Container(
                          width: 72,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'SINCE $establishedYear',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // ── RIGHT COLUMN: Name, Subtitle, Address, Phone, Opening Hours ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Name Row
                          Padding(
                            padding: const EdgeInsets.only(right: 36),
                            child: Text(
                              name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // 2. Subtitle
                          Text(
                            subtitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // 3. Address Row
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  address,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // 4. Phone Number Row
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  phone,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 5. Opening Hours Row with Breathing Indicator & Arrow Button
                          GestureDetector(
                            onTap: () => _showStoreHoursBottomSheet(
                              context,
                              shopProfile,
                              status,
                              statusText,
                            ),
                            child: DashedStitchContainer(
                              borderColor: AppColors.primary,
                              backgroundColor: const Color(0xFFFAF6EF),
                              borderRadius: 10,
                              inset: 2.5,
                              dashWidth: 5.0,
                              dashGap: 3.0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  // Breathing Status Indicator Dot
                                  _BreathingStatusDot(status: status),

                                  const SizedBox(width: 7),

                                  // Opening Hours Timing Text
                                  Expanded(
                                    child: Text(
                                      statusText,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF162D20),
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(width: 4),

                                  // Right Arrow Button
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF162D20),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── LEFT SIDE WHITE FABRIC ACCENT TAG ──
        const Positioned(left: -4, top: 32, child: _LeftFabricTabTag()),

        // ── RIGHT SIDE UPPER CORNER TASSEL CHARM (Rotated -10°) ──
        const Positioned(right: 5, top: 10, child: _TasselCharmWidget()),
      ],
    );
  }
}

/// Right Side Upper Corner Tassel Charm Widget (Rotated -10°)
class _TasselCharmWidget extends StatelessWidget {
  const _TasselCharmWidget();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -10 * math.pi / 180,
      child: SizedBox(
        width: 34,
        height: 48,
        child: SvgPicture.asset(
          'assets/images/tassel_charm.svg',
          width: 34,
          height: 48,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const _TasselCharmFallback(),
        ),
      ),
    );
  }
}

/// High-Precision Custom Vector Fallback for Tassel Charm
class _TasselCharmFallback extends StatelessWidget {
  const _TasselCharmFallback();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(34, 48),
      painter: _TasselCharmPainter(),
    );
  }
}

class _TasselCharmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final goldRingPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final innerGoldFill = Paint()
      ..color = const Color(0xFFF3DEAE)
      ..style = PaintingStyle.fill;

    final dotFill = Paint()
      ..color = const Color(0xFF8F6932)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, 10), 8, innerGoldFill);
    canvas.drawCircle(Offset(cx, 10), 8, goldRingPaint);
    canvas.drawCircle(Offset(cx, 10), 2.5, dotFill);

    canvas.drawLine(
      Offset(cx, 18),
      Offset(cx, 22),
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.0,
    );

    final ivoryPaint = Paint()
      ..color = const Color(0xFFFAF6EF)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFD8C1A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(Offset(cx, 26), 5.5, ivoryPaint);
    canvas.drawCircle(Offset(cx, 26), 5.5, borderPaint);

    final skirtPath = Path()
      ..moveTo(cx - 5, 30)
      ..quadraticBezierTo(cx - 11, 38, cx - 11, 46)
      ..quadraticBezierTo(cx, 48, cx + 11, 46)
      ..quadraticBezierTo(cx + 11, 38, cx + 5, 30)
      ..close();

    canvas.drawPath(skirtPath, ivoryPaint);
    canvas.drawPath(skirtPath, borderPaint);

    final threadPaint = Paint()
      ..color = const Color(0xFFC9AC83)
      ..strokeWidth = 1.0;

    for (double dx = -7; dx <= 7; dx += 2.8) {
      canvas.drawLine(
        Offset(cx + dx, 32),
        Offset(cx + dx * 0.9, 45),
        threadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Luxury Animated Breathing Status Dot
class _BreathingStatusDot extends StatefulWidget {
  const _BreathingStatusDot({required this.status});

  final StudioOpenStatus status;

  @override
  State<_BreathingStatusDot> createState() => _BreathingStatusDotState();
}

class _BreathingStatusDotState extends State<_BreathingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.status) {
      StudioOpenStatus.open => const Color(0xFF2E7D32),
      StudioOpenStatus.closingSoon => const Color(0xFFE65100),
      StudioOpenStatus.closed => const Color(0xFFC62828),
    };

    if (widget.status == StudioOpenStatus.closed) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final glowScale = 1.0 + (_animation.value * 0.65);
        final glowAlpha = 0.45 * (1.0 - _animation.value * 0.4);

        return SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: glowAlpha),
                  ),
                ),
              ),
              Container(
                width: 7.5,
                height: 7.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 3,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Left Side White Fabric Accent Tab Tag Detail
class _LeftFabricTabTag extends StatelessWidget {
  const _LeftFabricTabTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: const Color(0xFFC5A880).withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(-2, 1),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet displaying weekly Operating Hours in KC-Admin
void _showStoreHoursBottomSheet(
  BuildContext context,
  ShopProfileModel? shopProfile,
  StudioOpenStatus status,
  String liveDisplayHours,
) {
  final now = DateTime.now();

  final badgeColor = switch (status) {
    StudioOpenStatus.open => const Color(0xFF2E7D32),
    StudioOpenStatus.closingSoon => const Color(0xFFE65100),
    StudioOpenStatus.closed => const Color(0xFFC62828),
  };

  final badgeBgColor = switch (status) {
    StudioOpenStatus.open => const Color(0xFFE8F5E9),
    StudioOpenStatus.closingSoon => const Color(0xFFFFF3E0),
    StudioOpenStatus.closed => const Color(0xFFFFEBEE),
  };

  final badgeLabel = switch (status) {
    StudioOpenStatus.open => 'OPEN NOW',
    StudioOpenStatus.closingSoon => 'CLOSING SOON',
    StudioOpenStatus.closed => 'SHOP CLOSED',
  };

  final opHours =
      shopProfile?.operatingHours ?? OperatingHoursModel.defaultSchedule;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFAF7F2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCD4C8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162D20).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_filled_rounded,
                    color: Color(0xFF162D20),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studio Operating Hours',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF162D20),
                        ),
                      ),
                      Text(
                        '${shopProfile?.name ?? 'Kapada Creation'}  •  $liveDisplayHours',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BreathingStatusDot(status: status),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 4,
              child: CustomPaint(
                painter: StitchLinePainter(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  minThickness: 0.8,
                  maxThickness: 1.8,
                  dashWidth: 6.0,
                  dashGap: 3.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ...OperatingHoursModel.allWeekDays.map((dayName) {
              final sched =
                  opHours.dailySchedules[dayName] ??
                  DayOperatingSchedule(
                    day: dayName,
                    isOpen: dayName != 'Sunday',
                  );
              final dayIndex =
                  OperatingHoursModel.allWeekDays.indexOf(dayName) + 1;
              final isToday = now.weekday == dayIndex;

              final timeStr = sched.isOpen
                  ? '${sched.openTime} to ${sched.closeTime}'
                  : 'Closed';

              return _buildDayScheduleRow(
                dayName,
                timeStr,
                isToday,
                isClosed: !sched.isOpen,
              );
            }),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDFD6C7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF162D20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Designer consultations and stitching fittings available during studio hours.',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162D20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDayScheduleRow(
  String day,
  String timeRange,
  bool isToday, {
  bool isClosed = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: isToday
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isToday ? AppColors.primary : const Color(0xFFEBE4D8),
        width: isToday ? 1.2 : 0.8,
      ),
    ),
    child: Row(
      children: [
        Text(
          day,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF162D20),
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'TODAY',
              style: GoogleFonts.montserrat(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
        const Spacer(),
        Text(
          timeRange,
          style: GoogleFonts.montserrat(
            fontSize: 12.5,
            fontWeight: isClosed ? FontWeight.w600 : FontWeight.w500,
            color: isClosed ? const Color(0xFFC62828) : const Color(0xFF333333),
          ),
        ),
      ],
    ),
  );
}

/// CustomPainter generating natural green leather grain, micro-creases & 3D embossed pores.
class _LeatherGrainTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Organic Vignette Inner Shadow around leather perimeter
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.38)],
        stops: const [0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);

    // 2. High-Contrast Organic Micro-Creases (Wrinkle Lines)
    final creaseShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final creaseHighlightPaint = Paint()
      ..color = const Color(0xFF5A8B6D).withValues(alpha: 0.38)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double y = 8; y < size.height; y += 14) {
      path.reset();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        final seed = (x * 19 + y * 37).toInt();
        final dy = (seed % 7) - 3.5;
        path.quadraticBezierTo(x + 10, y + dy, x + 20, y + (seed % 5 - 2.5));
      }
      canvas.drawPath(path, creaseShadowPaint);
      canvas.drawPath(path.shift(const Offset(0.7, 0.8)), creaseHighlightPaint);
    }

    // 3. Dense 3D Embossed Pebble Pores & Leather Stipples
    final darkPorePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;

    final highlightPorePaint = Paint()
      ..color = const Color(0xFF6DA583).withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;

    for (double x = 4; x < size.width; x += 9) {
      for (double y = 4; y < size.height; y += 9) {
        final seed = (x * 41 + y * 67).toInt();
        if (seed % 3 == 0) {
          final r = (seed % 5 == 0) ? 1.4 : 0.9;
          final offsetX = (seed % 5) - 2.5;
          final offsetY = ((seed * 17) % 5) - 2.5;

          final center = Offset(x + offsetX, y + offsetY);
          // Dark pore shadow
          canvas.drawCircle(center, r, darkPorePaint);
          // Top-left specular sheen highlight
          canvas.drawCircle(
            center + const Offset(-0.5, -0.5),
            r * 0.65,
            highlightPorePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeatherTopstitchPainter extends CustomPainter {
  _LeatherTopstitchPainter({
    required this.borderRadius,
    required this.stitchColor,
  });

  final double borderRadius;
  final Color stitchColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double inset = 4.5;
    const double dashWidth = 6.5;
    const double dashGap = 3.5;

    final double insetRadius = (borderRadius - inset).clamp(4.0, borderRadius);
    final RRect insetRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        (size.width - inset * 2).clamp(0.0, size.width),
        (size.height - inset * 2).clamp(0.0, size.height),
      ),
      Radius.circular(insetRadius),
    );

    final Path insetPath = Path()..addRRect(insetRRect);

    final puncturePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = const Color(0xFFF3E7D3).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final PathMetric metric in insetPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;

        if (len > 0) {
          final Tangent? tStart = metric.getTangentForOffset(distance);
          final Tangent? tEnd = metric.getTangentForOffset(distance + len);

          if (tStart != null) {
            canvas.drawCircle(tStart.position, 1.1, puncturePaint);
          }
          if (tEnd != null) {
            canvas.drawCircle(tEnd.position, 1.1, puncturePaint);
          }

          const int steps = 5;
          for (int i = 0; i < steps; i++) {
            final double f1 = i / steps;
            final double f2 = (i + 1) / steps;
            final double d1 = distance + len * f1;
            final double d2 = distance + len * f2;
            final double fMid = (f1 + f2) / 2;

            final Path subSegment = metric.extractPath(d1, d2);
            final double w = 1.0 + 1.2 * math.sin(fMid * math.pi);

            canvas.drawPath(
              subSegment.shift(const Offset(0.6, 0.8)),
              shadowPaint..strokeWidth = w,
            );

            final mainPaint = Paint()
              ..color = stitchColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = w
              ..strokeCap = StrokeCap.round;

            canvas.drawPath(subSegment, mainPaint);

            canvas.drawPath(
              subSegment.shift(const Offset(-0.3, -0.4)),
              highlightPaint..strokeWidth = math.max(0.6, w * 0.4),
            );
          }
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LeatherTopstitchPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.stitchColor != stitchColor;
  }
}

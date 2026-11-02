import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اتجاه القبلة'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QiblahDirection>(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, AsyncSnapshot<QiblahDirection> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'جاري معايرة البوصلة وتحديد موقع القبلة...',
                      style: TextStyle(fontSize: context.respFont(14)),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: Responsive.pagePadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.compass_calibration,
                          size: 64,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'تعذر استقبال بيانات البوصلة أو الـ GPS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: context.respFont(16),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تأكد من تفعيل مستشعر البوصلة وإعطاء صلاحية الموقع للتطبيق.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: context.respFont(13),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final qiblahDirection = snapshot.data!;
            final double offset = qiblahDirection.offset;
            final bool isAligned = offset.abs() <= 6.0;

            return LayoutBuilder(
              builder: (context, constraints) {
                double dialSize = (constraints.maxWidth * 0.72).clamp(240.0, 360.0);

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: Responsive.pagePadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Status Card (Aligned / Turning)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isAligned
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : AppColors.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAligned
                                  ? const Color(0xFF10B981)
                                  : AppColors.secondaryColor.withOpacity(0.4),
                              width: isAligned ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isAligned ? Icons.check_circle : Icons.explore_outlined,
                                color: isAligned
                                    ? const Color(0xFF10B981)
                                    : AppColors.secondaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  isAligned
                                      ? 'أنت الآن باتجاه القبلة المشرفة! 🕋'
                                      : 'قم بتدوير الهاتف نحو مؤشر الكعبة الذهبي',
                                  style: TextStyle(
                                    fontSize: context.respFont(14),
                                    fontWeight: FontWeight.bold,
                                    color: isAligned
                                        ? const Color(0xFF047857)
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Degrees Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'زاوية القبلة: ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: context.respFont(14),
                              ),
                            ),
                            Text(
                              '${qiblahDirection.offset.abs().toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: context.respFont(22),
                                fontWeight: FontWeight.bold,
                                color: isAligned
                                    ? const Color(0xFF10B981)
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Masterpiece Compass Dial
                        SizedBox(
                          width: dialSize,
                          height: dialSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Rotating Compass Dial
                              Transform.rotate(
                                angle: (qiblahDirection.direction * (math.pi / 180) * -1),
                                child: Container(
                                  width: dialSize,
                                  height: dialSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.surface,
                                    border: Border.all(
                                      color: isAligned
                                          ? const Color(0xFF10B981)
                                          : AppColors.primaryColor.withOpacity(0.3),
                                      width: isAligned ? 4 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isAligned
                                            ? const Color(0xFF10B981).withOpacity(0.3)
                                            : AppColors.primaryColor.withOpacity(0.12),
                                        blurRadius: isAligned ? 25 : 15,
                                        spreadRadius: isAligned ? 4 : 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Degree Ticks Background
                                      CustomPaint(
                                        size: Size(dialSize, dialSize),
                                        painter: CompassDialPainter(
                                          isDark: theme.brightness == Brightness.dark,
                                        ),
                                      ),

                                      // Cardinal Points (N, S, E, W)
                                      const Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'شمال',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'جنوب',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'غرب',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'شرق',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Qibla Pointer & Kaaba Target Marker
                              Transform.rotate(
                                angle: (qiblahDirection.qiblah * (math.pi / 180)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Golden Kaaba Target Icon at the Qibla Angle
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isAligned
                                            ? const Color(0xFF10B981)
                                            : AppColors.secondaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isAligned
                                                    ? const Color(0xFF10B981)
                                                    : AppColors.secondaryColor)
                                                .withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        '🕋',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Needle line towards Kaaba
                                    Container(
                                      width: 4,
                                      height: dialSize * 0.32,
                                      decoration: BoxDecoration(
                                        color: isAligned
                                            ? const Color(0xFF10B981)
                                            : AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(height: dialSize * 0.38), // Counterbalance
                                  ],
                                ),
                              ),

                              // Center Decorative Badge
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                    color: isAligned
                                        ? const Color(0xFF10B981)
                                        : AppColors.secondaryColor,
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.navigation,
                                    color: isAligned
                                        ? const Color(0xFF10B981)
                                        : AppColors.primaryColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Calibration & Instructions Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إرشادات بدقة عالية:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.respFont(14),
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildInstructionRow(
                                context,
                                Icons.phone_android,
                                'ضع الهاتف أفقياً على سطح مستوٍ لضمان دقة الحساسات.',
                              ),
                              const SizedBox(height: 8),
                              _buildInstructionRow(
                                context,
                                Icons.do_not_disturb_on_outlined,
                                'ابتعد عن الأجهزة الإلكترونية والمغناطيسية القريبة.',
                              ),
                              const SizedBox(height: 8),
                              _buildInstructionRow(
                                context,
                                Icons.gesture,
                                'حرك الهاتف على شكل رقم (8) لمعايرة البوصلة عند الحاجة.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.respFont(12.5),
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw degree ticks around the compass dial
class CompassDialPainter extends CustomPainter {
  final bool isDark;
  CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = isDark ? Colors.white30 : Colors.black26
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black54
      ..strokeWidth = 2.0;

    for (int i = 0; i < 360; i += 10) {
      final isMajor = i % 30 == 0;
      final angle = i * (math.pi / 180);

      final tickLength = isMajor ? 12.0 : 6.0;
      final startRadius = radius - 16;
      final endRadius = startRadius - tickLength;

      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

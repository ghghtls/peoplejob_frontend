import 'package:flutter/material.dart';

// ─── PeopleJob 로고 위젯 ─────────────────────────────────────────────────────

class PeopleJobLogo extends StatelessWidget {
  final bool isDark;
  final double height;

  const PeopleJobLogo({super.key, this.isDark = false, this.height = 28});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0B1220);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: height * 0.8,
          height: height,
          child: CustomPaint(painter: _LogoMarkPainter(isDark: isDark)),
        ),
        const SizedBox(width: 5),
        Text(
          'PeopleJob',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: height * 0.57,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  final bool isDark;
  const _LogoMarkPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final blue = isDark ? const Color(0xFF4DA3FF) : const Color(0xFF0B5FFF);
    const champagne = Color(0xFFC8A96A);

    // Diamond 1 (primary, left-center)
    final p1 = Paint()..color = blue..style = PaintingStyle.fill;
    final cx1 = size.width * 0.36;
    final cy1 = size.height * 0.58;
    final r1  = size.width * 0.30;
    canvas.drawPath(
      Path()
        ..moveTo(cx1, cy1 - r1)
        ..lineTo(cx1 + r1, cy1)
        ..lineTo(cx1, cy1 + r1)
        ..lineTo(cx1 - r1, cy1)
        ..close(),
      p1,
    );

    // Diamond 2 (secondary, shifted right, 55% opacity)
    final p2 = Paint()
      ..color = blue.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final cx2 = size.width * 0.64;
    final cy2 = size.height * 0.62;
    final r2  = size.width * 0.24;
    canvas.drawPath(
      Path()
        ..moveTo(cx2, cy2 - r2)
        ..lineTo(cx2 + r2, cy2)
        ..lineTo(cx2, cy2 + r2)
        ..lineTo(cx2 - r2, cy2)
        ..close(),
      p2,
    );

    // Champagne accent circle (top-right)
    canvas.drawCircle(
      Offset(size.width * 0.77, size.height * 0.24),
      size.width * 0.13,
      Paint()..color = champagne..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter old) => isDark != old.isDark;
}

// ─── 공통 AppBar (Scaffold.appBar 용) ────────────────────────────────────────

AppBar buildCommonAppBar({
  String? title,
  Widget? titleWidget,
  List<Widget>? actions,
  bool showBackButton = true,
  bool showHomeButton = true,
  Color backgroundColor = Colors.white,
  VoidCallback? onBack,
}) {
  return AppBar(
    title: titleWidget ??
        (title != null
            ? Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B1220),
                  letterSpacing: -0.4,
                ),
              )
            : null),
    backgroundColor: backgroundColor,
    foregroundColor: const Color(0xFF0B1220),
    elevation: 0,
    scrolledUnderElevation: 0.5,
    shadowColor: const Color(0xFFD1D1D6),
    surfaceTintColor: backgroundColor,
    automaticallyImplyLeading: false,
    leading: showBackButton
        ? Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFF0B5FFF), size: 20),
              onPressed: onBack ?? () => Navigator.of(ctx).pop(),
              padding: EdgeInsets.zero,
            ),
          )
        : null,
    actions: [
      if (showHomeButton) const HomeButton(),
      ...?actions,
      const SizedBox(width: 4),
    ],
  );
}

// ─── 홈 버튼 (공용 위젯) ─────────────────────────────────────────────────────

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '홈으로',
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0B5FFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Color(0xFF0B5FFF),
            size: 20,
          ),
        ),
      ),
    );
  }
}

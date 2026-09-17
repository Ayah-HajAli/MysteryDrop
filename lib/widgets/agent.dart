import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The house character. Drawn from scratch as flat vector paths so it scales
/// cleanly and can be recoloured per screen — no image assets involved.
enum AgentPose {
  /// Full figure, hands in coat, shoulders up.
  standing,

  /// Hat and eyes only, cropped by the bottom of the widget.
  peeking,

  /// Full figure holding a jar of evidence.
  evidence,

  /// Shoulders shrugged, arms out. Used for empty states.
  shrug,
}

class Agent extends StatelessWidget {
  const Agent({
    super.key,
    this.pose = AgentPose.standing,
    this.height = 220,
    this.coat = Pal.paper,
    this.ink = Pal.black,
    this.accent = Pal.mustard,
    this.lookAt = 0.35,
  });

  final AgentPose pose;
  final double height;
  final Color coat;
  final Color ink;
  final Color accent;

  /// -1 hard left, 0 straight at you, 1 hard right.
  final double lookAt;

  Size get _design => switch (pose) {
        AgentPose.peeking => const Size(220, 120),
        AgentPose.evidence => const Size(230, 265),
        _ => const Size(200, 265),
      };

  @override
  Widget build(BuildContext context) {
    final d = _design;
    return SizedBox(
      height: height,
      width: height * d.width / d.height,
      child: CustomPaint(
        painter: _AgentPainter(
          pose: pose,
          coat: coat,
          ink: ink,
          accent: accent,
          lookAt: lookAt.clamp(-1.0, 1.0),
          design: d,
        ),
      ),
    );
  }
}

class _AgentPainter extends CustomPainter {
  _AgentPainter({
    required this.pose,
    required this.coat,
    required this.ink,
    required this.accent,
    required this.lookAt,
    required this.design,
  });

  final AgentPose pose;
  final Color coat;
  final Color ink;
  final Color accent;
  final double lookAt;
  final Size design;

  late Paint _fillCoat;
  late Paint _fillInk;
  late Paint _fillAccent;
  late Paint _line;
  late Paint _white;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / design.width, size.height / design.height);
    canvas.save();
    canvas.translate(
      (size.width - design.width * scale) / 2,
      (size.height - design.height * scale) / 2,
    );
    canvas.scale(scale);

    _fillCoat = Paint()..color = coat;
    _fillInk = Paint()..color = ink;
    _fillAccent = Paint()..color = accent;
    _white = Paint()..color = const Color(0xFFFFFDF4);
    _line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (pose) {
      case AgentPose.peeking:
        _paintPeek(canvas);
        break;
      case AgentPose.evidence:
        _paintFigure(canvas, jar: true, shrug: false);
        break;
      case AgentPose.shrug:
        _paintFigure(canvas, jar: false, shrug: true);
        break;
      case AgentPose.standing:
        _paintFigure(canvas, jar: false, shrug: false);
        break;
    }

    canvas.restore();
  }

  // ------------------------------------------------------------------ parts

  void _paintFigure(Canvas canvas, {required bool jar, required bool shrug}) {
    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 252), width: 150, height: 16),
      Paint()..color = ink.withOpacity(0.18),
    );

    // Legs and shoes.
    canvas.drawRect(const Rect.fromLTRB(78, 198, 96, 238), _fillInk);
    canvas.drawRect(const Rect.fromLTRB(106, 198, 124, 238), _fillInk);
    _shoe(canvas, const Rect.fromLTRB(56, 228, 100, 248));
    _shoe(canvas, const Rect.fromLTRB(104, 228, 148, 248));

    // Dark torso behind the coat — this is what shows at the collar.
    final torso = RRect.fromRectAndRadius(
      const Rect.fromLTRB(70, 66, 130, 212),
      const Radius.circular(24),
    );
    canvas.drawRRect(torso, _fillInk);

    // Head.
    canvas.drawCircle(const Offset(100, 80), 32, _fillInk);

    // Eyes sit under the brim, looking anywhere but at you.
    _eye(canvas, const Offset(87, 84));
    _eye(canvas, const Offset(113, 84));

    // Coat.
    final coatPath = Path()
      ..moveTo(42, 214)
      ..cubicTo(38, 152, 44, 106, 68, shrug ? 88 : 94)
      ..cubicTo(82, shrug ? 80 : 86, 118, shrug ? 80 : 86, 132, shrug ? 88 : 94)
      ..cubicTo(156, 106, 162, 152, 158, 214)
      ..close();
    canvas.drawPath(coatPath, _fillCoat);
    canvas.drawPath(coatPath, _line);

    // Collar: two flaps opening on the dark torso.
    final leftFlap = Path()
      ..moveTo(70, 92)
      ..lineTo(96, 104)
      ..lineTo(76, 140)
      ..close();
    final rightFlap = Path()
      ..moveTo(130, 92)
      ..lineTo(104, 104)
      ..lineTo(124, 140)
      ..close();
    for (final f in [leftFlap, rightFlap]) {
      canvas.drawPath(f, _fillCoat);
      canvas.drawPath(f, _line);
    }
    // The V of dark shirt between the flaps.
    final notch = Path()
      ..moveTo(96, 104)
      ..lineTo(104, 104)
      ..lineTo(100, 124)
      ..close();
    canvas.drawPath(notch, _fillInk);

    // Placket buttons.
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(112, 150.0 + i * 22), 4.5, _fillInk);
    }

    // Belt tie.
    canvas.drawLine(const Offset(52, 170), const Offset(148, 170), _line);

    // Arms.
    if (shrug) {
      canvas.drawLine(const Offset(52, 118), const Offset(26, 96), _line);
      canvas.drawLine(const Offset(148, 118), const Offset(174, 96), _line);
      _hand(canvas, const Offset(20, 88));
      _hand(canvas, const Offset(180, 88));
    } else {
      // Seam lines suggesting arms folded into the coat.
      canvas.drawPath(
        Path()
          ..moveTo(58, 112)
          ..cubicTo(50, 140, 50, 168, 56, 190),
        _line,
      );
      canvas.drawPath(
        Path()
          ..moveTo(142, 112)
          ..cubicTo(150, 140, 150, 168, 144, 190),
        _line,
      );
    }

    if (jar) {
      _jar(canvas, const Offset(176, 176));
      canvas.drawLine(const Offset(146, 128), const Offset(172, 152), _line);
      _hand(canvas, const Offset(176, 154));
    }

    _hat(canvas, const Offset(100, 64));
  }

  void _paintPeek(Canvas canvas) {
    canvas.drawCircle(const Offset(110, 100), 38, _fillInk);
    _eye(canvas, const Offset(95, 98), r: 13);
    _eye(canvas, const Offset(125, 98), r: 13);
    _hat(canvas, const Offset(110, 70), scale: 1.16);
  }

  void _hat(Canvas canvas, Offset c, {double scale = 1}) {
    final brim = Rect.fromCenter(
      center: Offset(c.dx, c.dy + 2 * scale),
      width: 146 * scale,
      height: 34 * scale,
    );
    final crown = Path()
      ..moveTo(c.dx - 26 * scale, c.dy + 4 * scale)
      ..cubicTo(
        c.dx - 30 * scale, c.dy - 26 * scale,
        c.dx - 20 * scale, c.dy - 44 * scale,
        c.dx, c.dy - 44 * scale,
      )
      ..cubicTo(
        c.dx + 20 * scale, c.dy - 44 * scale,
        c.dx + 30 * scale, c.dy - 26 * scale,
        c.dx + 26 * scale, c.dy + 4 * scale,
      )
      ..close();

    canvas.drawPath(crown, _fillCoat);
    canvas.drawPath(crown, _line);

    // Hat band, clipped to the crown so it reads as printed-on.
    canvas.save();
    canvas.clipPath(crown);
    canvas.drawRect(
      Rect.fromLTRB(
        c.dx - 40 * scale,
        c.dy - 12 * scale,
        c.dx + 40 * scale,
        c.dy + 4 * scale,
      ),
      _fillInk,
    );
    canvas.restore();

    canvas.drawOval(brim, _fillCoat);
    canvas.drawOval(brim, _line);
  }

  void _eye(Canvas canvas, Offset c, {double r = 12}) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.9, height: r * 2.1),
      _white,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.9, height: r * 2.1),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(c.dx + lookAt * r * 0.5, c.dy + r * 0.34),
      r * 0.46,
      _fillInk,
    );
  }

  void _hand(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 13, _fillCoat);
    canvas.drawCircle(c, 13, _line);
    for (var i = 0; i < 2; i++) {
      canvas.drawLine(
        Offset(c.dx - 7, c.dy - 3 + i * 7),
        Offset(c.dx + 7, c.dy - 3 + i * 7),
        Paint()
          ..color = ink
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _shoe(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        r,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      _fillInk,
    );
  }

  void _jar(Canvas canvas, Offset c) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 40, height: 50),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, _fillAccent);
    canvas.drawRRect(bodyRect, _line);
    final lid = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 30), width: 44, height: 14),
      const Radius.circular(4),
    );
    canvas.drawRRect(lid, _fillInk);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 2), width: 28, height: 6),
      _fillInk,
    );
  }

  @override
  bool shouldRepaint(covariant _AgentPainter old) =>
      old.pose != pose ||
      old.coat != coat ||
      old.ink != ink ||
      old.accent != accent ||
      old.lookAt != lookAt;
}

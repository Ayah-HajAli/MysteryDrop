import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import 'agent.dart';

/// Stands in for the day's photograph. Every case seed produces a different
/// but stable composition, so a case looks the same each time you open it.
class EvidencePlate extends StatelessWidget {
  const EvidencePlate({
    super.key,
    required this.seed,
    required this.kind,
    this.height = 250,
    this.base = Pal.paperDeep,
    this.mark = Pal.black,
    this.accent = Pal.mustard,
    this.showAgent = false,
    this.caption = 'EXHIBIT A — DO NOT REMOVE FROM FILE',
  });

  final int seed;
  final DropKind kind;
  final double height;
  final Color base;
  final Color mark;
  final Color accent;
  final bool showAgent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _EvidencePainter(
                seed: seed,
                kind: kind,
                base: base,
                mark: mark,
                accent: accent,
              ),
            ),
            if (showAgent)
              Positioned(
                right: -8,
                bottom: 0,
                child: Agent(
                  pose: AgentPose.peeking,
                  height: height * 0.42,
                  coat: Pal.paper,
                  lookAt: -0.6,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Pal.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(caption, style: label(10, color: Pal.paper)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidencePainter extends CustomPainter {
  _EvidencePainter({
    required this.seed,
    required this.kind,
    required this.base,
    required this.mark,
    required this.accent,
  });

  final int seed;
  final DropKind kind;
  final Color base;
  final Color mark;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    switch (kind) {
      case DropKind.location:
        _location(canvas, size, rnd);
        break;
      case DropKind.object:
        _object(canvas, size, rnd);
        break;
      case DropKind.photograph:
        _photograph(canvas, size, rnd);
        break;
    }

    // Diagonal hatch, like a coarse halftone over a reprinted photo.
    final hatch = Paint()
      ..color = mark.withOpacity(0.08)
      ..strokeWidth = 1.4;
    for (double x = -size.height; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), hatch);
    }

    _cropMarks(canvas, size);
  }

  void _location(Canvas canvas, Size size, math.Random rnd) {
    final w = size.width, h = size.height;
    final wall = Paint()..color = mark.withOpacity(0.12);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.18, w, h), wall);

    // Brick courses.
    final brick = Paint()
      ..color = mark.withOpacity(0.16)
      ..strokeWidth = 1.6;
    for (double y = h * 0.22; y < h; y += 13) {
      canvas.drawLine(Offset(0, y), Offset(w, y), brick);
    }

    // The door itself.
    final door = Rect.fromLTWH(w * 0.34, h * 0.26, w * 0.3, h * 0.6);
    canvas.drawRect(door, Paint()..color = accent.withOpacity(0.9));
    canvas.drawRect(
      door,
      Paint()
        ..color = mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRect(
      door.deflate(10),
      Paint()
        ..color = mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Step, and the flower nobody can explain.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.30, h * 0.86, w * 0.38, 10),
      Paint()..color = mark.withOpacity(0.35),
    );
    canvas.drawCircle(Offset(w * 0.60, h * 0.845), 5, Paint()..color = Pal.rust);

    // Tram cable overhead.
    canvas.drawLine(
      Offset(0, h * 0.14),
      Offset(w, h * 0.10),
      Paint()
        ..color = mark
        ..strokeWidth = 3,
    );
  }

  void _object(Canvas canvas, Size size, math.Random rnd) {
    final w = size.width, h = size.height;
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.48),
      h * 0.34,
      Paint()..color = accent.withOpacity(0.55),
    );
    final stroke = Paint()
      ..color = mark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // A key-ish silhouette: shaft, bow, bit.
    canvas.drawCircle(Offset(w * 0.34, h * 0.45), 26, Paint()..color = mark);
    canvas.drawCircle(Offset(w * 0.34, h * 0.45), 11, Paint()..color = base);
    canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.42, w * 0.3, 14), Paint()..color = mark);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.45, 12, 26), Paint()..color = mark);
    canvas.drawRect(Rect.fromLTWH(w * 0.52, h * 0.45, 10, 18), Paint()..color = mark);

    // Measuring rule along the bottom, the way evidence gets shot.
    canvas.drawLine(Offset(w * 0.1, h * 0.78), Offset(w * 0.9, h * 0.78), stroke);
    for (var i = 0; i <= 8; i++) {
      final x = w * 0.1 + (w * 0.8 / 8) * i;
      canvas.drawLine(Offset(x, h * 0.78), Offset(x, h * 0.78 - (i.isEven ? 12 : 7)), stroke);
    }
  }

  void _photograph(Canvas canvas, Size size, math.Random rnd) {
    final w = size.width, h = size.height;
    // Stacked bands like an over-exposed street shot.
    var y = 0.0;
    var i = 0;
    while (y < h) {
      final band = h * (0.1 + rnd.nextDouble() * 0.16);
      canvas.drawRect(
        Rect.fromLTWH(0, y, w, band),
        Paint()..color = (i.isEven ? mark : accent).withOpacity(0.10 + i * 0.04),
      );
      y += band;
      i++;
    }
    // Stair treads.
    for (var s = 0; s < 7; s++) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.18 + s * 8, h * 0.9 - s * (h * 0.09), w * 0.5, 9),
        Paint()..color = mark.withOpacity(0.7),
      );
    }
    // Redaction bar.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.22, w * 0.42, 22),
      Paint()..color = mark,
    );
  }

  void _cropMarks(Canvas canvas, Size size) {
    final p = Paint()
      ..color = mark
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    const len = 18.0;
    const pad = 10.0;
    final corners = <List<Offset>>[
      [const Offset(pad, pad), const Offset(pad + len, pad), const Offset(pad, pad + len)],
      [
        Offset(size.width - pad, pad),
        Offset(size.width - pad - len, pad),
        Offset(size.width - pad, pad + len)
      ],
    ];
    for (final c in corners) {
      canvas.drawLine(c[0], c[1], p);
      canvas.drawLine(c[0], c[2], p);
    }
  }

  @override
  bool shouldRepaint(covariant _EvidencePainter old) =>
      old.seed != seed || old.kind != kind || old.base != base;
}

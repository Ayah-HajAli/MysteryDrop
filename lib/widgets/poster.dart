import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// A block with a hard offset shadow instead of a soft blur — the way a
/// two-colour print job would do it.
class ChunkyBox extends StatelessWidget {
  const ChunkyBox({
    super.key,
    required this.child,
    this.color = Pal.paper,
    this.radius = 18,
    this.offset = 6,
    this.border = 3,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final Color color;
  final double radius;
  final double offset;
  final double border;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(left: offset, top: offset),
            child: Container(
              decoration: BoxDecoration(
                color: Pal.black,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: offset, bottom: offset),
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Pal.black, width: border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = Pal.mustard,
    this.textColor = Pal.black,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final bool expand;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final shift = _down ? 5.0 : 0.0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onPressed!.call();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.42,
          child: SizedBox(
            width: widget.expand ? double.infinity : null,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, top: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Pal.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(shift, shift),
                  child: Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 5),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Pal.black, width: 3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 19, color: widget.textColor),
                          const SizedBox(width: 9),
                        ],
                        Flexible(
                          child: Text(
                            widget.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: label(14, color: widget.textColor, w: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small flat pill used for case metadata.
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = Pal.black, this.filled = false});

  final String text;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: label(10.5, color: filled ? Pal.paper : color),
      ),
    );
  }
}

/// The starburst from the poster set, used once per screen at most.
class Starburst extends StatelessWidget {
  const Starburst({
    super.key,
    required this.top,
    this.bottom,
    this.size = 108,
    this.color = Pal.black,
    this.textColor = Pal.mustard,
    this.rotation = -0.12,
  });

  final String top;
  final String? bottom;
  final double size;
  final Color color;
  final Color textColor;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _StarburstPainter(color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(top.toUpperCase(),
                    textAlign: TextAlign.center, style: display(size * 0.2, color: textColor)),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(bottom!.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: label(size * 0.082, color: textColor)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  _StarburstPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const points = 16;
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = (math.pi / points) * i - math.pi / 2;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _StarburstPainter old) => old.color != color;
}

/// Uncoated-paper speckle. Cheap, deterministic, drawn once.
class Grain extends StatelessWidget {
  const Grain({super.key, this.opacity = 0.055});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GrainPainter(opacity), size: Size.infinite),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    final p = Paint()..color = Pal.black.withOpacity(opacity);
    final count = (size.width * size.height / 900).clamp(200, 2600).toInt();
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.1 + 0.3,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.opacity != opacity;
}

/// Ticking clock in the poster's voice: 04:12:55
class Countdown extends StatefulWidget {
  const Countdown({
    super.key,
    required this.target,
    this.style,
    this.onFinished,
    this.compact = false,
  });

  final DateTime target;
  final TextStyle? style;
  final VoidCallback? onFinished;
  final bool compact;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!_fired && !DateTime.now().isBefore(widget.target)) {
        _fired = true;
        widget.onFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.target.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(left.inHours);
    final m = two(left.inMinutes.remainder(60));
    final s = two(left.inSeconds.remainder(60));
    return Text(
      widget.compact ? '${h}h ${m}m' : '$h:$m:$s',
      style: widget.style ?? display(44),
    );
  }
}

/// Redaction bar. Used wherever an answer is being withheld.
class Redacted extends StatelessWidget {
  const Redacted({super.key, required this.width, this.height = 18});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Pal.black,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

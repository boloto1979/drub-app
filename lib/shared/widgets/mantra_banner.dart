import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MantraBanner extends StatefulWidget {
  final double height;
  final Color? color;
  final double spacing;

  const MantraBanner({
    super.key,
    this.height = 48,
    this.color,
    this.spacing = 7,
  });

  @override
  State<MantraBanner> createState() => _MantraBannerState();
}

class _MantraBannerState extends State<MantraBanner> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/images/vajra-guru.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _image = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    final tint = widget.color ?? Theme.of(context).colorScheme.primary;

    if (_image == null) return SizedBox(height: widget.height);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: CustomPaint(
        painter: _MantraPainter(
          image: _image!,
          color: tint,
          spacing: widget.spacing,
        ),
      ),
    );
  }
}

class _MantraPainter extends CustomPainter {
  final ui.Image image;
  final Color color;
  final double spacing;

  const _MantraPainter({
    required this.image,
    required this.color,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / image.height;
    final scaledWidth = image.width * scale;

    final paint = Paint()
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);

    double x = 0;
    while (x < size.width) {
      final src = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble(),
      );
      final dst = Rect.fromLTWH(x, 0, scaledWidth, size.height);
      canvas.drawImageRect(image, src, dst, paint);
      x += scaledWidth + spacing;
    }
  }

  @override
  bool shouldRepaint(_MantraPainter old) =>
      old.image != image || old.color != color || old.spacing != spacing;
}

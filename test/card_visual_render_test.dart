import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/constants/card_visuals.dart';

const _renderBanks = [
  'axis',
  'hdfc',
  'bandhan',
  'bank_of_baroda',
  'bank_of_india',
  'bank_of_maharashtra',
  'idbi',
  'dcb',
  'indusind',
  'csb',
  'idfc',
  'kotak',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders the reference-style card visual grid', () async {
    const canvasSize = Size(1588, 1792);
    const cardSize = Size(410, 257);
    const origin = Offset(134, 172);
    const columnGap = 54.0;
    const rowGap = 104.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & canvasSize, paint);

    for (var index = 0; index < _renderBanks.length; index++) {
      final column = index % 3;
      final row = index ~/ 3;
      final offset = Offset(
        origin.dx + column * (cardSize.width + columnGap),
        origin.dy + row * (cardSize.height + rowGap),
      );
      _paintCard(canvas, offset, cardSize, _renderBanks[index]);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final file = File('build/card_visuals/reference_grid.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(byteData!.buffer.asUint8List());
  });
}

void _paintCard(Canvas canvas, Offset offset, Size size, String bankId) {
  final rect = offset & size;
  final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
  final visual = CardVisuals.forBank(bankId);

  canvas.drawShadow(
    Path()..addRRect(rrect),
    Colors.black.withValues(alpha: 0.16),
    8,
    true,
  );

  final gradient = visual.gradient;
  final gradientPaint = Paint()..shader = gradient.createShader(rect);
  canvas.drawRRect(rrect, gradientPaint);

  if (visual.patternPainter == null) return;

  canvas.save();
  canvas.clipRRect(rrect);
  canvas.translate(offset.dx, offset.dy);
  visual.patternPainter!.paint(canvas, size);
  canvas.restore();
}

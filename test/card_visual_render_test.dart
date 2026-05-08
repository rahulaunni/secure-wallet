import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/data/bank_assets.dart';

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
    await _renderGrid(
      filePath: 'build/card_visuals/reference_grid.png',
      banks: _renderBanks,
      canvasSize: const Size(1588, 1792),
      cardSize: const Size(410, 257),
      origin: const Offset(134, 172),
      columnGap: 54,
      rowGap: 104,
      columns: 3,
    );
  });

  test('renders all thirty-five bank overlay patterns', () async {
    await _renderGrid(
      filePath: 'build/card_visuals/all_bank_overlay_grid.png',
      banks: BankAssets.supportedBanks,
      canvasSize: const Size(1740, 1760),
      cardSize: const Size(300, 188),
      origin: const Offset(70, 92),
      columnGap: 36,
      rowGap: 48,
      columns: 5,
    );
  });
}

Future<void> _renderGrid({
  required String filePath,
  required List<String> banks,
  required Size canvasSize,
  required Size cardSize,
  required Offset origin,
  required double columnGap,
  required double rowGap,
  required int columns,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(Offset.zero & canvasSize, paint);

  for (var index = 0; index < banks.length; index++) {
    final column = index % columns;
    final row = index ~/ columns;
    final offset = Offset(
      origin.dx + column * (cardSize.width + columnGap),
      origin.dy + row * (cardSize.height + rowGap),
    );
    _paintCard(canvas, offset, cardSize, banks[index]);
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    canvasSize.width.toInt(),
    canvasSize.height.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(byteData!.buffer.asUint8List());
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

  expect(
    CardVisuals.customVisualAssetPaths,
    contains(visual.visualAssetPath),
  );
}

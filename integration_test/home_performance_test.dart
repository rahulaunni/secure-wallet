import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swallet/data/local/hive_adapters.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/diagnostics/performance_runtime_diagnostics.dart';
import 'package:swallet/models/card_data.dart';
import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/screens/home_screen.dart';
import 'package:swallet/widgets/card/bank_card.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await Hive.initFlutter();
    registerHiveAdapters();
    if (!Hive.isBoxOpen(HiveBoxes.cards)) {
      await Hive.openBox<CardData>(HiveBoxes.cards);
    }
    if (!Hive.isBoxOpen(HiveBoxes.settings)) {
      await Hive.openBox(HiveBoxes.settings);
    }
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(HiveBoxes.cards)) {
      await Hive.box<CardData>(HiveBoxes.cards).clear();
    }
    if (Hive.isBoxOpen(HiveBoxes.settings)) {
      await Hive.box(HiveBoxes.settings).clear();
    }
  });

  testWidgets('measure HomeScreen card scrolling runtime', (tester) async {
    await binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => binding.setSurfaceSize(null));

    final diagnostics = PerformanceRuntimeDiagnostics.instance;
    diagnostics.reset();

    final cardsBox = Hive.box<CardData>(HiveBoxes.cards);
    await cardsBox.clear();
    await cardsBox.addAll(_buildCards());

    final settingsBox = Hive.box(HiveBoxes.settings);
    await settingsBox.put('use_biometrics', false);
    await settingsBox.put('swipe_actions_tutorial_v1_seen', true);
    await settingsBox.put('is_dark', true);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: HomeScreen(
            isDark: true,
            onThemeChanged: (_) {},
            unlockSettleAnimation: const AlwaysStoppedAnimation<double>(1),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final initialVisibleCards = _countVisibleCards(tester);
    diagnostics.recordVisibleCardsSample('initial', initialVisibleCards);

    final frameTimings = <FrameTiming>[];
    void timingsCallback(List<FrameTiming> timings) {
      frameTimings.addAll(timings);
    }

    WidgetsBinding.instance.addTimingsCallback(timingsCallback);
    await _performMeasuredScroll(tester);
    await tester.pump(const Duration(milliseconds: 400));
    WidgetsBinding.instance.removeTimingsCallback(timingsCallback);
    await tester.pump(const Duration(milliseconds: 300));

    final finalVisibleCards = _countVisibleCards(tester);
    diagnostics.recordVisibleCardsSample('after_scroll', finalVisibleCards);

    final runtimeDiagnostics = diagnostics.snapshot();
    final performanceSummary = _summarizeFrameTimings(frameTimings);
    final markdown = _buildRuntimeMarkdown(
      performanceSummary: performanceSummary,
      runtimeDiagnostics: runtimeDiagnostics,
      targetLabel: kIsWeb ? 'Chrome web' : 'local device',
    );

    final payload = <String, dynamic>{
      'performance_summary': performanceSummary,
      'runtime_diagnostics': runtimeDiagnostics,
      'runtime_markdown': markdown,
    };

    debugPrintSynchronously('PERF_RUNTIME_JSON_START');
    debugPrintSynchronously(jsonEncode(payload));
    debugPrintSynchronously('PERF_RUNTIME_JSON_END');
  });
}

Future<void> _performMeasuredScroll(WidgetTester tester) async {
  final Finder cardList = find.byType(ListView).first;
  final Offset start = tester.getCenter(cardList);
  final TestGesture gesture = await tester.startGesture(start);

  for (var index = 0; index < 8; index++) {
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump(const Duration(milliseconds: 16));
  }

  await gesture.up();
  await tester.pump(const Duration(milliseconds: 500));
}

List<CardData> _buildCards() {
  const bankIds = <String>[
    'hdfc',
    'axis',
    'icici',
    'kotak',
    'idbi',
    'federal',
    'indusind',
    'rbl',
    'yes',
    'citibank',
    'bank_of_baroda',
    'canara',
  ];

  const networks = <CardNetwork>[
    CardNetwork.visa,
    CardNetwork.mastercard,
    CardNetwork.rupay,
    CardNetwork.amex,
  ];

  final cards = <CardData>[];
  for (var index = 0; index < bankIds.length; index++) {
    cards.add(
      CardData(
        bankCid: bankIds[index],
        cardNetwork: networks[index % networks.length],
        cardType: index.isEven ? CardType.credit : CardType.debit,
        cardNumber: '411111111111${(1000 + index).toString().padLeft(4, '0')}',
        expiry: '12/3${index % 10}',
        holderName: 'User $index',
        cvv: '${100 + index}',
      ),
    );
  }
  return cards;
}

int _countVisibleCards(WidgetTester tester) {
  final Size surfaceSize =
      tester.view.physicalSize / tester.view.devicePixelRatio;
  final Rect viewport = Offset.zero & surfaceSize;
  var visible = 0;

  for (final element in find.byType(BankCard).evaluate()) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      continue;
    }

    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    if (rect.overlaps(viewport)) {
      visible++;
    }
  }

  return visible;
}

Map<String, dynamic> _summarizeFrameTimings(List<FrameTiming> frameTimings) {
  if (frameTimings.isEmpty) {
    return const <String, dynamic>{
      'average_frame_build_time_millis': 0,
      'worst_frame_build_time_millis': 0,
      'average_frame_rasterizer_time_millis': 0,
      'worst_frame_rasterizer_time_millis': 0,
      'frame_count': 0,
    };
  }

  double averageMicros(Iterable<int> values) {
    var total = 0;
    var count = 0;
    for (final value in values) {
      total += value;
      count++;
    }
    if (count == 0) {
      return 0;
    }
    return total / count;
  }

  int maxMicros(Iterable<int> values) {
    var maxValue = 0;
    for (final value in values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue;
  }

  final buildMicros =
      frameTimings.map((timing) => timing.buildDuration.inMicroseconds);
  final rasterMicros = frameTimings.map(
    (timing) => timing.rasterDuration.inMicroseconds,
  );

  return <String, dynamic>{
    'average_frame_build_time_millis': averageMicros(buildMicros) / 1000.0,
    'worst_frame_build_time_millis': maxMicros(buildMicros) / 1000.0,
    'average_frame_rasterizer_time_millis':
        averageMicros(rasterMicros) / 1000.0,
    'worst_frame_rasterizer_time_millis': maxMicros(rasterMicros) / 1000.0,
    'frame_count': frameTimings.length,
  };
}

String _buildRuntimeMarkdown({
  required Map<String, dynamic> performanceSummary,
  required Map<String, dynamic> runtimeDiagnostics,
  required String targetLabel,
}) {
  final List<dynamic> slowestWidgets =
      (runtimeDiagnostics['slowest_widgets'] as List?) ?? const <dynamic>[];
  final List<dynamic> bankCardBuilds =
      (runtimeDiagnostics['bank_card_builds_by_card'] as List?) ??
          const <dynamic>[];
  final List<dynamic> scrollGestures =
      (runtimeDiagnostics['scroll_gestures'] as List?) ?? const <dynamic>[];
  final Map<String, dynamic> visibleSamples = Map<String, dynamic>.from(
    (runtimeDiagnostics['visible_card_samples'] as Map?) ??
        const <String, dynamic>{},
  );
  final List<String> suspectedBottlenecks = _suspectedBottlenecks(
    performanceSummary: performanceSummary,
    runtimeDiagnostics: runtimeDiagnostics,
  );

  final buffer = StringBuffer()
    ..writeln('# Performance Runtime Report')
    ..writeln()
    ..writeln(
      'Scope: instrumented runtime measurement of `HomeScreen` on $targetLabel with 12 seeded cards and a measured vertical scroll gesture.',
    )
    ..writeln()
    ..writeln('## Rebuild Counts')
    ..writeln()
    ..writeln(
      '- HomeScreen rebuild count: `${runtimeDiagnostics['home_screen_rebuild_count'] ?? 0}`',
    )
    ..writeln(
      '- Total instrumented widget rebuilds: `${runtimeDiagnostics['total_instrumented_widget_rebuilds'] ?? 0}`',
    )
    ..writeln(
      '- Total BankCard rebuilds: `${runtimeDiagnostics['bank_card_build_count_total'] ?? 0}`',
    )
    ..writeln(
      '- Average BankCard build duration: `${_microsToMillis(runtimeDiagnostics['bank_card_average_build_micros_overall'])} ms`',
    )
    ..writeln()
    ..writeln('## Frame Timing')
    ..writeln()
    ..writeln(
      '- Average frame time: `${_sumMillis(performanceSummary['average_frame_build_time_millis'], performanceSummary['average_frame_rasterizer_time_millis'])} ms`',
    )
    ..writeln(
      '- Worst frame time: `${_sumMillis(performanceSummary['worst_frame_build_time_millis'], performanceSummary['worst_frame_rasterizer_time_millis'])} ms`',
    )
    ..writeln(
      '- UI thread time: `${_formatMillis(performanceSummary['average_frame_build_time_millis'])} ms` avg, `${_formatMillis(performanceSummary['worst_frame_build_time_millis'])} ms` worst',
    )
    ..writeln(
      '- Raster time: `${_formatMillis(performanceSummary['average_frame_rasterizer_time_millis'])} ms` avg, `${_formatMillis(performanceSummary['worst_frame_rasterizer_time_millis'])} ms` worst',
    )
    ..writeln('- Frame count: `${performanceSummary['frame_count'] ?? 0}`')
    ..writeln()
    ..writeln('## Card Presence')
    ..writeln()
    ..writeln(
      '- Cards visible: `${visibleSamples['initial'] ?? 0}` initially, `${visibleSamples['after_scroll'] ?? 0}` after scroll',
    )
    ..writeln(
      '- Cards mounted: `${runtimeDiagnostics['active_card_widgets'] ?? 0}` current, `${runtimeDiagnostics['peak_active_card_widgets'] ?? 0}` peak',
    )
    ..writeln(
      '- Repaint events: `${runtimeDiagnostics['repaint_event_count'] ?? 0}`',
    )
    ..writeln()
    ..writeln('## Slowest Widgets')
    ..writeln();

  for (final entry in slowestWidgets.take(8)) {
    final row = Map<String, dynamic>.from(entry as Map);
    buffer.writeln(
      '- `${row['widget']}`: `${_microsToMillis(row['average_micros'])} ms` avg, `${_microsToMillis(row['max_micros'])} ms` max across `${row['count']}` samples',
    );
  }

  buffer
    ..writeln()
    ..writeln('## BankCard Rebuilds')
    ..writeln();

  for (final entry in bankCardBuilds.take(8)) {
    final row = Map<String, dynamic>.from(entry as Map);
    buffer.writeln(
      '- `${row['card_id']}`: `${row['build_count']}` builds, `${_microsToMillis(row['average_build_micros'])} ms` avg, `${_microsToMillis(row['max_build_micros'])} ms` max',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Scroll Gesture Metrics')
    ..writeln();

  for (final entry in scrollGestures) {
    final row = Map<String, dynamic>.from(entry as Map);
    buffer.writeln(
      '- Gesture `${row['id']}`: `${row['rebuild_delta']}` instrumented rebuilds, `${row['home_rebuild_delta']}` HomeScreen rebuilds, `${row['bank_card_build_delta']}` BankCard rebuilds, `${_microsToMillis(row['duration_micros'])} ms` duration, `${row['update_count']}` update notifications',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Suspected Bottlenecks')
    ..writeln();

  for (final item in suspectedBottlenecks) {
    buffer.writeln('- $item');
  }

  return buffer.toString();
}

List<String> _suspectedBottlenecks({
  required Map<String, dynamic> performanceSummary,
  required Map<String, dynamic> runtimeDiagnostics,
}) {
  final issues = <String>[];
  final scrollGestures =
      (runtimeDiagnostics['scroll_gestures'] as List?) ?? const <dynamic>[];
  final avgBuild =
      _asDouble(performanceSummary['average_frame_build_time_millis']);
  final avgRaster = _asDouble(
    performanceSummary['average_frame_rasterizer_time_millis'],
  );
  final peakMounted =
      (runtimeDiagnostics['peak_active_card_widgets'] ?? 0) as int;
  final visibleSamples = Map<String, dynamic>.from(
    (runtimeDiagnostics['visible_card_samples'] as Map?) ??
        const <String, dynamic>{},
  );

  if (scrollGestures.isNotEmpty) {
    final firstGesture = Map<String, dynamic>.from(scrollGestures.first as Map);
    final rebuildDelta = (firstGesture['rebuild_delta'] ?? 0) as int;
    final bankCardBuildDelta =
        (firstGesture['bank_card_build_delta'] ?? 0) as int;
    if (rebuildDelta > 20) {
      issues.add(
        'The measured scroll gesture triggered `$rebuildDelta` instrumented rebuilds, which points to broad rebuild propagation during scrolling.',
      );
    }
    if (bankCardBuildDelta > 8) {
      issues.add(
        'BankCard rebuilt `$bankCardBuildDelta` times during one scroll gesture, which is high for a list that should mostly reuse existing rows.',
      );
    }
  }

  if (avgRaster > avgBuild && avgRaster > 8) {
    issues.add(
      'Raster time is higher than UI build time, which suggests card painting and compositing are heavier than pure widget build work.',
    );
  }

  if (peakMounted > ((visibleSamples['initial'] ?? 0) as int) + 4) {
    issues.add(
      'Mounted card count stays well above visible card count, which supports the earlier finding that off-screen cards remain in the widget tree.',
    );
  }

  final paintStats = Map<String, dynamic>.from(
    (runtimeDiagnostics['paint_stats'] as Map?) ?? const <String, dynamic>{},
  );
  final cardVisualPaint = Map<String, dynamic>.from(
    (paintStats['CardVisualAssetLayer'] as Map?) ?? const <String, dynamic>{},
  );
  if ((cardVisualPaint['average_micros'] ?? 0) is num &&
      ((cardVisualPaint['average_micros'] ?? 0) as num) > 1000) {
    issues.add(
      'CardVisualAssetLayer paint time is elevated, which matches the layered SVG texture path called out in the static audit.',
    );
  }

  final svgResolveStats = Map<String, dynamic>.from(
    (runtimeDiagnostics['svg_resolve_stats'] as Map?) ??
        const <String, dynamic>{},
  );
  final bankLogoResolve = Map<String, dynamic>.from(
    (svgResolveStats['BankLogo'] as Map?) ?? const <String, dynamic>{},
  );
  if ((bankLogoResolve['average_micros'] ?? 0) is num &&
      ((bankLogoResolve['average_micros'] ?? 0) as num) > 200) {
    issues.add(
      'Bank logo asset resolution is doing measurable work during builds, so asset lookup is part of the hot path rather than a one-time setup step.',
    );
  }

  if (issues.isEmpty) {
    issues.add(
      'The measured run did not expose one dominant stall, but the rebuild and mounted-card counts still point to structural list cost as the main risk.',
    );
  }

  return issues;
}

String _formatMillis(Object? value) {
  final millis = _asDouble(value);
  return millis.toStringAsFixed(2);
}

String _sumMillis(Object? left, Object? right) {
  final total = _asDouble(left) + _asDouble(right);
  return total.toStringAsFixed(2);
}

String _microsToMillis(Object? value) {
  final micros = _asDouble(value);
  return (micros / 1000.0).toStringAsFixed(3);
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return 0;
}

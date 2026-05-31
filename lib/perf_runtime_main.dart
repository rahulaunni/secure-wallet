import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/local/hive_adapters.dart';
import 'data/local/hive_boxes.dart';
import 'diagnostics/performance_runtime_diagnostics.dart';
import 'diagnostics/performance_runtime_report_builder.dart';
import 'models/card_data.dart';
import 'models/card_network.dart';
import 'models/card_type.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  registerHiveAdapters();
  if (!Hive.isBoxOpen(HiveBoxes.cards)) {
    await Hive.openBox<CardData>(HiveBoxes.cards);
  }
  if (!Hive.isBoxOpen(HiveBoxes.settings)) {
    await Hive.openBox(HiveBoxes.settings);
  }

  await _seedDiagnosticsData();
  runApp(const _PerformanceRuntimeApp());
}

Future<void> _seedDiagnosticsData() async {
  final cardsBox = Hive.box<CardData>(HiveBoxes.cards);
  await cardsBox.clear();
  await cardsBox.addAll(_buildCards());

  final settingsBox = Hive.box(HiveBoxes.settings);
  await settingsBox.put('use_biometrics', false);
  await settingsBox.put('swipe_actions_tutorial_v1_seen', true);
  await settingsBox.put('is_dark', true);
}

class _PerformanceRuntimeApp extends StatelessWidget {
  const _PerformanceRuntimeApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _PerformanceRuntimeScreen(),
    );
  }
}

class _PerformanceRuntimeScreen extends StatefulWidget {
  const _PerformanceRuntimeScreen();

  @override
  State<_PerformanceRuntimeScreen> createState() =>
      _PerformanceRuntimeScreenState();
}

class _PerformanceRuntimeScreenState extends State<_PerformanceRuntimeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<FrameTiming> _frameTimings = <FrameTiming>[];
  final PerformanceRuntimeDiagnostics _diagnostics =
      PerformanceRuntimeDiagnostics.instance;

  bool _scenarioStarted = false;
  bool _reportReady = false;
  String _reportMarkdown = 'Running diagnostics...';

  @override
  void initState() {
    super.initState();
    _diagnostics.reset();
    WidgetsBinding.instance.addTimingsCallback(_handleFrameTimings);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScenario();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_handleFrameTimings);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleFrameTimings(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);
  }

  Future<void> _startScenario() async {
    if (_scenarioStarted) {
      return;
    }
    _scenarioStarted = true;

    await Future<void>.delayed(const Duration(milliseconds: 900));
    _diagnostics.sampleVisibleCards('initial');

    if (_scrollController.hasClients) {
      final targetOffset =
          (_scrollController.position.maxScrollExtent * 0.42).clamp(0, 640);
      await _scrollController.animateTo(
        targetOffset.toDouble(),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeInOutCubic,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    _diagnostics.sampleVisibleCards('after_scroll');
    WidgetsBinding.instance.removeTimingsCallback(_handleFrameTimings);

    final performanceSummary = summarizeFrameTimings(_frameTimings);
    final runtimeDiagnostics = _diagnostics.snapshot();
    final markdown = buildRuntimeMarkdown(
      performanceSummary: performanceSummary,
      runtimeDiagnostics: runtimeDiagnostics,
      targetLabel: kIsWeb ? 'Chrome runtime harness' : 'runtime harness',
    );

    final payload = <String, dynamic>{
      'performance_summary': performanceSummary,
      'runtime_diagnostics': runtimeDiagnostics,
      'runtime_markdown': markdown,
    };

    debugPrintSynchronously('PERF_RUNTIME_JSON_START');
    debugPrintSynchronously(jsonEncode(payload));
    debugPrintSynchronously('PERF_RUNTIME_JSON_END');

    if (!mounted) {
      return;
    }

    setState(() {
      _reportMarkdown = markdown;
      _reportReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HomeScreen(
          isDark: true,
          onThemeChanged: (_) {},
          unlockSettleAnimation: const AlwaysStoppedAnimation<double>(1),
          diagnosticsScrollController: _scrollController,
        ),
        if (_reportReady)
          Positioned(
            right: 12,
            bottom: 12,
            child: SizedBox(
              width: 320,
              height: 280,
              child: Material(
                color: const Color(0xEE101827),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _reportMarkdown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
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

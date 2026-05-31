import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'constants/layout_constants.dart';
import 'debug/visual_cost_flags.dart';
import 'models/card_data.dart';
import 'models/card_network.dart';
import 'models/card_type.dart';
import 'utils/app_startup_preloader.dart';
import 'widgets/card/bank_card.dart';
import 'widgets/card/secure_reveal_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _VisualCostExperimentApp());
}

class _ExperimentCardSpec {
  final String bankCid;
  final CardNetwork network;
  final String cardType;
  final String cardNumber;
  final String expiry;
  final String holderName;

  const _ExperimentCardSpec({
    required this.bankCid,
    required this.network,
    required this.cardType,
    required this.cardNumber,
    required this.expiry,
    required this.holderName,
  });
}

class _VisualCostExperimentApp extends StatelessWidget {
  const _VisualCostExperimentApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const _VisualCostExperimentScreen(),
    );
  }
}

class _VisualCostExperimentScreen extends StatefulWidget {
  const _VisualCostExperimentScreen();

  @override
  State<_VisualCostExperimentScreen> createState() =>
      _VisualCostExperimentScreenState();
}

class _VisualCostExperimentScreenState
    extends State<_VisualCostExperimentScreen> {
  static const double _cardWidth = 358;
  static const double _horizontalPadding = 16;
  static const Duration _prewarmDelay = Duration(milliseconds: 1400);
  static const Duration _settleDelay = Duration(milliseconds: 300);
  static const Duration _scrollDuration = Duration(milliseconds: 2800);

  final ScrollController _scrollController = ScrollController();
  final List<FrameTiming> _timings = <FrameTiming>[];
  late final List<_ExperimentCardSpec> _cards;
  bool _collecting = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _cards = const [
      _ExperimentCardSpec(
        bankCid: 'hdfc',
        network: CardNetwork.visa,
        cardType: 'Credit',
        cardNumber: '5550054088065454',
        expiry: '08/29',
        holderName: 'NIDIN JOSE',
      ),
      _ExperimentCardSpec(
        bankCid: 'icici',
        network: CardNetwork.mastercard,
        cardType: 'Debit',
        cardNumber: '5184112245679081',
        expiry: '01/30',
        holderName: 'ARJUN MENON',
      ),
      _ExperimentCardSpec(
        bankCid: 'axis',
        network: CardNetwork.rupay,
        cardType: 'Credit',
        cardNumber: '6521789087012345',
        expiry: '11/31',
        holderName: 'MAYA PILLAI',
      ),
      _ExperimentCardSpec(
        bankCid: 'federal',
        network: CardNetwork.amex,
        cardType: 'Debit',
        cardNumber: '377812345678901',
        expiry: '04/30',
        holderName: 'RIYA DAS',
      ),
      _ExperimentCardSpec(
        bankCid: 'kotak',
        network: CardNetwork.visa,
        cardType: 'Credit',
        cardNumber: '4123456789012345',
        expiry: '02/31',
        holderName: 'DEV SHARMA',
      ),
      _ExperimentCardSpec(
        bankCid: 'sbi',
        network: CardNetwork.mastercard,
        cardType: 'Debit',
        cardNumber: '5105105105105100',
        expiry: '09/28',
        holderName: 'ANU K NAIR',
      ),
      _ExperimentCardSpec(
        bankCid: 'bank_of_baroda',
        network: CardNetwork.rupay,
        cardType: 'Credit',
        cardNumber: '6078563412457845',
        expiry: '12/30',
        holderName: 'ROHAN IYER',
      ),
      _ExperimentCardSpec(
        bankCid: 'canara',
        network: CardNetwork.visa,
        cardType: 'Debit',
        cardNumber: '4556737586899855',
        expiry: '07/29',
        holderName: 'PRIYA R',
      ),
      _ExperimentCardSpec(
        bankCid: 'yes',
        network: CardNetwork.mastercard,
        cardType: 'Credit',
        cardNumber: '5454545454545454',
        expiry: '10/31',
        holderName: 'SANA KHAN',
      ),
      _ExperimentCardSpec(
        bankCid: 'idfc',
        network: CardNetwork.visa,
        cardType: 'Debit',
        cardNumber: '4012888888881881',
        expiry: '06/30',
        holderName: 'KIRAN PAUL',
      ),
      _ExperimentCardSpec(
        bankCid: 'standard_chartered',
        network: CardNetwork.amex,
        cardType: 'Credit',
        cardNumber: '378282246310005',
        expiry: '05/29',
        holderName: 'HARISH KUMAR',
      ),
      _ExperimentCardSpec(
        bankCid: 'union',
        network: CardNetwork.rupay,
        cardType: 'Debit',
        cardNumber: '6069853456712345',
        expiry: '03/30',
        holderName: 'MEERA S',
      ),
    ];
    WidgetsBinding.instance.addTimingsCallback(_handleTimings);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runExperiment());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_handleTimings);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTimings(List<FrameTiming> timings) {
    if (!_collecting) {
      return;
    }
    _timings.addAll(timings);
  }

  Future<void> _runExperiment() async {
    if (!mounted || _finished) {
      return;
    }

    final cardDataForWarmup = _cards
        .map(_WarmCardData.fromSpec)
        .toList(growable: false);

    AppStartupPreloader.scheduleCardWarmUp(
      context,
      cardDataForWarmup,
      cardWidth: _cardWidth,
    );

    await Future<void>.delayed(_prewarmDelay);
    if (!mounted) {
      return;
    }

    _timings.clear();
    _collecting = true;
    await Future<void>.delayed(_settleDelay);
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    await _scrollController.animateTo(
      maxScrollExtent,
      duration: _scrollDuration,
      curve: Curves.linear,
    );

    await Future<void>.delayed(_settleDelay);
    _collecting = false;
    _finished = true;

    final metrics = _buildMetrics();
    // ignore: avoid_print
    print('VISUAL_COST_RESULT:${jsonEncode(metrics)}');
    await SystemNavigator.pop();
  }

  Map<String, Object?> _buildMetrics() {
    final frames = _timings;
    if (frames.isEmpty) {
      return <String, Object?>{
        'experiment': kVisualCostExperimentName,
        'frames': 0,
        'avg_frame_ms': 0,
        'worst_frame_ms': 0,
        'avg_raster_ms': 0,
        'worst_raster_ms': 0,
        'avg_build_ms': 0,
        'worst_build_ms': 0,
        'smoothness_60hz': 0,
        'smoothness_120hz': 0,
      };
    }

    double totalFrameMs = 0;
    double totalRasterMs = 0;
    double totalBuildMs = 0;
    double worstFrameMs = 0;
    double worstRasterMs = 0;
    double worstBuildMs = 0;
    int over60Budget = 0;
    int over120Budget = 0;

    for (final timing in frames) {
      final frameMs = timing.totalSpan.inMicroseconds / 1000.0;
      final rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;
      final buildMs = timing.buildDuration.inMicroseconds / 1000.0;

      totalFrameMs += frameMs;
      totalRasterMs += rasterMs;
      totalBuildMs += buildMs;
      worstFrameMs = math.max(worstFrameMs, frameMs);
      worstRasterMs = math.max(worstRasterMs, rasterMs);
      worstBuildMs = math.max(worstBuildMs, buildMs);

      if (frameMs > 16.67) {
        over60Budget++;
      }
      if (frameMs > 8.33) {
        over120Budget++;
      }
    }

    final frameCount = frames.length;
    final smooth60 = ((frameCount - over60Budget) / frameCount) * 100;
    final smooth120 = ((frameCount - over120Budget) / frameCount) * 100;

    return <String, Object?>{
      'experiment': kVisualCostExperimentName,
      'frames': frameCount,
      'avg_frame_ms': totalFrameMs / frameCount,
      'worst_frame_ms': worstFrameMs,
      'avg_raster_ms': totalRasterMs / frameCount,
      'worst_raster_ms': worstRasterMs,
      'avg_build_ms': totalBuildMs / frameCount,
      'worst_build_ms': worstBuildMs,
      'smoothness_60hz': smooth60,
      'smoothness_120hz': smooth120,
      'flags': <String, bool>{
        'disable_grain': kDisableGrainPainter,
        'disable_pattern_layers': kDisablePatternLayers,
        'disable_shader_mask': kDisableShaderMask,
        'disable_card_shadow': kDisableCardShadow,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: SafeArea(
        child: ListView.builder(
          controller: _scrollController,
          cacheExtent: 2500,
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            24,
            _horizontalPadding,
            120,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: bankCardVerticalSpacing),
              child: BankCardScope(
                revealed: false,
                cvvVisible: false,
                onToggleCvv: () {},
                child: BankCard(
                  bankLogo: card.bankCid,
                  networkLogo: card.network.assetPath,
                  cardType: card.cardType,
                  cardNumber: card.cardNumber,
                  validThru: card.expiry,
                  holderName: card.holderName,
                  cvv: '123',
                  showActions: true,
                  onEyeTap: () {},
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WarmCardData {
  static CardData fromSpec(_ExperimentCardSpec spec) {
    return CardData(
      bankCid: spec.bankCid,
      cardNetwork: spec.network,
      cardType: spec.cardType == 'Credit' ? CardType.credit : CardType.debit,
      cardNumber: spec.cardNumber,
      expiry: spec.expiry,
      holderName: spec.holderName,
      cvv: '123',
    );
  }
}

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PerformanceRuntimeDiagnostics {
  PerformanceRuntimeDiagnostics._();

  static final PerformanceRuntimeDiagnostics instance =
      PerformanceRuntimeDiagnostics._();

  bool enabled = true;

  int homeScreenRebuildCount = 0;
  int totalInstrumentedWidgetRebuilds = 0;
  int repaintEventCount = 0;
  int activeCardWidgets = 0;
  int peakActiveCardWidgets = 0;

  final Set<String> _mountedCardIds = <String>{};
  final Map<String, BuildContext> _cardContexts = <String, BuildContext>{};
  final Map<String, int> _bankCardBuildCounts = <String, int>{};
  final Map<String, int> _bankCardBuildMicrosTotal = <String, int>{};
  final Map<String, int> _bankCardBuildMicrosMax = <String, int>{};
  final Map<String, _MetricBucket> _widgetBuildStats =
      <String, _MetricBucket>{};
  final Map<String, _MetricBucket> _paintStats = <String, _MetricBucket>{};
  final Map<String, _MetricBucket> _svgResolveStats = <String, _MetricBucket>{};
  final List<_ScrollGestureRecord> _completedScrollGestures =
      <_ScrollGestureRecord>[];
  final Map<String, int> _visibleCardSamples = <String, int>{};

  _ScrollGestureSession? _activeScrollGesture;
  int _scrollGestureSequence = 0;

  void reset() {
    homeScreenRebuildCount = 0;
    totalInstrumentedWidgetRebuilds = 0;
    repaintEventCount = 0;
    activeCardWidgets = 0;
    peakActiveCardWidgets = 0;
    _mountedCardIds.clear();
    _cardContexts.clear();
    _bankCardBuildCounts.clear();
    _bankCardBuildMicrosTotal.clear();
    _bankCardBuildMicrosMax.clear();
    _widgetBuildStats.clear();
    _paintStats.clear();
    _svgResolveStats.clear();
    _completedScrollGestures.clear();
    _visibleCardSamples.clear();
    _activeScrollGesture = null;
    _scrollGestureSequence = 0;
  }

  void recordHomeScreenBuild(int micros) {
    if (!enabled) return;
    homeScreenRebuildCount++;
    _recordWidgetBuild('HomeScreen', micros);
  }

  void recordBankCardBuild(String cardId, int micros) {
    if (!enabled) return;
    _recordWidgetBuild('BankCard', micros);
    _bankCardBuildCounts.update(cardId, (value) => value + 1,
        ifAbsent: () => 1);
    _bankCardBuildMicrosTotal.update(
      cardId,
      (value) => value + micros,
      ifAbsent: () => micros,
    );
    final previousMax = _bankCardBuildMicrosMax[cardId] ?? 0;
    if (micros > previousMax) {
      _bankCardBuildMicrosMax[cardId] = micros;
    }
  }

  void recordSecureRevealBuild(int micros) {
    if (!enabled) return;
    _recordWidgetBuild('SecureRevealWrapper', micros);
  }

  void recordCardVisualBuild(int micros) {
    if (!enabled) return;
    _recordWidgetBuild('CardVisualAssetLayer', micros);
  }

  void recordBankLogoBuild(int micros) {
    if (!enabled) return;
    _recordWidgetBuild('BankLogo', micros);
  }

  void recordSvgResolve(String label, int micros) {
    if (!enabled) return;
    _svgResolveStats.putIfAbsent(label, _MetricBucket.new).record(micros);
  }

  void recordPaint(String label, int micros) {
    if (!enabled) return;
    repaintEventCount++;
    _paintStats.putIfAbsent(label, _MetricBucket.new).record(micros);
  }

  void cardMounted(String cardId) {
    if (!enabled) return;
    _mountedCardIds.add(cardId);
    activeCardWidgets = _mountedCardIds.length;
    if (activeCardWidgets > peakActiveCardWidgets) {
      peakActiveCardWidgets = activeCardWidgets;
    }
  }

  void cardUnmounted(String cardId) {
    if (!enabled) return;
    _mountedCardIds.remove(cardId);
    _cardContexts.remove(cardId);
    activeCardWidgets = _mountedCardIds.length;
  }

  void recordVisibleCardsSample(String label, int count) {
    if (!enabled) return;
    _visibleCardSamples[label] = count;
  }

  void updateCardContext(String cardId, BuildContext context) {
    if (!enabled) return;
    _cardContexts[cardId] = context;
  }

  void sampleVisibleCards(String label) {
    if (!enabled) return;

    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) {
      _visibleCardSamples[label] = 0;
      return;
    }

    final primaryView = views.first;
    final viewport =
        Offset.zero & (primaryView.physicalSize / primaryView.devicePixelRatio);

    var visibleCount = 0;
    for (final entry in _cardContexts.entries) {
      final renderObject = entry.value.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) {
        continue;
      }
      if (!renderObject.hasSize) {
        continue;
      }

      final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      if (rect.overlaps(viewport)) {
        visibleCount++;
      }
    }

    _visibleCardSamples[label] = visibleCount;
  }

  void handleScrollNotification(ScrollNotification notification) {
    if (!enabled || notification.metrics.axis != Axis.vertical) {
      return;
    }

    if (notification is ScrollStartNotification) {
      _activeScrollGesture ??= _ScrollGestureSession(
        id: ++_scrollGestureSequence,
        startedAt: DateTime.now(),
        rebuildBaseline: totalInstrumentedWidgetRebuilds,
        homeRebuildBaseline: homeScreenRebuildCount,
        bankCardBuildBaseline: _sumCounts(_bankCardBuildCounts.values),
      );
      return;
    }

    if (notification is ScrollUpdateNotification) {
      _activeScrollGesture?.updateCount++;
      return;
    }

    if (notification is ScrollEndNotification) {
      final session = _activeScrollGesture;
      if (session == null) {
        return;
      }

      _completedScrollGestures.add(
        _ScrollGestureRecord(
          id: session.id,
          durationMicros:
              DateTime.now().difference(session.startedAt).inMicroseconds,
          rebuildDelta:
              totalInstrumentedWidgetRebuilds - session.rebuildBaseline,
          homeRebuildDelta:
              homeScreenRebuildCount - session.homeRebuildBaseline,
          bankCardBuildDelta: _sumCounts(_bankCardBuildCounts.values) -
              session.bankCardBuildBaseline,
          updateCount: session.updateCount,
        ),
      );
      _activeScrollGesture = null;
    }
  }

  Map<String, dynamic> snapshot() {
    final bankCardAverageMicros = _averageMicrosForMap(
      _bankCardBuildCounts,
      _bankCardBuildMicrosTotal,
    );

    final bankCardBuilds = _bankCardBuildCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final slowestWidgets = <Map<String, dynamic>>[
      ..._widgetBuildStats.entries.map((entry) {
        final value = entry.value;
        return <String, dynamic>{
          'widget': entry.key,
          'count': value.count,
          'average_micros': value.averageMicros,
          'max_micros': value.maxMicros,
          'total_micros': value.totalMicros,
        };
      }),
      ..._paintStats.entries.map((entry) {
        final value = entry.value;
        return <String, dynamic>{
          'widget': '${entry.key} paint',
          'count': value.count,
          'average_micros': value.averageMicros,
          'max_micros': value.maxMicros,
          'total_micros': value.totalMicros,
        };
      }),
      ..._svgResolveStats.entries.map((entry) {
        final value = entry.value;
        return <String, dynamic>{
          'widget': '${entry.key} svg resolve',
          'count': value.count,
          'average_micros': value.averageMicros,
          'max_micros': value.maxMicros,
          'total_micros': value.totalMicros,
        };
      }),
    ]..sort((a, b) {
        final int left = (a['average_micros'] as num).round();
        final int right = (b['average_micros'] as num).round();
        return right.compareTo(left);
      });

    return <String, dynamic>{
      'home_screen_rebuild_count': homeScreenRebuildCount,
      'total_instrumented_widget_rebuilds': totalInstrumentedWidgetRebuilds,
      'bank_card_build_count_total': _sumCounts(_bankCardBuildCounts.values),
      'bank_card_average_build_micros_overall': _overallAverageMicros(
          _bankCardBuildCounts, _bankCardBuildMicrosTotal),
      'bank_card_builds_by_card': bankCardBuilds.take(20).map((entry) {
        return <String, dynamic>{
          'card_id': entry.key,
          'build_count': entry.value,
          'average_build_micros': bankCardAverageMicros[entry.key] ?? 0,
          'max_build_micros': _bankCardBuildMicrosMax[entry.key] ?? 0,
        };
      }).toList(),
      'active_card_widgets': activeCardWidgets,
      'peak_active_card_widgets': peakActiveCardWidgets,
      'mounted_card_ids': _mountedCardIds.toList()..sort(),
      'repaint_event_count': repaintEventCount,
      'widget_build_stats': _metricMap(_widgetBuildStats),
      'paint_stats': _metricMap(_paintStats),
      'svg_resolve_stats': _metricMap(_svgResolveStats),
      'scroll_gestures': _completedScrollGestures.map((entry) {
        return entry.toJson();
      }).toList(),
      'visible_card_samples': Map<String, int>.from(_visibleCardSamples),
      'slowest_widgets': slowestWidgets.take(12).toList(),
    };
  }

  void _recordWidgetBuild(String label, int micros) {
    totalInstrumentedWidgetRebuilds++;
    _widgetBuildStats.putIfAbsent(label, _MetricBucket.new).record(micros);
  }

  Map<String, Map<String, num>> _metricMap(Map<String, _MetricBucket> source) {
    final result = <String, Map<String, num>>{};
    for (final entry in source.entries) {
      result[entry.key] = <String, num>{
        'count': entry.value.count,
        'average_micros': entry.value.averageMicros,
        'max_micros': entry.value.maxMicros,
        'total_micros': entry.value.totalMicros,
      };
    }
    return result;
  }

  Map<String, int> _averageMicrosForMap(
    Map<String, int> counts,
    Map<String, int> totals,
  ) {
    final result = <String, int>{};
    for (final entry in counts.entries) {
      final total = totals[entry.key] ?? 0;
      result[entry.key] = entry.value == 0 ? 0 : total ~/ entry.value;
    }
    return result;
  }

  int _overallAverageMicros(
    Map<String, int> counts,
    Map<String, int> totals,
  ) {
    final totalCount = _sumCounts(counts.values);
    if (totalCount == 0) {
      return 0;
    }

    final totalMicros = _sumCounts(totals.values);
    return totalMicros ~/ totalCount;
  }

  int _sumCounts(Iterable<int> values) {
    var total = 0;
    for (final value in values) {
      total += value;
    }
    return total;
  }
}

class PerformancePaintProbe extends SingleChildRenderObjectWidget {
  final String label;

  const PerformancePaintProbe({
    super.key,
    required this.label,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _PerformancePaintProbeRenderObject(label);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final typedRenderObject =
        renderObject as _PerformancePaintProbeRenderObject;
    typedRenderObject.label = label;
  }
}

class _PerformancePaintProbeRenderObject extends RenderProxyBox {
  _PerformancePaintProbeRenderObject(this.label);

  String label;

  @override
  void paint(PaintingContext context, Offset offset) {
    final stopwatch = Stopwatch()..start();
    super.paint(context, offset);
    stopwatch.stop();
    PerformanceRuntimeDiagnostics.instance.recordPaint(
      label,
      stopwatch.elapsedMicroseconds,
    );
  }
}

class PerformanceCardMountTracker extends StatefulWidget {
  final String cardId;
  final Widget child;

  const PerformanceCardMountTracker({
    super.key,
    required this.cardId,
    required this.child,
  });

  @override
  State<PerformanceCardMountTracker> createState() =>
      _PerformanceCardMountTrackerState();
}

class _PerformanceCardMountTrackerState
    extends State<PerformanceCardMountTracker> {
  @override
  void initState() {
    super.initState();
    PerformanceRuntimeDiagnostics.instance.cardMounted(widget.cardId);
  }

  @override
  void didUpdateWidget(covariant PerformanceCardMountTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cardId == widget.cardId) {
      return;
    }

    PerformanceRuntimeDiagnostics.instance.cardUnmounted(oldWidget.cardId);
    PerformanceRuntimeDiagnostics.instance.cardMounted(widget.cardId);
  }

  @override
  void dispose() {
    PerformanceRuntimeDiagnostics.instance.cardUnmounted(widget.cardId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PerformanceRuntimeDiagnostics.instance.updateCardContext(
      widget.cardId,
      context,
    );
    return widget.child;
  }
}

class _MetricBucket {
  int count = 0;
  int totalMicros = 0;
  int maxMicros = 0;

  void record(int micros) {
    count++;
    totalMicros += micros;
    if (micros > maxMicros) {
      maxMicros = micros;
    }
  }

  int get averageMicros => count == 0 ? 0 : totalMicros ~/ count;
}

class _ScrollGestureSession {
  final int id;
  final DateTime startedAt;
  final int rebuildBaseline;
  final int homeRebuildBaseline;
  final int bankCardBuildBaseline;
  int updateCount = 0;

  _ScrollGestureSession({
    required this.id,
    required this.startedAt,
    required this.rebuildBaseline,
    required this.homeRebuildBaseline,
    required this.bankCardBuildBaseline,
  });
}

class _ScrollGestureRecord {
  final int id;
  final int durationMicros;
  final int rebuildDelta;
  final int homeRebuildDelta;
  final int bankCardBuildDelta;
  final int updateCount;

  const _ScrollGestureRecord({
    required this.id,
    required this.durationMicros,
    required this.rebuildDelta,
    required this.homeRebuildDelta,
    required this.bankCardBuildDelta,
    required this.updateCount,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'duration_micros': durationMicros,
      'rebuild_delta': rebuildDelta,
      'home_rebuild_delta': homeRebuildDelta,
      'bank_card_build_delta': bankCardBuildDelta,
      'update_count': updateCount,
    };
  }
}

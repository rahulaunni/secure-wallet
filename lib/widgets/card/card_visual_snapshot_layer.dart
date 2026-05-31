import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../debug/visual_cost_flags.dart';
import '../../models/card_data.dart';
import '../../utils/card_snapshot_service.dart';

class CardVisualSnapshotLayer extends StatefulWidget {
  final CardData card;
  final double logicalWidth;
  final BorderRadius borderRadius;
  final Widget liveVisual;

  const CardVisualSnapshotLayer({
    super.key,
    required this.card,
    required this.logicalWidth,
    required this.borderRadius,
    required this.liveVisual,
  });

  @override
  State<CardVisualSnapshotLayer> createState() =>
      _CardVisualSnapshotLayerState();
}

class _CardVisualSnapshotLayerState extends State<CardVisualSnapshotLayer> {
  static const Duration _captureRetryDelay = Duration(milliseconds: 350);

  final GlobalKey _boundaryKey = GlobalKey();
  bool _captureScheduled = false;
  String? _resolvedSnapshotPath;
  String? _resolvedSnapshotSignature;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _syncResolvedSnapshotFromCard();
  }

  @override
  void didUpdateWidget(covariant CardVisualSnapshotLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.normalSnapshotSignature !=
            widget.card.normalSnapshotSignature ||
        oldWidget.card.normalSnapshotPath != widget.card.normalSnapshotPath ||
        oldWidget.logicalWidth != widget.logicalWidth) {
      _cancelRetry();
      _captureScheduled = false;
      _syncResolvedSnapshotFromCard();
    }
  }

  @override
  void dispose() {
    _cancelRetry();
    super.dispose();
  }

  void _syncResolvedSnapshotFromCard() {
    final currentPath = CardSnapshotService.currentSnapshotPath(widget.card);
    _resolvedSnapshotPath = currentPath;
    _resolvedSnapshotSignature = currentPath == null
        ? null
        : CardSnapshotService.visualSignature(widget.card);
  }

  String? _effectiveSnapshotPath() {
    final currentSignature = CardSnapshotService.visualSignature(widget.card);
    final localPath = _resolvedSnapshotPath;
    if (_resolvedSnapshotSignature == currentSignature &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      return localPath;
    }

    return CardSnapshotService.currentSnapshotPath(widget.card);
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _scheduleRetryIfNeeded() {
    if (!mounted || _effectiveSnapshotPath() != null || _retryTimer != null) {
      return;
    }

    _retryTimer = Timer(_captureRetryDelay, () {
      _retryTimer = null;
      if (!mounted || _effectiveSnapshotPath() != null) {
        return;
      }
      setState(() {
        _captureScheduled = false;
      });
    });
  }

  void _scheduleCaptureIfNeeded() {
    if (_captureScheduled || _effectiveSnapshotPath() != null) {
      return;
    }

    _cancelRetry();
    _captureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final generatedCard = await CardSnapshotService.captureSnapshotForCard(
        context: context,
        card: widget.card,
        boundaryKey: _boundaryKey,
        persistToRepository: true,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        if (generatedCard != null) {
          _resolvedSnapshotPath = generatedCard.normalSnapshotPath;
          _resolvedSnapshotSignature = generatedCard.normalSnapshotSignature;
        }
        _captureScheduled = false;
      });

      if (generatedCard == null) {
        _scheduleRetryIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshotPath = _effectiveSnapshotPath();
    const showDebug = kShowCardSnapshotDebug;
    if (snapshotPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: widget.borderRadius,
            child: Image.file(
              File(snapshotPath),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) {
                _captureScheduled = false;
                return RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.liveVisual,
                );
              },
            ),
          ),
          if (showDebug)
            const _CardSnapshotDebugBadge(
              label: 'SNAPSHOT PNG',
              backgroundColor: Color(0xCC166534),
            ),
        ],
      );
    }

    _scheduleCaptureIfNeeded();
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: widget.liveVisual,
        ),
        if (showDebug)
          _CardSnapshotDebugBadge(
            label: _captureScheduled ? 'LIVE VISUAL / CAPTURING' : 'LIVE VISUAL',
            backgroundColor: const Color(0xCCB45309),
          ),
      ],
    );
  }
}

class _CardSnapshotDebugBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const _CardSnapshotDebugBadge({
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

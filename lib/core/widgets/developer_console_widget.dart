// lib/core/widgets/developer_console_widget.dart
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/in_memory_log_output.dart';

// ── LAYER 4b & 4c: Developer Diagnostics Panel + System Trigger ──────────────
//
// DiagnosticsOverlay  — Root-level wrapper widget. Renders the normal child
//                        always; overlays DeveloperConsoleWidget when toggled.
//                        The overlay is compiled out in release builds.
//
// DeveloperConsoleWidget — The actual panel UI with:
//   • Live memory counter (ProcessInfo.currentRss, 1-second ticker)
//   • Performance Overlay toggle (GPU + UI thread frame bars)
//   • Scrollable terminal log console (InMemoryLogOutput stream)
//   • Clear button for the log buffer
//
// Trigger mechanism — A 5-tap gesture detector on the greeting section of the
// Hirer Dashboard header text fires the show/hide toggle. Implemented in
// hirer_dashboard_screen.dart to keep this file widget-only.
// ─────────────────────────────────────────────────────────────────────────────

/// Global notifier for the diagnostics panel visibility.
/// ValueNotifier is intentionally NOT a Riverpod provider — the diagnostics
/// layer must be independent of the app's state management graph.
final diagnosticsVisible = ValueNotifier<bool>(false);

/// Global notifier for the PerformanceOverlay state.
final performanceOverlayEnabled = ValueNotifier<bool>(false);

// ─────────────────────────────────────────────────────────────────────────────

/// Root wrapper that conditionally layers [DeveloperConsoleWidget] over [child].
/// In release builds the overlay is never compiled into the widget tree.
class DiagnosticsOverlay extends StatelessWidget {
  const DiagnosticsOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Release builds: pass through transparently — zero overhead.
    if (kReleaseMode) return child;

    // DiagnosticsOverlay is mounted ABOVE MaterialApp in the widget tree, so
    // there is no Directionality or Material ancestor available for the overlay
    // panel's Text / Icon widgets.
    //
    // Fix: Wrap in Directionality(ltr) so text direction is always resolved,
    // and Material(transparency) so the ink / theme layer exists without
    // overriding the child's own MaterialApp theming.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        type: MaterialType.transparency,
        child: ValueListenableBuilder<bool>(
          valueListenable: diagnosticsVisible,
          builder: (context, visible, _) {
            return Stack(
              children: [
                child,
                if (visible)
                  const Positioned.fill(
                    child: DeveloperConsoleWidget(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// The high-fidelity diagnostics panel widget.
class DeveloperConsoleWidget extends StatefulWidget {
  const DeveloperConsoleWidget({super.key});

  @override
  State<DeveloperConsoleWidget> createState() => _DeveloperConsoleWidgetState();
}

class _DeveloperConsoleWidgetState extends State<DeveloperConsoleWidget> {
  late Timer _memoryTimer;
  double _memoryMb = 0.0;
  List<String> _logLines = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<String>>? _logSub;

  @override
  void initState() {
    super.initState();

    // ── Memory polling — 1-second periodic timer ──────────────────────────
    // ProcessInfo.currentRss returns the Resident Set Size in bytes.
    // We convert to MB for readability.
    _updateMemory();
    _memoryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateMemory();
    });

    // ── Log stream subscription ───────────────────────────────────────────
    // Seed with what's already in the buffer, then listen for new entries.
    _logLines = List.from(InMemoryLogOutput.instance.lines);
    _logSub = InMemoryLogOutput.instance.stream.listen((lines) {
      if (mounted) {
        setState(() => _logLines = lines);
        // Auto-scroll to bottom on new entries.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    // Emit a timeline event so opening the panel is visible in DevTools.
    developer.Timeline.startSync('DiagnosticsPanel_Open');
    developer.Timeline.finishSync();
  }

  void _updateMemory() {
    final rss = ProcessInfo.currentRss;
    setState(() => _memoryMb = rss / (1024 * 1024));
  }

  @override
  void dispose() {
    _memoryTimer.cancel();
    _logSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xF0050A14), // near-opaque dark navy
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FF99), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF99).withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildMetricsRow(),
                const Divider(color: Color(0xFF1A2A1A), height: 1),
                _buildPerfOverlayToggle(),
                const Divider(color: Color(0xFF1A2A1A), height: 1),
                _buildLogConsole(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.bug_report_rounded, color: Color(0xFF00FF99), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'AmanGhar  |  Developer Diagnostics',
              style: TextStyle(
                color: Color(0xFF00FF99),
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => diagnosticsVisible.value = false,
            child: const Icon(Icons.close_rounded, color: Color(0xFF00FF99), size: 18),
          ),
        ],
      ),
    );
  }

  // ── Metrics row ─────────────────────────────────────────────────────────────
  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _MetricChip(
            icon: Icons.memory_rounded,
            label: 'RSS Memory',
            value: '${_memoryMb.toStringAsFixed(2)} MB',
            color: _memoryMb > 256
                ? const Color(0xFFFF4444)
                : const Color(0xFF00FF99),
          ),
          const SizedBox(width: 10),
          const _MetricChip(
            icon: Icons.account_tree_rounded,
            label: 'Build',
            value: kDebugMode
                ? 'DEBUG'
                : kProfileMode
                    ? 'PROFILE'
                    : 'RELEASE',
            color: kDebugMode
                ? Color(0xFFFFAA00)
                : Color(0xFF00AAFF),
          ),
          const SizedBox(width: 10),
          _MetricChip(
            icon: Icons.storage_rounded,
            label: 'Log Buffer',
            value: '${_logLines.length}/100',
            color: const Color(0xFF9966FF),
          ),
        ],
      ),
    );
  }

  // ── Performance Overlay toggle ───────────────────────────────────────────────
  Widget _buildPerfOverlayToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: performanceOverlayEnabled,
      builder: (_, enabled, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFFFFAA00), size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'GPU / UI Thread Performance Overlay',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => performanceOverlayEnabled.value = v,
                activeThumbColor: const Color(0xFFFFAA00),
                inactiveTrackColor: const Color(0xFF2A2A2A),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Log terminal console ─────────────────────────────────────────────────────
  Widget _buildLogConsole() {
    return Container(
      height: 220,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF020810),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A3A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Console toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded,
                    color: Color(0xFF00FF99), size: 13),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'SYSTEM LOG',
                    style: TextStyle(
                      color: Color(0xFF00FF99),
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    InMemoryLogOutput.instance.clear();
                    setState(() => _logLines = []);
                  },
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(
                      color: Color(0xFFFF4444),
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1A3A2A), height: 1),
          // Scrollable log entries
          Expanded(
            child: _logLines.isEmpty
                ? const Center(
                    child: Text(
                      'No log entries yet.\nTrigger app actions to populate.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF3A5A3A),
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    itemCount: _logLines.length,
                    itemBuilder: (_, i) {
                      final line = _logLines[i];
                      return Text(
                        line,
                        style: TextStyle(
                          color: _lineColor(line),
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          height: 1.55,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Maps log level indicators to terminal colours.
  Color _lineColor(String line) {
    final l = line.toLowerCase();
    if (l.contains('✗') || l.contains('[e]') || l.contains('error')) {
      return const Color(0xFFFF4444);
    }
    if (l.contains('[w]') || l.contains('warn')) {
      return const Color(0xFFFFAA00);
    }
    if (l.contains('[i]') || l.contains('info') || l.contains('✓')) {
      return const Color(0xFF00FF99);
    }
    if (l.contains('[d]') || l.contains('debug')) {
      return const Color(0xFF7799FF);
    }
    return const Color(0xFF888888);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Small labelled metric pill used in the metrics row.
class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 11, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

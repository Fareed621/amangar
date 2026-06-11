// lib/core/services/in_memory_log_output.dart
import 'dart:async';
import 'package:logger/logger.dart';

// ── LAYER 4a: In-Memory Log Appender ─────────────────────────────────────────
//
// Extends [LogOutput] so it can be plugged directly into the `logger` package's
// output chain alongside [ConsoleOutput] via [MultiOutput].
//
// Design decisions:
//  • Singleton: [InMemoryLogOutput.instance] — shared across the entire app so
//    all Logger instances (prayer times, auth, BGSync, ads, encryption) write
//    to the same circular buffer.
//  • Capped at [maxLines] = 100 entries (FIFO eviction) — prevents unbounded
//    memory growth in long-running sessions.
//  • Exposes [lines] as an immutable snapshot and [stream] as a broadcast
//    stream so the DeveloperConsoleWidget can rebuild reactively without polling.
//  • Thread-safe for the main isolate (all Flutter widget callbacks run on the
//    same event loop). Background-isolate logs (BGSync) do NOT write here
//    because they run in a separate memory space — that is by design.
// ─────────────────────────────────────────────────────────────────────────────

class InMemoryLogOutput extends LogOutput {
  InMemoryLogOutput._();

  /// Global singleton — wired into main.dart's root Logger via MultiOutput.
  static final InMemoryLogOutput instance = InMemoryLogOutput._();

  /// Maximum number of log lines retained in memory.
  static const int maxLines = 100;

  final List<String> _buffer = [];

  // StreamController is broadcast so multiple listeners (e.g., multiple
  // DeveloperConsoleWidget rebuilds) can subscribe simultaneously.
  final _controller = StreamController<List<String>>.broadcast();

  /// Immutable snapshot of the current buffer — safe to read from build().
  List<String> get lines => List.unmodifiable(_buffer);

  /// Reactive stream — emit on every new log entry.
  Stream<List<String>> get stream => _controller.stream;

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      if (_buffer.length >= maxLines) {
        _buffer.removeAt(0); // FIFO eviction — drop oldest entry
      }
      _buffer.add(line);
    }
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_buffer));
    }
  }

  /// Clears the buffer and notifies listeners. Called by the console UI.
  void clear() {
    _buffer.clear();
    if (!_controller.isClosed) {
      _controller.add(const []);
    }
  }

  @override
  Future<void> destroy() async {
    await _controller.close();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import '../tasks/domain/task_model.dart';
import '../tasks/presentation/task_notifier.dart';

class FocusTimerScreen extends StatefulHookConsumerWidget {
  final String taskId;
  final String subtaskId;
  
  const FocusTimerScreen({super.key, required this.taskId, required this.subtaskId});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  late ConfettiController _confettiController;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isRunning = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer(int totalSeconds) {
    setState(() {
      _secondsLeft = totalSeconds;
      _isRunning = true;
      _isFinished = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _completeSubtask();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resumeTimer() {
    _startTimer(_secondsLeft);
  }

  void _completeSubtask() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
    });
    _confettiController.play();
    ref.read(taskNotifierProvider.notifier).toggleSubtask(widget.taskId, widget.subtaskId);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskNotifierProvider);
    final task = tasks.firstWhere((t) => t.id == widget.taskId, orElse: () => TaskModel(id: '', title: '', createdAt: DateTime.now()));
    final subtask = task.subtasks.firstWhere((st) => st.id == widget.subtaskId, orElse: () => SubtaskModel(id: '', title: '', estimatedMinutes: 25));

    // Initialize initial time based on subtask estimate
    useEffect(() {
      if (_secondsLeft == 0 && !_isFinished && !_isRunning) {
        Future.microtask(() => setState(() => _secondsLeft = subtask.estimatedMinutes * 60));
      }
      return null;
    }, []);

    String minutesStr = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    String secondsStr = (_secondsLeft % 60).toString().padLeft(2, '0');
    double progress = subtask.estimatedMinutes == 0 ? 0 : 1 - (_secondsLeft / (subtask.estimatedMinutes * 60));

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LANGKAH SAAT INI',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 16),
                    Text(
                      subtask.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 200.ms).slideY(),
                    const SizedBox(height: 64),
                    
                    // Timer Display
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _isFinished ? 1.0 : progress,
                            strokeWidth: 8,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          _isFinished ? 'SELESAI' : '$minutesStr:$secondsStr',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _isFinished ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).scale(),
                    
                    const SizedBox(height: 64),
                    
                    // Controls
                    if (_isFinished)
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali ke Dashboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ).animate().fadeIn().scale()
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              _timer?.cancel();
                              context.pop();
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('Batal'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isRunning ? _pauseTimer : _resumeTimer,
                            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                            label: Text(_isRunning ? 'Jeda' : 'Mulai'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      
                    // Quick Setters
                    if (!_isRunning && !_isFinished) ...[
                       const SizedBox(height: 32),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [5, 15, 25].map((mins) {
                           return Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                             child: ChoiceChip(
                               label: Text('$mins m'),
                               selected: _secondsLeft == mins * 60,
                               onSelected: (selected) {
                                 if (selected) setState(() => _secondsLeft = mins * 60);
                               },
                             ),
                           );
                         }).toList(),
                       ).animate().fadeIn(delay: 800.ms),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}

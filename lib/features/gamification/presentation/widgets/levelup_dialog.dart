import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

class LevelUpDialog extends StatefulWidget {
  final int level;
  const LevelUpDialog({super.key, required this.level});

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6534FF), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6534FF).withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.yellowAccent, size: 80)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2000.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut)
                      .then()
                      .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1000.ms, curve: Curves.easeInOut),
                ),
                const SizedBox(height: 24),
                const Text(
                  'LEVEL UP!',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 36, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn().scale(curve: Curves.easeOutBack),
                const SizedBox(height: 12),
                Text(
                  'You reached Level ${widget.level}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6534FF),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                  ),
                  child: const Text('Awesome!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

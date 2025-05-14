import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';
import 'package:qadam_app/app/services/challenge_service.dart';
import 'package:qadam_app/app/models/challenge_model.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch challenges when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeService>(context, listen: false).fetchChallenges();
    });
  }

  void _updateChallengesProgress(List<Challenge> challenges, int currentSteps, ChallengeService challengeService) {
    print("Current steps in _updateChallengesProgress: $currentSteps");
    for (var challenge in challenges) {
      if (!challenge.isCompleted && challenge.progress < 1.0) {
        final challengeModel = challengeService.challenges.firstWhere(
          (c) => c.id == challenge.id,
          orElse: () => ChallengeModel(
            id: challenge.id,
            title: challenge.title,
            description: challenge.description,
            reward: challenge.reward,
            targetSteps: 5000, // Default if not found
            duration: 1,
            type: 'daily',
          ),
        );
        
        print("Challenge: ${challengeModel.title}");
        print("Target steps: ${challengeModel.targetSteps}");
        
        final progress = calculateProgress(challengeModel, currentSteps);

        print("Current steps: $currentSteps");
        print("Calculated progress: $progress");
        
        if (progress != challenge.progress) {
          print("Updating progress from ${challenge.progress} to $progress");
          challengeService.updateChallengeProgress(challenge.id, progress);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepService = Provider.of<StepCounterService>(context);
    final coinService = Provider.of<CoinService>(context);
    final challengeService = Provider.of<ChallengeService>(context);

    // Filter challenges by type
    final dailyChallenges = challengeService.challenges
        .where((c) => c.type == 'daily')
        .map((c) => Challenge(
              title: c.title,
              description: c.description,
              reward: c.reward,
              progress: calculateProgress(c, stepService.steps),
              isCompleted: c.isCompleted,
              icon: getIconForChallenge(c.title),
              id: c.id,
            ))
        .toList();

    // Update progress for daily challenges based on current steps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChallengesProgress(dailyChallenges, stepService.steps, challengeService);
    });

    final weeklyChallenges = challengeService.challenges
        .where((c) => c.type == 'weekly')
        .map((c) => Challenge(
              title: c.title,
              description: c.description,
              reward: c.reward,
              progress: calculateProgress(c, stepService.steps),
              isCompleted: c.isCompleted,
              icon: getIconForChallenge(c.title),
              id: c.id,
            ))
        .toList();

    final completedChallenges = challengeService.challenges
        .where((c) => c.isCompleted)
        .map((c) => Challenge(
              title: c.title,
              description: c.description,
              reward: c.reward,
              progress: 1.0,
              isCompleted: true,
              icon: getIconForChallenge(c.title),
              id: c.id,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challengelar'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: challengeService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : challengeService.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Xatolik yuz berdi: ${challengeService.error}'),
                      ElevatedButton(
                        onPressed: () {
                          challengeService.fetchChallenges();
                        },
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Challenge intro
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Challengelarda qatnashing',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Challengelarni bajarib, qo\'shimcha tangalar yuting',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Daily challenges
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Bugungi challengelar',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (dailyChallenges.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Bugungi challengelar mavjud emas',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...dailyChallenges.map((challenge) => _buildChallengeCard(context, challenge, coinService, challengeService)).toList(),
                          ],
                        ),
                      ),

                      // Weekly challenges
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Haftalik challengelar',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (weeklyChallenges.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Haftalik challengelar mavjud emas',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...weeklyChallenges.map((challenge) => _buildChallengeCard(context, challenge, coinService, challengeService)).toList(),
                          ],
                        ),
                      ),

                      // Challenge history (completed)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bajarilgan challengelar',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                            fontSize: 18,
                                          ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Show history
                                  },
                                  child: const Text('Barchasini ko\'rish'),
                                ),
                              ],
                            ),
                            
                            if (completedChallenges.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Hali bajarilgan challengelar yo\'q',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...completedChallenges.take(3).map((challenge) => _buildChallengeCard(context, challenge, coinService, challengeService)).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge, CoinService coinService, ChallengeService challengeService) {
    final clampedProgress = challenge.progress > 1.0 ? 1.0 : challenge.progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: challenge.isCompleted
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFFFC107).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  challenge.icon,
                  color: challenge.isCompleted
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFFC107),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFFC107),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Color(0xFFFFC107),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+${challenge.reward}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (challenge.progress >= 1.0 && !challenge.isCompleted) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 20),
                              Text('Mukofot olinmoqda...'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  
                  try {
                    // Complete the challenge in the database
                    await challengeService.completeChallenge(challenge.id);
                    
                    // Also add coins locally to make it immediately visible
                    await coinService.addCoins(challenge.reward);
                    
                    // Close loading dialog
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    
                    // Show animation and success message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: const Color(0xFFFFC107),
                                  size: 60,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Tabriklaymiz!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Siz ${challenge.title} challengeni bajardingiz!',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: const Color(0xFFFFC107),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '+${challenge.reward} tanga',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFC107),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                    ),
                                    child: const Text('Davom etish'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    
                  } catch (e) {
                    // Close loading dialog
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Xatolik yuz berdi: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Mukofotni olish'),
              ),
            ),
          ] else if (challenge.isCompleted) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
                child: const Text('Mukofot olindi'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double calculateProgress(ChallengeModel challenge, int currentSteps) {
    print("calculateProgress called with:");
    print("- targetSteps: ${challenge.targetSteps}");
    print("- currentSteps: $currentSteps");
    print("- existing progress: ${challenge.progress}");
    
    // Safety check for division by zero
    if (challenge.targetSteps <= 0) {
      print("Target steps is zero or negative, returning existing progress: ${challenge.progress ?? 0}");
      return challenge.progress ?? 0;
    }
    
    // Calculate progress based on steps
    double progress = currentSteps / challenge.targetSteps;
    print("Calculated raw progress: $progress");
    
    // Make sure progress is not negative
    progress = progress < 0 ? 0 : progress;
    
    // For debugging
    final existingProgress = challenge.progress ?? 0;
    final finalProgress = progress > existingProgress ? progress : existingProgress;
    
    print("Final progress value: $finalProgress");
    
    // Return the higher of current progress in database or calculated progress
    return finalProgress;
  }

  IconData getIconForChallenge(String title) {
    if (title.contains('qadam')) return Icons.directions_walk;
    if (title.contains('do\'st')) return Icons.people;
    if (title.contains('kun')) return Icons.calendar_today;
    return Icons.emoji_events;
  }
}

class Challenge {
  final String title;
  final String description;
  final int reward;
  final double progress;
  final bool isCompleted;
  final IconData icon;
  final String id;

  Challenge({
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.isCompleted,
    required this.icon,
    required this.id,
  });
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stepService = Provider.of<StepCounterService>(context);
    final coinService = Provider.of<CoinService>(context);

    // Define challenges - in a real app, these would come from a backend
    final List<Challenge> dailyChallenges = [
      Challenge(
        title: '5,000 qadam bosing',
        description: 'Bugun 5,000 qadam bosib, 50 tanga yuting',
        reward: 50,
        progress: stepService.steps / 5000,
        isCompleted: stepService.steps >= 5000,
        icon: Icons.directions_walk,
      ),
      Challenge(
        title: '10,000 qadam bosing',
        description: 'Bugun 10,000 qadam bosib, 100 tanga yuting',
        reward: 100,
        progress: stepService.steps / 10000,
        isCompleted: stepService.steps >= 10000,
        icon: Icons.directions_run,
      ),
    ];

    final List<Challenge> weeklyChallenges = [
      Challenge(
        title: '7 kun ketma-ket 8,000+ qadam',
        description: 'Bir hafta davomida har kuni 8,000 qadamdan oshiring',
        reward: 500,
        progress: 0.3, // Placeholder, should be calculated from history
        isCompleted: false,
        icon: Icons.calendar_today,
      ),
      Challenge(
        title: 'Do\'stingizni taklif qiling',
        description: 'Bir do\'stingizni taklif qiling va 200 tanga oling',
        reward: 200,
        progress: 0, // Placeholder
        isCompleted: false,
        icon: Icons.people,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challengelar'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
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
                  ...dailyChallenges.map((challenge) => _buildChallengeCard(context, challenge)).toList(),
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
                  ...weeklyChallenges.map((challenge) => _buildChallengeCard(context, challenge)).toList(),
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
                  
                  // Placeholder for completed challenges
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
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
          if (challenge.isCompleted) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Claim reward
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Mukofotni olish'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Challenge {
  final String title;
  final String description;
  final int reward;
  final double progress;
  final bool isCompleted;
  final IconData icon;

  Challenge({
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.isCompleted,
    required this.icon,
  });
} 
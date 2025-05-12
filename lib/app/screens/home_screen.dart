import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';
import 'package:qadam_app/app/screens/coin_wallet_screen.dart';
import 'package:qadam_app/app/screens/challenge_screen.dart';
import 'package:qadam_app/app/screens/statistics_screen.dart';
import 'package:qadam_app/app/screens/referral_screen.dart';
import 'package:qadam_app/app/components/step_progress_card.dart';
import 'package:qadam_app/app/components/challenge_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid the setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start step counting service
      final stepService = Provider.of<StepCounterService>(context, listen: false);
      stepService.startCounting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepService = Provider.of<StepCounterService>(context);
    final coinService = Provider.of<CoinService>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Qadam++'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salom, Foydalanuvchi!',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Bugun sog\'lom qadamlar',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFFC107),
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${coinService.coins}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Step counter card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: StepProgressCard(
                  steps: stepService.steps,
                  goal: stepService.dailyGoal,
                  coins: coinService.todayEarned,
                ),
              ),

              // Challenge banner
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: ChallengeBanner(),
              ),

              const SizedBox(height: 20),

              // Options grid
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qo\'shimcha imkoniyatlar',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 18,
                              ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            icon: Icons.monetization_on,
                            label: 'Hamyon',
                            color: const Color(0xFFFFC107),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CoinWalletScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            icon: Icons.analytics,
                            label: 'Statistika',
                            color: const Color(0xFF2196F3),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StatisticsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            icon: Icons.flag,
                            label: 'Challenge',
                            color: const Color(0xFFE91E63),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChallengeScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            icon: Icons.people,
                            label: 'Referal',
                            color: const Color(0xFF673AB7),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReferralScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

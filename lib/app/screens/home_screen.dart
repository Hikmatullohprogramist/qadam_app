import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/screens/splash_screen.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';
import 'package:qadam_app/app/screens/coin_wallet_screen.dart';
import 'package:qadam_app/app/screens/challenge_screen.dart';
import 'package:qadam_app/app/screens/statistics_screen.dart';
import 'package:qadam_app/app/screens/referral_screen.dart';
import 'package:qadam_app/app/components/step_progress_card.dart';
import 'package:qadam_app/app/components/challenge_banner.dart';

import '../ad_helper.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // COMPLETE: Add _rewardedAd
  RewardedAd? _rewardedAd;
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid the setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start step counting service
      final stepService =
          Provider.of<StepCounterService>(context, listen: false);
      stepService.startCounting();

      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();

      // COMPLETE: Load a rewarded Ad

      // _loadRewardedAd();
    });
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    final stepService = Provider.of<StepCounterService>(context);
    final coinService = Provider.of<CoinService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: authService.user?.photoURL != null
                        ? NetworkImage(authService.user!.photoURL!)
                        : null,
                    child: authService.user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 33,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authService.user?.displayName ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    authService.user?.email ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Asosiy'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Sozlamalar'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Chiqish'),
              onTap: () {
                authService.signOut();

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SplashScreen()));
              },
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
            onTap: () {
              stepService.addSteps(100);
            },
            child: const Text('Qadam++')),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              _key.currentState?.openDrawer();
            },
            icon: const Icon(
              Icons.menu,
            )),
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

              if (_bannerAd != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
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
                          'Salom, ${authService.user?.displayName ?? ""}!',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepService = Provider.of<StepCounterService>(context);
    final coinService = Provider.of<CoinService>(context);

    // Sample data for statistics
    // In a real app, this would be fetched from a database/backend
    List<DailyStats> weeklyStats = [
      DailyStats(day: 'Dushanba', steps: 8234, coins: 82),
      DailyStats(day: 'Seshanba', steps: 10567, coins: 100),
      DailyStats(day: 'Chorshanba', steps: 7659, coins: 76),
      DailyStats(day: 'Payshanba', steps: 9876, coins: 98),
      DailyStats(day: 'Juma', steps: 11245, coins: 100),
      DailyStats(day: 'Shanba', steps: 5432, coins: 54),
      DailyStats(day: 'Yakshanba', steps: stepService.steps, coins: coinService.todayEarned),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kunlik'),
            Tab(text: 'Haftalik'),
            Tab(text: 'Oylik'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Daily statistics
          _buildDailyTab(context, weeklyStats.last),
          
          // Weekly statistics
          _buildWeeklyTab(context, weeklyStats),
          
          // Monthly statistics
          Center(
            child: Text(
              'Oylik statistika hali mavjud emas',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(BuildContext context, DailyStats todayStats) {
    final stepService = Provider.of<StepCounterService>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              children: [
                Text(
                  'Bugungi natijalar',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.directions_walk,
                      value: todayStats.steps.toString(),
                      label: 'Qadam',
                      color: Theme.of(context).primaryColor,
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.monetization_on,
                      value: '+${todayStats.coins}',
                      label: 'Tanga',
                      color: const Color(0xFFFFC107),
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.trending_up,
                      value: '${(todayStats.steps / stepService.dailyGoal * 100).toInt()}%',
                      label: 'Maqsad',
                      color: const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Activity timeline
          Text(
            'Bugungi faoliyat',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                _buildTimelineItem(
                  context,
                  time: '08:30',
                  activity: 'Qadam sanoq boshlandi',
                  detail: 'Kun davomida qadamlarni kuzatamiz',
                  icon: Icons.play_circle_outline,
                  color: Theme.of(context).primaryColor,
                ),
                if (todayStats.steps > 5000)
                  _buildTimelineItem(
                    context,
                    time: '12:15',
                    activity: '5,000 qadam challengesi bajarildi',
                    detail: '+50 tanga qo\'shildi',
                    icon: Icons.emoji_events,
                    color: const Color(0xFFFFC107),
                  ),
                if (todayStats.steps > 8000)
                  _buildTimelineItem(
                    context,
                    time: '16:45',
                    activity: 'Kunlik maqsadning 80% bajarildi',
                    detail: 'Yaxshi ketayapsiz!',
                    icon: Icons.trending_up,
                    color: const Color(0xFF2196F3),
                  ),
                if (todayStats.steps > 10000)
                  _buildTimelineItem(
                    context,
                    time: '19:30',
                    activity: '10,000 qadam maqsadi bajarildi',
                    detail: 'Ajoyib natija! +100 tanga qo\'shildi',
                    icon: Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    isLast: true,
                  ),
                if (todayStats.steps <= 10000)
                  _buildTimelineItem(
                    context,
                    time: 'Hozir',
                    activity: '${todayStats.steps} qadam bosib bo\'ldingiz',
                    detail: 'Davom eting!',
                    icon: Icons.access_time,
                    color: Colors.grey,
                    isLast: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(BuildContext context, List<DailyStats> weeklyStats) {
    // Calculate weekly totals
    int totalSteps = weeklyStats.fold(0, (sum, stats) => sum + stats.steps);
    int totalCoins = weeklyStats.fold(0, (sum, stats) => sum + stats.coins);
    double dailyAverage = totalSteps / 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              children: [
                Text(
                  'Haftalik ko\'rsatkichlar',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.directions_walk,
                      value: totalSteps.toString(),
                      label: 'Qadam',
                      color: Theme.of(context).primaryColor,
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.monetization_on,
                      value: totalCoins.toString(),
                      label: 'Tanga',
                      color: const Color(0xFFFFC107),
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.calendar_today,
                      value: dailyAverage.toInt().toString(),
                      label: 'O\'rtacha',
                      color: const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Daily breakdown
          Text(
            'Kunlik ma\'lumotlar',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 15),
          
          // Here we would typically display a chart
          // For simplicity, just showing a list of daily stats
          ...weeklyStats.map((stats) => _buildDayStatsCard(context, stats)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String time,
    required String activity,
    required String detail,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                activity,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (!isLast) const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayStatsCard(BuildContext context, DailyStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stats.day,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    stats.steps.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    stats.coins.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DailyStats {
  final String day;
  final int steps;
  final int coins;

  DailyStats({
    required this.day,
    required this.steps,
    required this.coins,
  });
} 
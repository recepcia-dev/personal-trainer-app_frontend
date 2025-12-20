import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_state_provider.dart';
import 'dashboard_tabs/clients_tab.dart';
import 'dashboard_tabs/profile_tab.dart';
import 'dashboard_tabs/settings_tab.dart';

/// Trainer Dashboard with 3 main sections
///
/// Features:
/// - Profile tab: General trainer information
/// - Clients tab: List of all clients with workout/meal management
/// - Settings tab: Language, theme mode, payments
class TrainerDashboardScreen extends ConsumerStatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  ConsumerState<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends ConsumerState<TrainerDashboardScreen>
    with SingleTickerProviderStateMixin {
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
    final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trainer Dashboard',
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 1,
        surfaceTintColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.person_outline),
              text: 'Profile',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Clients',
            ),
            Tab(
              icon: Icon(Icons.settings_outlined),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProfileTab(),
          ClientsTab(),
          SettingsTab(),
        ],
      ),
    );
  }
}

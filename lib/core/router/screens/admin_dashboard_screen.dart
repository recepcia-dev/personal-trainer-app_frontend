import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/admin/presentation/providers/admin_provider.dart';

/// Professional Admin Dashboard with Material 3 DataTables and purple theme
///
/// Features:
/// - Stats tab with metric cards
/// - Users management with DataTable, search, and filters
/// - Exercises management with DataTable, search, and pagination
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 1,
        surfaceTintColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'Statistics',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Users',
            ),
            Tab(
              icon: Icon(Icons.fitness_center_outlined),
              text: 'Exercises',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AdminStatsTab(),
          _AdminUsersTab(),
          _AdminExercisesTab(),
        ],
      ),
    );
  }
}

/// Statistics tab showing platform metrics with enhanced card design
class _AdminStatsTab extends ConsumerWidget {
  const _AdminStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return const Center(child: Text('Failed to load statistics'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 28),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  _StatMetricCard(
                    value: '${stats.totalUsers}',
                    label: 'Total Users',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatMetricCard(
                    value: '${stats.trainers}',
                    label: 'Trainers',
                    icon: Icons.person_outline,
                    color: Colors.deepPurple,
                  ),
                  _StatMetricCard(
                    value: '${stats.clients}',
                    label: 'Clients',
                    icon: Icons.group_outlined,
                    color: Colors.teal,
                  ),
                  _StatMetricCard(
                    value: '${stats.admins}',
                    label: 'Admins',
                    icon: Icons.admin_panel_settings_outlined,
                    color: Colors.orange,
                  ),
                  _StatMetricCard(
                    value: '${stats.exercises}',
                    label: 'Exercises',
                    icon: Icons.fitness_center,
                    color: Colors.red,
                  ),
                  _StatMetricCard(
                    value: '${stats.progressLogs}',
                    label: 'Progress Logs',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Reusable stat metric card with icon, value, and label
class _StatMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatMetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.02),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Users management tab with DataTable, search, and filters
class _AdminUsersTab extends ConsumerStatefulWidget {
  const _AdminUsersTab();

  @override
  ConsumerState<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<_AdminUsersTab> {
  String _searchQuery = '';
  Set<String> _selectedFilters = {'All'};
  int _currentPage = 0;
  static const int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        // Filter users based on search and type filters
        var filtered = users.where((user) {
          final matchesSearch = user.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesFilter = _selectedFilters.contains('All') ||
              (_selectedFilters.contains('Active') && user.isActive) ||
              (_selectedFilters.contains('Inactive') && !user.isActive) ||
              (_selectedFilters.contains(user.userTypeDisplay));
          return matchesSearch && matchesFilter;
        }).toList();

        final totalPages = (filtered.length / _rowsPerPage).ceil();
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
        final pageUsers = filtered.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Search and Filters Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    SearchBar(
                      hintText: 'Search by name or email...',
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Admin',
                        'Trainer',
                        'Client',
                        'Active',
                        'Inactive',
                      ]
                          .map((filter) => FilterChip(
                                label: Text(filter),
                                selected: _selectedFilters.contains(filter),
                                onSelected: (selected) {
                                  setState(() {
                                    if (filter == 'All') {
                                      _selectedFilters = {'All'};
                                      _currentPage = 0;
                                    } else {
                                      _selectedFilters.remove('All');
                                      if (selected) {
                                        _selectedFilters.add(filter);
                                      } else {
                                        _selectedFilters.remove(filter);
                                      }
                                      if (_selectedFilters.isEmpty) {
                                        _selectedFilters = {'All'};
                                      }
                                      _currentPage = 0;
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // DataTable
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DataTable(
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(
                        label: Text('Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                    ],
                    rows: pageUsers
                        .map((user) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    user.fullName ?? user.email,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(Text(user.email)),
                                DataCell(
                                  Chip(
                                    label: Text(user.userTypeDisplay),
                                    backgroundColor: user.userTypeDisplay == 'Admin'
                                        ? Colors.orange.withOpacity(0.2)
                                        : user.userTypeDisplay == 'Trainer'
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: user.userTypeDisplay == 'Admin'
                                          ? Colors.orange[900]
                                          : user.userTypeDisplay == 'Trainer'
                                              ? Colors.blue[900]
                                              : Colors.green[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Icon(
                                    user.isActive ? Icons.check_circle : Icons.cancel,
                                    color: user.isActive ? Colors.green : Colors.red,
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () {},
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        color: Colors.red,
                                        onPressed: () {},
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
              // Pagination
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Exercises catalog tab with DataTable, search, and filtering
class _AdminExercisesTab extends ConsumerStatefulWidget {
  const _AdminExercisesTab();

  @override
  ConsumerState<_AdminExercisesTab> createState() => _AdminExercisesTabState();
}

class _AdminExercisesTabState extends ConsumerState<_AdminExercisesTab> {
  String _searchQuery = '';
  String? _selectedCategory;
  int _currentPage = 0;
  static const int _rowsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(adminExercisesProvider);

    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return const Center(child: Text('No exercises found'));
        }

        // Extract unique categories
        final categories = <String>{};
        for (final exercise in exercises) {
          final category = exercise['category'] as String?;
          if (category != null) categories.add(category);
        }

        // Filter exercises
        var filtered = exercises.where((exercise) {
          final matchesSearch = (exercise['name'] as String?)
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true;
          final matchesCategory = _selectedCategory == null ||
              exercise['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        final totalPages = (filtered.length / _rowsPerPage).ceil();
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
        final pageExercises = filtered.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Search and Filters Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    SearchBar(
                      hintText: 'Search exercises...',
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Filter Dropdown
                    DropdownButton<String?>(
                      value: _selectedCategory,
                      hint: const Text('Filter by category'),
                      isExpanded: true,
                      onChanged: (value) => setState(() {
                        _selectedCategory = value;
                        _currentPage = 0;
                      }),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categories.map((category) => DropdownMenuItem<String?>(
                              value: category,
                              child: Text(category),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              // DataTable
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(
                        label: Text('Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Muscle Group',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Equipment',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                      DataColumn(
                        label: Text('Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            )),
                      ),
                    ],
                    rows: pageExercises
                        .map((exercise) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    (exercise['name'] as String?) ?? 'Unnamed',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Chip(
                                    label: Text((exercise['category'] as String?) ?? '—'),
                                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                    labelStyle: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text((exercise['muscle_group'] as String?) ?? '—'),
                                ),
                                DataCell(
                                  Text((exercise['equipment'] as String?) ?? '—'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () {},
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        color: Colors.red,
                                        onPressed: () {},
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
              // Pagination
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add Exercise FAB hint
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Use the + button to add new exercises',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

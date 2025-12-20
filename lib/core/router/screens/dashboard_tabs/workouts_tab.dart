import 'package:flutter/material.dart';

/// Workouts tab - Not used for trainers
/// This file exists only to prevent import errors
class WorkoutsTab extends StatelessWidget {
  const WorkoutsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Workouts tab is not available for trainers'),
    );
  }
}

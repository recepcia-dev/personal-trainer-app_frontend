import 'package:flutter/material.dart';

/// Home tab - Not used for trainers
/// This file exists only to prevent import errors
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home tab is not available for trainers'),
    );
  }
}

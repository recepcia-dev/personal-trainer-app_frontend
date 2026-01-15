import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/booking_request_model.dart';
import '../providers/booking_provider.dart';

class BookingRequestsScreen extends ConsumerStatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  ConsumerState<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends ConsumerState<BookingRequestsScreen>
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
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(bookingRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: requestsAsync.when(
        data: (requests) {
          final pending = requests.where((r) => r.status == BookingStatus.pending).toList();
          final accepted = requests.where((r) => r.status == BookingStatus.accepted).toList();
          final history = requests.where((r) => 
            r.status == BookingStatus.declined || 
            r.status == BookingStatus.cancelled ||
            r.status == BookingStatus.completed
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _RequestsList(
                requests: pending,
                emptyMessage: 'No pending requests',
                showActions: true,
                onAccept: (request) => _handleAccept(request),
                onDecline: (request) => _handleDecline(request),
              ),
              _RequestsList(
                requests: accepted,
                emptyMessage: 'No accepted bookings',
                showActions: false,
              ),
              _RequestsList(
                requests: history,
                emptyMessage: 'No booking history',
                showActions: false,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load requests', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookingRequestsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccept(BookingRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Booking'),
        content: Text(
          'Accept booking request from ${request.clientName} '
          'for ${DateFormat('MMM d').format(request.requestedDate)} at ${request.requestedTime}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Call API to accept booking
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking with ${request.clientName} accepted!'),
          backgroundColor: Colors.green,
        ),
      );
      ref.invalidate(bookingRequestsProvider);
    }
  }

  Future<void> _handleDecline(BookingRequestModel request) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _DeclineDialog(clientName: request.clientName),
    );

    if (reason != null && mounted) {
      // TODO: Call API to decline booking with reason
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request declined')),
      );
      ref.invalidate(bookingRequestsProvider);
    }
  }
}

class _RequestsList extends StatelessWidget {
  final List<BookingRequestModel> requests;
  final String emptyMessage;
  final bool showActions;
  final void Function(BookingRequestModel)? onAccept;
  final void Function(BookingRequestModel)? onDecline;

  const _RequestsList({
    required this.requests,
    required this.emptyMessage,
    required this.showActions,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh is handled by parent
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _BookingRequestCard(
            request: request,
            showActions: showActions,
            onAccept: onAccept != null ? () => onAccept!(request) : null,
            onDecline: onDecline != null ? () => onDecline!(request) : null,
          );
        },
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingRequestModel request;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _BookingRequestCard({
    required this.request,
    required this.showActions,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    
    Color statusColor;
    String statusText;
    switch (request.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case BookingStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case BookingStatus.declined:
        statusColor = Colors.red;
        statusText = 'Declined';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Completed';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: request.clientPhotoUrl != null
                      ? NetworkImage(request.clientPhotoUrl!)
                      : null,
                  child: request.clientPhotoUrl == null
                      ? Text(
                          request.clientName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (request.clientEmail != null)
                        Text(
                          request.clientEmail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(request.requestedDate),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(request.requestedTime, style: theme.textTheme.bodyMedium),
                if (request.durationMinutes != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${request.durationMinutes} min)',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.notes!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (request.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Requested ${_formatTimeAgo(request.createdAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDecline,
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}

class _DeclineDialog extends StatefulWidget {
  final String clientName;

  const _DeclineDialog({required this.clientName});

  @override
  State<_DeclineDialog> createState() => _DeclineDialogState();
}

class _DeclineDialogState extends State<_DeclineDialog> {
  final _reasonController = TextEditingController();
  String _selectedReason = 'Not available at requested time';

  final _reasons = [
    'Not available at requested time',
    'Schedule is full',
    'Not taking new clients',
    'Other (specify below)',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you declining ${widget.clientName}\'s request?'),
          const SizedBox(height: 16),
          ...(_reasons.map((reason) => RadioListTile<String>(
            title: Text(reason, style: const TextStyle(fontSize: 14)),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) => setState(() => _selectedReason = value!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ))),
          if (_selectedReason == 'Other (specify below)') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _selectedReason == 'Other (specify below)'
                ? _reasonController.text
                : _selectedReason;
            Navigator.pop(context, reason);
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

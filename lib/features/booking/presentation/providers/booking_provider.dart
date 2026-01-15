import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/booking_request_model.dart';

/// Provider for booking requests for the current trainer
final bookingRequestsProvider = FutureProvider<List<BookingRequestModel>>((ref) async {
  // TODO: Replace with actual API call
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Mock data
  return [
    BookingRequestModel(
      id: '1',
      trainerId: 'trainer-1',
      clientId: 'client-1',
      clientName: 'Sarah Williams',
      clientEmail: 'sarah@example.com',
      requestedDate: DateTime.now().add(const Duration(days: 2)),
      requestedTime: '10:00 AM',
      durationMinutes: 60,
      notes: 'First time training, interested in weight loss program',
      status: BookingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    BookingRequestModel(
      id: '2',
      trainerId: 'trainer-1',
      clientId: 'client-2',
      clientName: 'Michael Chen',
      clientEmail: 'michael@example.com',
      requestedDate: DateTime.now().add(const Duration(days: 3)),
      requestedTime: '2:00 PM',
      durationMinutes: 90,
      notes: 'Want to focus on muscle building',
      status: BookingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    BookingRequestModel(
      id: '3',
      trainerId: 'trainer-1',
      clientId: 'client-3',
      clientName: 'Emma Johnson',
      clientEmail: 'emma@example.com',
      requestedDate: DateTime.now().add(const Duration(days: 1)),
      requestedTime: '4:00 PM',
      durationMinutes: 60,
      status: BookingStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      respondedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    BookingRequestModel(
      id: '4',
      trainerId: 'trainer-1',
      clientId: 'client-4',
      clientName: 'David Brown',
      clientEmail: 'david@example.com',
      requestedDate: DateTime.now().subtract(const Duration(days: 2)),
      requestedTime: '11:00 AM',
      durationMinutes: 60,
      notes: 'Looking for injury rehabilitation training',
      status: BookingStatus.declined,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      respondedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});

/// Provider for pending booking requests count
final pendingBookingCountProvider = Provider<int>((ref) {
  final requests = ref.watch(bookingRequestsProvider);
  return requests.when(
    data: (data) => data.where((r) => r.status == BookingStatus.pending).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

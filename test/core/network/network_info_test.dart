import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('NetworkInfoImpl', () {
    late MockConnectivity mockConnectivity;
    late NetworkInfoImpl networkInfo;

    setUp(() {
      mockConnectivity = MockConnectivity();
      networkInfo = NetworkInfoImpl(mockConnectivity);
    });

    test(
      'isConnected returns true when device is connected to WiFi',
      () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, true);
        verify(() => mockConnectivity.checkConnectivity()).called(1);
      },
    );

    test(
      'isConnected returns true when device is connected to mobile data',
      () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.mobile);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, true);
        verify(() => mockConnectivity.checkConnectivity()).called(1);
      },
    );

    test(
      'isConnected returns true when device is connected to ethernet',
      () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.ethernet);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, true);
        verify(() => mockConnectivity.checkConnectivity()).called(1);
      },
    );

    test(
      'isConnected returns false when device has no connectivity',
      () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, false);
        verify(() => mockConnectivity.checkConnectivity()).called(1);
      },
    );

    test(
      'isConnected returns false when checkConnectivity throws exception',
      () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenThrow(Exception('Connectivity check failed'));

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, false);
      },
    );
  });
}

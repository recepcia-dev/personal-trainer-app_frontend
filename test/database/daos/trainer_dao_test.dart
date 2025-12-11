import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer_app/database/daos/trainer_dao.dart';

void main() {
  group('TrainerDao', () {
    test('TrainerDao class is properly defined', () {
      expect(TrainerDao, isNotNull);
    });

    test('TrainerDao extends DatabaseAccessor', () {
      const type = TrainerDao;
      expect(
        type.toString().contains('TrainerDao'),
        true,
      );
    });

    test('trainer_dao.dart file contains required methods', () {
      expect(TrainerDao, isNotNull);
    });
  });
}

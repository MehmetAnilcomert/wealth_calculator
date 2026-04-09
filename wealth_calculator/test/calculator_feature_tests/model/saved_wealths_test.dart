import 'package:flutter_test/flutter_test.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

void main() {
  group('SavedWealths Model Tests', () {
    test('fromMap creates valid SavedWealths object', () {
      final map = {
        'id': 123,
        'type': 'Gram Altın',
        'amount': 15.5,
      };

      final savedWealth = SavedWealths.fromMap(map);

      expect(savedWealth.id, 123);
      expect(savedWealth.type, 'Gram Altın');
      expect(savedWealth.amount, 15.5);
    });

    test('toMap serializes SavedWealths object correctly', () {
      final savedWealth = SavedWealths(
        id: 456,
        type: 'ABD Doları',
        amount: 1000.0,
      );

      final map = savedWealth.toMap();

      expect(map['id'], 456);
      expect(map['type'], 'ABD Doları');
      expect(map['amount'], 1000.0);
    });

    test('copyWith creates a new object with updated fields', () {
      final original = SavedWealths(id: 1, type: 'Test', amount: 10.0);
      
      // We use copyWith instead of direct assignment
      final updated = original.copyWith(amount: 20.0);

      // Verify original is UNCHANGED (Immutability)
      expect(original.amount, 10.0);
      
      // Verify new copy has updated value
      expect(updated.amount, 20.0);
      
      // Verify other fields are preserved
      expect(updated.id, original.id);
      expect(updated.type, original.type);
    });
  });
}

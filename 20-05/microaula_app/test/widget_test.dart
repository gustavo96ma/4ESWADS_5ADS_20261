import 'package:flutter_test/flutter_test.dart';

import 'package:microaula_app/models/note.dart';

void main() {
  test('Note serializa e desserializa via JSON', () {
    final now = DateTime(2026, 5, 20, 14, 30);
    final original = Note(id: 1, title: 'Comprar leite', createdAt: now);

    final json = original.toJson();
    final restored = Note.fromJson(json);

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.createdAt, original.createdAt);
  });

  test('Note.copyWith mantém campos não alterados', () {
    final n = Note(id: 1, title: 'Original', createdAt: DateTime(2026, 5, 20));
    final updated = n.copyWith(title: 'Atualizada');

    expect(updated.id, 1);
    expect(updated.title, 'Atualizada');
    expect(updated.createdAt, DateTime(2026, 5, 20));
  });
}

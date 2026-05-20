import 'package:hive/hive.dart';

/// Modelo usado em todas as 3 abas do cache_demo (shared_prefs em JSON, Hive, sqflite).
/// TypeAdapter escrito à mão pra evitar build_runner na aula.
class Note {
  Note({
    this.id,
    required this.title,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final DateTime createdAt;

  Note copyWith({int? id, String? title, DateTime? createdAt}) => Note(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as int?,
        title: json['title'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      );
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    return Note(
      title: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

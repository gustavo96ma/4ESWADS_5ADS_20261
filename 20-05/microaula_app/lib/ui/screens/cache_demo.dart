import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/note.dart';

class CacheDemoScreen extends StatelessWidget {
  const CacheDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Cache local'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'shared_prefs'),
              Tab(text: 'Hive'),
              Tab(text: 'sqflite'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SharedPrefsTab(),
            _HiveTab(),
            _SqfliteTab(),
          ],
        ),
      ),
    );
  }
}

/// Aba 1 — shared_preferences guardando lista serializada em JSON.
/// Demonstra que primitivos só (`List<String>`) já cobre bem casos simples.
class _SharedPrefsTab extends StatefulWidget {
  const _SharedPrefsTab();
  @override
  State<_SharedPrefsTab> createState() => _SharedPrefsTabState();
}

class _SharedPrefsTabState extends State<_SharedPrefsTab> {
  static const _key = 'notes_json';
  final _controller = TextEditingController();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _load() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_key) ?? [];
    setState(() {
      _notes = raw.map((s) => Note.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _save() async {
    final prefs = await _prefs;
    await prefs.setStringList(_key, _notes.map((n) => jsonEncode(n.toJson())).toList());
  }

  Future<void> _add() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _notes = [
        ..._notes,
        Note(title: _controller.text.trim(), createdAt: DateTime.now()),
      ];
    });
    _controller.clear();
    await _save();
  }

  Future<void> _remove(int i) async {
    setState(() => _notes = [..._notes]..removeAt(i));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return _CrudView(
      controller: _controller,
      hint: 'Chave: notes_json (List<String>)',
      notes: _notes,
      onAdd: _add,
      onRemove: _remove,
    );
  }
}

/// Aba 2 — Hive com `Box<Note>`.
/// Demonstra persistência tipada sem serializar manualmente.
class _HiveTab extends StatefulWidget {
  const _HiveTab();
  @override
  State<_HiveTab> createState() => _HiveTabState();
}

class _HiveTabState extends State<_HiveTab> {
  final _controller = TextEditingController();
  Box<Note>? _box;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final box = await Hive.openBox<Note>('notes');
    setState(() => _box = box);
  }

  Future<void> _add() async {
    final box = _box;
    if (box == null || _controller.text.trim().isEmpty) return;
    await box.add(Note(title: _controller.text.trim(), createdAt: DateTime.now()));
    _controller.clear();
    setState(() {});
  }

  Future<void> _remove(int i) async {
    await _box?.deleteAt(i);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final box = _box;
    if (box == null) return const Center(child: CircularProgressIndicator());
    return _CrudView(
      controller: _controller,
      hint: 'Box<Note>("notes")',
      notes: box.values.toList(),
      onAdd: _add,
      onRemove: _remove,
    );
  }
}

/// Aba 3 — sqflite com tabela notes.
/// Roda em mobile; em web exige sqflite_common_ffi_web (fora do escopo da aula).
class _SqfliteTab extends StatefulWidget {
  const _SqfliteTab();
  @override
  State<_SqfliteTab> createState() => _SqfliteTabState();
}

class _SqfliteTabState extends State<_SqfliteTab> {
  final _controller = TextEditingController();
  Database? _db;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _open();
  }

  Future<void> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'microaula.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      '''),
    );
    _db = db;
    await _refresh();
  }

  Future<void> _refresh() async {
    final db = _db;
    if (db == null) return;
    final rows = await db.query('notes', orderBy: 'created_at DESC');
    setState(() => _notes = rows.map(Note.fromJson).toList());
  }

  Future<void> _add() async {
    final db = _db;
    if (db == null || _controller.text.trim().isEmpty) return;
    await db.insert('notes', {
      'title': _controller.text.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    _controller.clear();
    await _refresh();
  }

  Future<void> _remove(int i) async {
    final db = _db;
    final id = _notes[i].id;
    if (db == null || id == null) return;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'sqflite roda nativamente em mobile.\n\n'
            'Pra Web, use sqflite_common_ffi_web — fora do escopo da aula.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_db == null) return const Center(child: CircularProgressIndicator());
    return _CrudView(
      controller: _controller,
      hint: 'Tabela: notes (id, title, created_at)',
      notes: _notes,
      onAdd: _add,
      onRemove: _remove,
    );
  }
}

class _CrudView extends StatelessWidget {
  const _CrudView({
    required this.controller,
    required this.hint,
    required this.notes,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final String hint;
  final List<Note> notes;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: onAdd, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? const Center(child: Text('Sem registros'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final n = notes[i];
                    return Dismissible(
                      key: ValueKey('${n.id ?? n.title}_${n.createdAt.millisecondsSinceEpoch}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => onRemove(i),
                      background: Container(
                        color: Colors.red.shade100,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      child: ListTile(
                        title: Text(n.title),
                        subtitle: Text(n.createdAt.toString().substring(0, 19)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

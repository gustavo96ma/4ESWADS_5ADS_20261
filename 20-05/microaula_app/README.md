# microaula_app — 20/05

Demo da micro aula sobre os 3 tópicos pendentes do projeto Mobile:

1. **Cache local** — `shared_preferences`, Hive, sqflite
2. **Compartilhar via OS** — `share_plus`
3. **Deploy híbrido** — `kIsWeb` + UI condicional (mobile vs web admin)

## Como rodar

```bash
flutter pub get

# Mobile (Android/iOS) — todas as 3 demos
flutter run

# Web (Chrome) — sqflite cai em fallback ("só mobile")
flutter run -d chrome
```

## Estrutura

```
lib/
├── main.dart                  # GoRouter com 4 rotas (home + 3 demos)
├── models/
│   └── note.dart              # Modelo compartilhado + TypeAdapter Hive (manual)
└── ui/screens/
    ├── cache_demo.dart        # TabBar: shared_prefs · Hive · sqflite
    ├── share_demo.dart        # share_plus: texto, link, arquivo gerado, imagem
    └── hybrid_demo.dart       # Detecta plataforma + GridView responsivo
```

## Notas pra estudo

- **Hive sem build_runner.** O `NoteAdapter` em `models/note.dart` é escrito à mão pra evitar `dart run build_runner build` na aula. Em produção use `@HiveType` + gerador.
- **sqflite em web.** Requer `sqflite_common_ffi_web` + service worker. Ficou de fora pra manter o demo enxuto — a aba mostra mensagem informativa em `kIsWeb`.
- **share_plus.** Em desktop/web alguns canais podem não funcionar (depende do OS/browser). Mobile cobre todos.
- **Layout responsivo.** `hybrid_demo` usa `MediaQuery.sizeOf` + breakpoint `>=720` pra decidir entre 1 ou 2 colunas. `kIsWeb` muda o banner.

## Aula complementar

Material em Markdown: [`Planner/Projetos/UNICV Aulas/micro-aula-mobile-pendentes.md`](https://github.com/) (vault privado).

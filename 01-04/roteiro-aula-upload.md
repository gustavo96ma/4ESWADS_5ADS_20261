# Roteiro de Aula: Upload de Arquivos em Flutter

**Turmas:** 4 ESW / 4 ADS / 5 ADS
**Pre-requisito:** Projeto `beeceptor_app` com CRUD de posts funcionando
**Branch:** `feature/aula-upload-arquivos`
**Duracao estimada:** ~55 minutos

---

## Visao Geral da Aula

```
Fluxo do que vamos construir:

  [Galeria / Camera / Arquivo]      <-- Selecao (image_picker / file_picker)
            |
       [Preview + Tamanho]          <-- Validacao local
            |
      [FormData + MultipartFile]    <-- Empacotamento (Dio)
            |
     [POST multipart/form-data]    <-- Envio com progresso
            |
   [URL do arquivo no servidor]    <-- Resposta da API
```

**Conceito-chave da aula:** Ate agora enviamos JSON para a API. Hoje vamos enviar **arquivos binarios** (fotos, PDFs). Isso exige um formato diferente: `multipart/form-data`.

---

## FASE 1 — Setup (~5 min)

### O que fazer

Abrir o terminal no projeto `beeceptor_app` e instalar as dependencias:

```bash
flutter pub add image_picker file_picker
```

### O que explicar

> "Vamos usar dois pacotes diferentes. Por que dois e nao um so?"

- **`image_picker`** — acessa a **camera** e a **galeria de fotos** do celular. Usa o picker nativo do sistema (PHPicker no iOS, Photo Picker no Android 13+). Serve para fotos e videos.

- **`file_picker`** — acessa o **sistema de arquivos** do dispositivo. Serve para qualquer tipo de arquivo: PDF, DOCX, planilhas, etc. Usa o Document Picker nativo.

> "Sao complementares. Um app real de upload geralmente precisa dos dois."

### Permissoes de plataforma

**iOS** — Abrir `ios/Runner/Info.plist` e adicionar antes do `</dict>` final:

```xml
<key>NSCameraUsageDescription</key>
<string>Este app precisa acessar a camera para tirar fotos para upload.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Este app precisa acessar suas fotos para selecionar imagens para upload.</string>
```

> "No iOS, se voce nao declarar essas chaves, o app **crasha** — nao da erro bonito, ele simplesmente fecha. O texto entre as tags `<string>` e o que o usuario ve no popup de permissao."

**Android** — Abrir `android/app/src/main/AndroidManifest.xml` e adicionar antes do `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

> "No Android 13+, nao precisamos de permissao de storage. O `image_picker` usa o Photo Picker do sistema, que ja tem acesso sandbox. O `file_picker` usa o SAF (Storage Access Framework). Mas a camera ainda precisa de permissao explicita."

### Verificar

```bash
flutter pub get
```

Deve rodar sem erros.

---

## FASE 2 — Selecionar imagem da galeria e exibir preview (~15 min)

### Passo 2.1 — Criar a tela basica

Criar `lib/ui/screens/upload_page.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _picker = ImagePicker();

  File? _selectedFile;
  String? _selectedFileName;
  bool _isImage = false;

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
        _isImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload de Arquivos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Escolher da Galeria'),
            ),
            const SizedBox(height: 24),
            if (_selectedFile != null && _isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 12),
              Text(_selectedFileName!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
```

### O que explicar enquanto digita

> **`ImagePicker()`** — "Criamos uma instancia do picker. Ela e reutilizavel, entao guardamos como campo da classe."

> **`pickImage(source: ImageSource.gallery)`** — "Isso abre o picker nativo do sistema. No iOS abre o PHPicker, no Android o Photo Picker. O usuario escolhe a foto e o metodo retorna um `XFile`."

> **`XFile`** — "E um wrapper cross-platform que tem o `path` (caminho no disco) e o `name` (nome do arquivo). Nao e um `File` do `dart:io`, entao convertemos: `File(image.path)`."

> **Compressao automatica** — Pausar aqui e destacar:

```dart
maxWidth: 1920,    // redimensiona se maior que 1920px de largura
maxHeight: 1080,   // redimensiona se maior que 1080px de altura
imageQuality: 85,  // compressao JPEG (0-100), 85 = boa qualidade
```

> "Uma foto de celular moderno tem 4-12 MB. Com esses parametros, cai para 200-500 KB. Isso e **essencial** em producao: economiza banda do usuario, reduz tempo de upload, e o servidor nao precisa reprocessar."

> **`mounted`** — "O picker abre uma tela nativa. O usuario pode demorar, trocar de app, etc. Quando ele volta, a nossa widget pode ja ter sido destruida. O `mounted` verifica se ela ainda existe antes de chamar `setState`."

### Passo 2.2 — Conectar a rota e o botao na home

**`lib/main.dart`** — Adicionar import e rota:

```dart
import 'package:beeceptor_app/ui/screens/upload_page.dart';

// Dentro de routes: [], como irmao de '/posts':
GoRoute(
  path: '/upload',
  builder: (BuildContext context, GoRouterState state) {
    return const UploadPage();
  },
),
```

**`lib/ui/screens/home_page.dart`** — Trocar "Botao 2":

```dart
TextIconButton(
  text: 'Upload de Arquivos',
  icon: Icons.cloud_upload,
  onPressed: () => context.go('/upload'),
),
```

### Testar agora

```bash
flutter run
```

1. Abrir o app
2. Clicar em "Upload de Arquivos"
3. Clicar em "Escolher da Galeria"
4. Selecionar uma foto
5. **Resultado esperado:** foto aparece na tela com o nome embaixo

> No simulador iOS: funciona normalmente (tem fotos de exemplo)
> No emulador Android: funciona normalmente

---

## FASE 3 — Adicionar camera e file picker (~10 min)

### Passo 3.1 — Botao de camera

Adicionar na classe `_UploadPageState`:

```dart
Future<void> _pickFromCamera() async {
  final XFile? photo = await _picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  if (photo != null && mounted) {
    setState(() {
      _selectedFile = File(photo.path);
      _selectedFileName = photo.name;
      _isImage = true;
    });
  }
}
```

### O que explicar

> "E praticamente o mesmo codigo, so muda `ImageSource.gallery` para `ImageSource.camera`. O plugin cuida de abrir a camera nativa, pedir permissao, e retornar a foto."

> **Simulador iOS:** "Nao tem camera. O `pickImage` retorna `null` e o nosso `if (photo != null)` cuida disso — nada quebra. Para testar camera, use um dispositivo fisico."

### Passo 3.2 — File picker para documentos

Adicionar import e metodo:

```dart
import 'package:file_picker/file_picker.dart';

Future<void> _pickFile() async {
  final result = await FilePicker.pickFiles();
  if (result != null && result.files.single.path != null && mounted) {
    final platformFile = result.files.single;
    setState(() {
      _selectedFile = File(platformFile.path!);
      _selectedFileName = platformFile.name;
      _isImage = false;
    });
  }
}
```

### O que explicar

> **`FilePicker.pickFiles()`** — "Abre o picker de documentos do sistema. O usuario pode escolher um PDF, DOCX, planilha, qualquer coisa."

> **`PlatformFile`** — "Diferente do `XFile` do image_picker. Tem `path`, `name`, `size` (em bytes), e `extension`."

> **`_isImage = false`** — "Precisamos saber se e imagem ou nao para decidir se mostramos `Image.file()` ou um icone generico no preview."

### Passo 3.3 — Adicionar os dois botoes no build

```dart
OutlinedButton.icon(
  onPressed: _pickFromCamera,
  icon: const Icon(Icons.camera_alt),
  label: const Text('Tirar Foto'),
),
const SizedBox(height: 12),
OutlinedButton.icon(
  onPressed: _pickFile,
  icon: const Icon(Icons.attach_file),
  label: const Text('Escolher Arquivo'),
),
```

E no preview, tratar o caso nao-imagem:

```dart
if (_selectedFile != null)
  if (_isImage)
    Image.file(_selectedFile!, height: 200, fit: BoxFit.cover)
  else
    const Icon(Icons.insert_drive_file, size: 64),
```

### Testar agora

1. Testar galeria — deve mostrar preview da imagem
2. Testar camera — no dispositivo fisico, tira foto e mostra
3. Testar arquivo — selecionar um PDF, deve mostrar icone generico + nome

---

## FASE 4 — Service e Provider para upload (~15 min)

### O que explicar antes de codar

> **"Ate agora so selecionamos o arquivo. Agora vamos ENVIAR para uma API. Qual a diferenca de enviar um arquivo vs enviar JSON?"**

Desenhar no quadro ou mostrar:

```
JSON (o que ja fizemos):
POST /posts
Content-Type: application/json
{"title": "Ola", "body": "Mundo"}

ARQUIVO (o que vamos fazer):
POST /files/upload
Content-Type: multipart/form-data; boundary=----abc123
------abc123
Content-Disposition: form-data; name="file"; filename="foto.jpg"
Content-Type: image/jpeg
[bytes binarios da imagem]
------abc123--
```

> "O `multipart/form-data` divide a requisicao em partes. Cada parte pode ser texto OU binario. E o mesmo formato que um `<form>` HTML usa quando tem `<input type="file">`."

> "O Dio cuida de montar isso automaticamente. Nos so precisamos usar `FormData` e `MultipartFile` em vez de um `Map<String, dynamic>`."

### Passo 4.1 — Model

Criar `lib/models/upload_result.dart`:

```dart
class UploadResult {
  final String originalName;
  final String fileName;
  final String location;

  UploadResult({
    required this.originalName,
    required this.fileName,
    required this.location,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      originalName: json['originalname'] ?? '',
      fileName: json['filename'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalname': originalName,
      'filename': fileName,
      'location': location,
    };
  }
}
```

### O que explicar

> "Mesmo padrao do `Post`: construtor, `fromJson`, `toJson`. O `?? ''` e uma boa pratica — se a API omitir um campo, nao crasha com `TypeError`."

> "A API que vamos usar (Platzi Fake Store) retorna esses 3 campos: `originalname`, `filename`, e `location` (URL do arquivo no servidor)."

### Passo 4.2 — Service

Criar `lib/services/upload_service.dart`:

```dart
import 'package:beeceptor_app/models/upload_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadService {
  final Dio _dio;
  final String _baseUrl = 'https://api.escuelajs.co/api/v1/files/upload';

  UploadService(this._dio);

  Future<UploadResult> uploadFile(
    String filePath,
    String fileName, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post(
      _baseUrl,
      data: formData,
      onSendProgress: onSendProgress,
    );

    debugPrint('UPLOAD RESPONSE: ${response.data}');
    return UploadResult.fromJson(response.data);
  }
}
```

### O que explicar (PAUSAR E DETALHAR CADA LINHA)

> **`UploadService(this._dio)`** — "Mesmo padrao do `PostsService`. Recebe o Dio por injecao de dependencia, nao cria o proprio."

> **`FormData.fromMap({...})`** — "Equivalente ao `post.toJson()` que ja usamos, mas para multipart. O Dio ve que o body e um `FormData` e automaticamente seta o `Content-Type: multipart/form-data`. Nao precisamos setar header manualmente."

> **`MultipartFile.fromFile(filePath, filename: fileName)`** — "Le o arquivo do disco em STREAMING — nao carrega tudo na memoria de uma vez. Isso e importante para arquivos grandes. Se usassemos `fromBytes()`, um arquivo de 50 MB iria para a RAM toda."

> **`onSendProgress`** — "Callback que o Dio chama conforme os bytes vao sendo enviados. Recebe `sent` (bytes enviados ate agora) e `total` (total de bytes). Vamos usar isso para a barra de progresso."

> **Sem try/catch** — "O service NUNCA trata erros. Quem trata e o Provider. Mesmo padrao do `PostsService`."

### Passo 4.3 — Provider

Criar `lib/providers/upload_provider.dart`:

```dart
import 'package:beeceptor_app/models/upload_result.dart';
import 'package:beeceptor_app/services/upload_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadProvider extends ChangeNotifier {
  final UploadService _uploadService;
  UploadProvider(this._uploadService);

  UploadResult? _result;
  UploadResult? get result => _result;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double _progress = 0.0;
  double get progress => _progress;

  Future<void> upload(String filePath, String fileName) async {
    _isLoading = true;
    _error = null;
    _progress = 0.0;
    _result = null;
    notifyListeners();

    try {
      _result = await _uploadService.uploadFile(
        filePath,
        fileName,
        onSendProgress: (sent, total) {
          _progress = sent / total;
          notifyListeners();
        },
      );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          _error = 'Tempo limite excedido. Verifique sua conexao.';
          break;
        case DioExceptionType.connectionError:
          _error = 'Sem conexao com a internet.';
          break;
        case DioExceptionType.badResponse:
          _error = 'Erro do servidor: ${e.response?.statusCode}';
          break;
        default:
          _error = 'Erro de rede: ${e.message}';
      }
    } catch (e) {
      _error = 'Erro inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _result = null;
    _error = null;
    _progress = 0.0;
    notifyListeners();
  }
}
```

### O que explicar

> **`_progress = 0.0`** — "Campo novo que nao tinha no `PostsProvider`. Vai de 0.0 a 1.0. Resetamos para 0.0 no inicio de cada upload — se nao fizer isso, o segundo upload comeca visualmente em 100%."

> **`notifyListeners()` dentro do `onSendProgress`** — "A cada pedaco de bytes enviado, atualizamos o progresso e notificamos a UI. E isso que faz a barra de progresso animar em tempo real."

> **`on DioException catch (e)`** — "Diferente do `PostsProvider` que so tem `catch (e)`. Aqui tratamos o `DioException` especificamente para dar mensagens claras ao usuario: 'Sem conexao', 'Tempo limite', 'Erro do servidor 500'. O `catch (e)` generico pega qualquer outro erro inesperado."

> **`clearResult()`** — "Reseta tudo para o usuario poder enviar outro arquivo sem precisar sair e voltar da tela."

### Passo 4.4 — Registrar no main.dart

Adicionar imports e provider no `MultiProvider`:

```dart
import 'package:beeceptor_app/providers/upload_provider.dart';
import 'package:beeceptor_app/services/upload_service.dart';

// Dentro de providers: []
ChangeNotifierProvider<UploadProvider>(
  create: (context) => UploadProvider(UploadService(context.read<Dio>())),
),
```

### O que explicar

> "Mesmo padrao de injecao: `Dio -> UploadService -> UploadProvider`. O Dio e compartilhado entre PostsProvider e UploadProvider."

---

## FASE 5 — Conectar o upload com barra de progresso (~10 min)

### Passo 5.1 — Adicionar o botao "Enviar" e o Consumer

Na `upload_page.dart`, adicionar apos o preview:

```dart
// Botao de enviar (so aparece quando tem arquivo selecionado)
Consumer<UploadProvider>(
  builder: (context, provider, _) {
    return FilledButton.icon(
      onPressed: provider.isLoading ? null : _uploadFile,
      icon: const Icon(Icons.send),
      label: Text(provider.isLoading ? 'Enviando...' : 'Enviar Arquivo'),
    );
  },
),
```

E o metodo:

```dart
void _uploadFile() {
  if (_selectedFile == null) return;
  context.read<UploadProvider>().upload(
    _selectedFile!.path,
    _selectedFileName ?? 'file',
  );
}
```

### O que explicar

> **`provider.isLoading ? null : _uploadFile`** — "Passar `null` para `onPressed` desabilita o botao automaticamente no Material 3. Isso impede o usuario de clicar duas vezes e enviar o mesmo arquivo em paralelo."

### Passo 5.2 — Barra de progresso

```dart
Consumer<UploadProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return Column(
        children: [
          LinearProgressIndicator(value: provider.progress),
          Text('${(provider.progress * 100).toStringAsFixed(0)}%'),
        ],
      );
    }
    // ...estados de erro e sucesso
  },
),
```

### O que explicar

> **`LinearProgressIndicator(value: provider.progress)`** — "O `value` aceita 0.0 a 1.0. Como nosso provider calcula `sent / total` que ja esta nesse range, e direto. Se passar `null`, a barra fica indeterminada (animacao infinita)."

> **Por que a barra anima?** — "Porque no provider, cada vez que `onSendProgress` dispara, chamamos `notifyListeners()`. O `Consumer` reconstroi, pega o novo valor de `progress`, e o Flutter redesenha a barra. Isso acontece varias vezes por segundo."

### Passo 5.3 — Estado de sucesso

```dart
if (provider.result != null) {
  return Column(
    children: [
      const Icon(Icons.check_circle, color: Colors.green, size: 48),
      const Text('Arquivo enviado com sucesso!'),
      SelectableText(provider.result!.location),
    ],
  );
}
```

### O que explicar

> **`SelectableText`** — "O usuario pode copiar a URL do arquivo. Util para verificar se o upload realmente funcionou — e so colar no navegador."

> **`provider.result!.location`** — "A API retorna a URL real onde o arquivo ficou hospedado. Isso prova que o upload foi real, nao so um mock."

### Testar agora (DEMONSTRACAO FINAL)

1. Selecionar uma foto da galeria
2. Clicar "Enviar Arquivo"
3. **Ver a barra de progresso animando de 0% a 100%**
4. Ver a mensagem de sucesso com a URL
5. Copiar a URL e abrir no navegador — a imagem aparece!
6. Testar com um PDF — mesmo fluxo, URL diferente

### Teste de erro (bonus)

1. Ativar modo aviao no dispositivo/simulador
2. Tentar enviar
3. **Ver a mensagem "Sem conexao com a internet"** em vez de um stacktrace feio
4. Clicar "Tentar novamente" apos reconectar

---

## Conceitos-Chave para Revisao Final (~5 min)

### Quadro comparativo (desenhar no quadro)

```
| CRUD de Posts (ja fizemos)     | Upload de Arquivos (hoje)        |
|-------------------------------|----------------------------------|
| Content-Type: application/json| Content-Type: multipart/form-data|
| body: post.toJson()           | body: FormData + MultipartFile    |
| Resposta: JSON do post        | Resposta: JSON com URL do arquivo|
| Sem progresso (dado pequeno)  | onSendProgress (arquivo grande)  |
| image_picker nao precisa      | image_picker + file_picker       |
| Sem permissoes especiais      | Camera + Galeria (iOS/Android)   |
```

### Best practices mencionadas na aula

1. **Compressao no cliente** — `maxWidth`, `maxHeight`, `imageQuality` reduzem 4-12 MB para 200-500 KB
2. **Validacao de tamanho** — checar antes de enviar, nao depender so do servidor
3. **`MultipartFile.fromFile`** (streaming) vs `fromBytes` (tudo na memoria) — sempre preferir streaming
4. **`mounted` check** — sempre verificar apos operacoes async que abrem telas nativas
5. **`retrieveLostData()`** — Android pode matar a Activity durante o picker
6. **Tratamento de `DioException`** — mensagens claras por tipo de erro
7. **Desabilitar botao durante upload** — `onPressed: null` no Material 3

---

## Estrutura Final de Arquivos

```
lib/
├── main.dart                          # + UploadProvider + rota /upload
├── models/
│   ├── post.dart                      # (existente)
│   └── upload_result.dart             # NOVO
├── services/
│   ├── posts_service.dart             # (existente)
│   └── upload_service.dart            # NOVO
├── providers/
│   ├── posts_provider.dart            # (existente)
│   └── upload_provider.dart           # NOVO
└── ui/
    ├── screens/
    │   ├── home_page.dart             # MODIFICADO (novo botao)
    │   ├── posts_page.dart            # (existente)
    │   ├── post_detail_page.dart      # (existente)
    │   └── upload_page.dart           # NOVO
    └── widgets/
        ├── post_form_dialog.dart      # (existente)
        └── text_icon_button.dart      # (existente)
```

---

## Perguntas Frequentes dos Alunos

**"Posso usar so o `file_picker` pra tudo?"**
> Pode, mas ele nao abre a camera. E o `image_picker` da compressao de graca com `imageQuality`.

**"Preciso do `permission_handler`?"**
> Para este caso, nao. Os plugins `image_picker` e `file_picker` pedem permissao automaticamente quando voce chama `pickImage` / `pickFiles`. Mas em apps mais complexos (ex: verificar permissao ANTES de mostrar o botao), ai sim voce usaria.

**"E se a API nao aceitar o tipo do arquivo?"**
> Em producao, voce validaria no cliente (extensao + tamanho) E no servidor. Nunca confie so na validacao do cliente — o usuario pode burlar.

**"Como faco upload de MULTIPLOS arquivos?"**
> `FormData` aceita uma lista de `MultipartFile`. O `file_picker` tem `allowMultiple: true`. Isso fica pra proxima aula ou pro trabalho.

**"Funciona na web?"**
> Sim, mas `MultipartFile.fromFile` nao funciona na web (nao tem `dart:io`). Precisa usar `MultipartFile.fromBytes()` com os bytes que o picker retorna. Hoje focamos em mobile.

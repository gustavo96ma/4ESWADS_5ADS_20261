# Debug: Feature de Upload de Arquivos

## Contexto

A feature de upload de arquivos foi implementada no commit `353760f` ("22-04") e adicionou:

- `lib/models/upload_result.dart`
- `lib/services/upload_service.dart`
- `lib/providers/upload_provider.dart`
- `lib/ui/screens/upload_page.dart`
- Rota `/upload` e injeção do `UploadProvider` em `lib/main.dart`

Sintoma reportado pelo usuário: **"não funcionou, parece que não tá chegando no service"**.

Após investigação cuidadosa, a chamada **provavelmente chega ao service** — mas dois bugs combinados produzem exatamente o sintoma de "não acontece nada":

1. Em caso de **sucesso**, um `TypeError` no `debugPrint` **aborta antes do `return`**, fazendo `_result` ficar `null`.
2. Em caso de **erro**, o `error` do provider nunca é exibido na UI (não há `Consumer` para ele).

Resultado: independente de sucesso ou falha, a UI fica visualmente igual a "nada aconteceu".

---

## Bugs identificados

### Bug 1 — `lib/services/upload_service.dart:26` — `TypeError` em runtime no caminho feliz

```dart
final response = await _dio.post(
  _baseUrl,
  data: formData,
  onSendProgress: onSendProgress,
);

debugPrint(response.data);   // ❌ response.data é Map<String, dynamic>; debugPrint exige String?
```

Em runtime isso lança `type 'IdentityMap<String, dynamic>' is not a subtype of type 'String?'` **antes** do `return UploadResult.fromJson(...)`. A exceção sobe para o `catch (e)` do provider (não é `DioException`, então cai no `catch` genérico) e o `_result` permanece `null`. O usuário vê o spinner desaparecer e nada mais — exatamente "parece que não chegou no service".

**Por que o `flutter analyze` não pega**: `debugPrint` aceita `Object?` na assinatura efetiva via inferência de tipo dinâmica do `response.data` (que é `dynamic`), então o type checker não reclama. O erro só aparece em runtime.

**Correção**:

```dart
debugPrint(response.data.toString());
```

---

### Bug 2 — `lib/providers/upload_provider.dart:38-51` — switch case quebrado

```dart
} on DioException catch (e) {
  switch (e.type) {
    case DioException.connectionTimeout:   // ❌ tear-off de factory, não DioExceptionType
    case DioExceptionType.sendTimeout:
      _error = 'Tempo limite excedido. Verifique sua conexão';
      break;
    case DioException.connectionError:     // ❌ idem
      _error = 'Sem conexão com a internet';
      break;
    case DioException.badResponse:         // ❌ idem
      _error = 'Erro do servidor: ${e.response?.statusCode}';
                                           // ❌ falta break aqui
    default:
      _error = 'Erro de rede: ${e.message}';
  }
}
```

`e.type` é `DioExceptionType` (enum). `DioException.connectionTimeout` é uma **factory constructor** que retorna `DioException` (verificado em `~/.pub-cache/hosted/pub.dev/dio-5.9.2/lib/src/dio_exception.dart:96`). O tear-off da factory **nunca dá match** com um valor do enum, então qualquer erro de rede cai no `default`.

Além disso, o `case DioException.badResponse:` não tem `break`, causando fall-through para o `default` e sobrescrevendo `_error`.

**Correção**:

```dart
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
      _error = 'Tempo limite excedido. Verifique sua conexão';
      break;
    case DioExceptionType.connectionError:
      _error = 'Sem conexão com a internet';
      break;
    case DioExceptionType.badResponse:
      _error = 'Erro do servidor: ${e.response?.statusCode}';
      break;
    default:
      _error = 'Erro de rede: ${e.message}';
  }
}
```

---

### Bug 3 — `lib/providers/upload_provider.dart:53` — chave extra na mensagem

```dart
_error = 'Erro inesperado $e}';   // ❌ '}' sobrando
```

**Correção**:

```dart
_error = 'Erro inesperado: $e';
```

---

### Bug 4 — `lib/ui/screens/upload_page.dart` — UI não mostra `error`

O arquivo tem três `Consumer<UploadProvider>`:

- linha 125-135 → botão "Enviar Arquivo"
- linha 136-148 → progresso
- linha 149-166 → resultado de sucesso

**Não existe Consumer para `provider.error`.** Quando o upload falha, o erro é gravado no provider mas nunca renderizado. Esta é a causa direta do sintoma "não acontece nada".

**Correção**: adicionar um quarto `Consumer<UploadProvider>` logo após o de `result`:

```dart
Consumer<UploadProvider>(
  builder: (context, provider, _) {
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  },
),
```

---

### Bug 5 — `lib/ui/screens/upload_page.dart:128` — botão habilitado sem arquivo

```dart
onPressed: provider.isLoading ? null : _uploadFile,
```

Quando `_selectedFile == null`, o botão fica clicável mas `_uploadFile()` faz `return` silencioso (linha 72). Reforça a sensação de "nada acontece".

**Correção**:

```dart
onPressed: (provider.isLoading || _selectedFile == null) ? null : _uploadFile,
```

---

### Bug 6 — `lib/ui/screens/upload_page.dart:9` — TODO obsoleto

```dart
//TODO: debuggar pra encontrar o erro que não está dando sucesso ao fazer upload
```

Remover após corrigir os bugs acima.

---

## Resumo das mudanças por arquivo

| Arquivo                              | Mudanças                                                                                              |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `lib/services/upload_service.dart`   | 1 linha: `response.data` → `response.data.toString()`                                                 |
| `lib/providers/upload_provider.dart` | 3 cases: `DioException.X` → `DioExceptionType.X`; +1 `break`; corrigir string `'Erro inesperado $e}'` |
| `lib/ui/screens/upload_page.dart`    | +1 Consumer para erro; ajustar `onPressed` do botão; remover TODO                                     |

Total: ~25 linhas de mudança em 3 arquivos. Sem novas dependências, sem mudanças no `main.dart` ou em rotas.

---

## Verificação end-to-end

1. **Static check**: `flutter analyze` — deve continuar limpo.
2. **Build/run**: `flutter run` em emulador ou dispositivo físico.
3. **Caminho feliz** (rede OK, com arquivo selecionado):
   - Home → "Upload de Arquivos" → "Galeria" → escolher imagem.
   - Clicar "Enviar Arquivo" → ver `LinearProgressIndicator` avançar de 0% a 100%.
   - Ver ícone verde + "Arquivo enviado com sucesso!" + `location` da API.
   - Conferir no console que `debugPrint` imprime o JSON da resposta como string.
4. **Caminho de erro de rede** (sem internet):
   - Desligar Wi-Fi/dados → tentar upload → ver mensagem **vermelha visível** ("Sem conexão com a internet" ou similar).
5. **Caminho sem seleção**:
   - Abrir a tela sem selecionar arquivo → botão "Enviar Arquivo" deve estar **desabilitado** (cinza, não clicável).
6. **Caminho de erro do servidor** (opcional): trocar temporariamente `_baseUrl` por uma URL inválida (`https://api.escuelajs.co/api/v1/files/upload-fake`) → confirmar que aparece "Erro do servidor: 404" em vermelho.

---

## Observações

- A API `https://api.escuelajs.co/api/v1/files/upload` (Platzi Fake API) é pública e ocasionalmente instável. Após as correções, qualquer falha do backend ficará **visível na UI**, tornando o próximo passo de debug trivial (basta ler a mensagem).
- As permissões `INTERNET` em `android/app/src/main/AndroidManifest.xml` (release) **não estão declaradas**, mas estão presentes em `debug/` e `profile/`. Isso só afeta builds de release — fora do escopo deste debug, mas vale registrar.

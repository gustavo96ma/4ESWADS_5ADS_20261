import 'carro.dart';
import 'jipe.dart';

void main() {
  // Escreve "Hello world" no console
  print('Hello world');

  // Exemplo de declaração e impressão de uma string
  String texto = 'Exemplo de string em Dart';
  print(texto);

  // Exemplo de declaração e impressão de um número inteiro
  int numero = 42;
  print('O número é: $numero');

  // Exemplo de declaração e impressão de um valor booleano
  bool verdadeiro = true;
  print('O valor booleano é: $verdadeiro');

  // Exemplo de declaração e impressão de um número decimal
  double decimal = 3.14;
  print('O dinheiro que eu tenho é: R\$$decimal');

  // Exemplo de declaração de um bloco condicional IF
  if (numero == 43) {
    print('O número vale 43!');
  } else if (numero == 42) {
    print('O número vale 42!');
  } else {
    print('Nenhuma condição foi satisfeita');
  }

  // Exemplo de declaração de um bloco condicional SWITCH CASE
  switch (numero) {
    case >= 42:
      print('O número vale 42');
      break;

    case 42:
      print('O número vale 43');
      break;

    case 44:
      print('O número vale 43');
      break;

    default:
      print('O número não vale nada!');
      break;
  }

  // Exemplo de declaração de um bloco de repetição FOR SIMPLES
  for (int i = 0; i < 99; i++) {
    print(i);
  }

  for (var element in [0, 1, 2, 3, 4]) {
    print(element);
  }

  [0, 1, 2, 3, 4].forEach((element) {
    print(element);
    print(element * 2);
  });

  // Exemplo de declaração de uma Lista (Array)
  List<int> lista = [0, 1, 2, 3, 4];

  // Exemplo de declaração de uma Mapa (Dicionário)
  Map<String, int> dicionario = {'chave': numero, 'outraChave': 9};
  print(dicionario['outraChave']);

  // Dart by example -> recomendacao

  //
  Carro carro = Carro(ano: 1988, modelo: 'Fusca', 10000);
  print(carro.ano);
  print(carro.modelo);
  print(carro.buzinar());
  print(carro.buzinar());
  print('${carro.buzinar()}, ${carro.buzinar()}');

  Jipe jipe = Jipe(ano: 2010, modelo: 'Jeep Compass', 10000);
  print(jipe.buzinar());
  print('A potência do carro é ${jipe.potencia}');
  print(jipe.tracionar());
  print('A potência do carro é ${jipe.potencia}');
}

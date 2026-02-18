import 'carro.dart';

class Jipe extends Carro {
  Jipe(super.potencia, {required super.modelo, required super.ano});

  @override
  String buzinar() {
    return 'Foo';
  }

  String tracionar() {
    super.potencia += 10000;
    return '4x4 Ativado';
  }
}

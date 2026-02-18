class Carro {
  Carro(this.potencia, {required this.modelo, required this.ano});

  String modelo;
  int ano;
  int potencia;

  String buzinar() {
    return 'Bii';
  }
}

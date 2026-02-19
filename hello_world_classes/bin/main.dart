void main() {
  EscolaDeSamba escolaDeSamba = EscolaDeSamba(
    nome: 'Maringá Maringá',
    numeroDeIntegrantes: 17,
    cores: ['verde', 'dourado', 'branco'],
  );

  EscolaDeSamba escolaComRainha = EscolaComRainha(
    nome: 'Unidos da Vila',
    numeroDeIntegrantes: 30,
    cores: ['azul', 'branco'],
    rainha: 'Juliana Paes',
  );

  // Polimorfismo: ambas são EscolaDeSamba, mas comportamentos diferentes
  List<EscolaDeSamba> escolas = [escolaDeSamba, escolaComRainha];
  for (var escola in escolas) {
    print(escola.toString());
    print('Nota: ${escola.nota()}');
    print('---');
  }
}

class EscolaDeSamba {
  String nome;
  int numeroDeIntegrantes;
  List<String> cores;

  EscolaDeSamba({
    required this.nome,
    required this.numeroDeIntegrantes,
    required this.cores,
  });

  // Método que pode ser sobrescrito
  String? get rainhaDeBateria => null;

  // Método polimórfico
  double nota() {
    // Nota padrão
    return numeroDeIntegrantes * 0.5;
  }

  @override
  String toString() {
    return 'EscolaDeSamba(\n nome: $nome,\n numeroDeIntegrantes: $numeroDeIntegrantes, \n cores: $cores, \n rainhaDeBateria: $rainhaDeBateria \n)';
  }
}

// Herança: EscolaComRainha herda de EscolaDeSamba
class EscolaComRainha extends EscolaDeSamba {
  final String rainha;

  EscolaComRainha({
    required super.nome,
    required super.numeroDeIntegrantes,
    required super.cores,
    required this.rainha,
  });

  @override
  String get rainhaDeBateria => rainha;

  // Polimorfismo: sobrescreve o método nota
  @override
  double nota() {
    // Escola com rainha tem bônus
    return super.nota() + 10;
  }

  @override
  String toString() {
    return 'EscolaComRainha(\n nome: $nome,\n numeroDeIntegrantes: $numeroDeIntegrantes, \n cores: $cores, \n rainhaDeBateria: $rainha \n)';
  }
}

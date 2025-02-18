import 'dart:io';
import 'dart:math';

void main() {
  // Exibir mensagem de boas-vindas
  print('Bem-vindo ao Jogo de Pedra-Papel-Tesoura!');
  
  // Opções de escolha
  var opcoes = ['Pedra', 'Papel', 'Tesoura'];
  
  // Jogador escolhe a opção
  print('Escolha uma opção: 0 = Pedra, 1 = Papel, 2 = Tesoura');
  int? escolhaJogador = int.tryParse(stdin.readLineSync()!);

  // Verifica se a entrada do jogador é válida
  if (escolhaJogador == null || escolhaJogador < 0 || escolhaJogador > 2) {
    print('Escolha inválida. Por favor, escolha entre 0, 1 ou 2.');
    return;
  }

  // Computador escolhe aleatoriamente
  var escolhaComputador = Random().nextInt(3);

  // Exibe as escolhas
  print('Você escolheu: ${opcoes[escolhaJogador]}');
  print('O computador escolheu: ${opcoes[escolhaComputador]}');

  // Determina o vencedor
  if (escolhaJogador == escolhaComputador) {
    print('Empate!');
  } else if ((escolhaJogador == 0 && escolhaComputador == 2) ||
      (escolhaJogador == 1 && escolhaComputador == 0) ||
      (escolhaJogador == 2 && escolhaComputador == 1)) {
    print('Você ganhou!');
  } else {
    print('O computador ganhou!');
  }
}

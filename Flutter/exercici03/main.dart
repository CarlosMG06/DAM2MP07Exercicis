import 'dart:io';
import './game.dart';

void main() {
    Game gameInstance = Game();
    print('--- Joc de Buscamines ---');

    while (true) {
        gameInstance.showBoard();
        stdout.write('Escriu una comanda ("help" o "ajuda" per ajuda): \n> ');
        String? input = stdin.readLineSync();
        if (input == null || input.toLowerCase() == 'exit' || input.toLowerCase() == 'sortir') {
            print('Sortint del joc. Fins aviat!');
            break;
        }
        bool lose = parseCommand(input, gameInstance);
        if (lose) {
            gameInstance.gameOver();
            gameInstance.showBoard();
            print('Has perdut!');
            print('Número de tirades: ${gameInstance.tries}');
            break;
        }
        bool win = gameInstance.checkWin();
        if (win) {
            gameInstance.gameOver();
            gameInstance.showBoard();
            print('Has guanyat!');
            print('Número de tirades: ${gameInstance.tries}');
            break;
        }
    }
}

bool parseCommand(command, gameInstance) {
    List<String> parts = command.trim().split(' ');
    String mainCommand = parts[0];
    if (mainCommand == 'help' || mainCommand == 'ajuda') {
        help();
    } else if (mainCommand == 'cheat' || mainCommand == 'trampes') {
        gameInstance.toggleCheatMode();
    } else if (RegExp(r"[A-F]\d").hasMatch(mainCommand)) {
        String position = mainCommand;
        int y = position.codeUnitAt(0) - 'A'.codeUnitAt(0);
        int x = int.parse(position.substring(1));
        if (parts.length > 1 && (parts[1].toLowerCase() == 'flag' || parts[1].toLowerCase() == 'bandera')) {
            gameInstance.toggleFlag(x, y);
        } else {
            bool isFirstMove = gameInstance.tries == 0;
            bool lose = gameInstance.uncoverCell(x, y, isFirstMove);
            return lose;
        }
    } else {
        print('Comanda no reconeguda. Escriu "help" o "ajuda" per veure les comandes disponibles.');
    }
    print('');
    return false;
}

void help() {
    print('''Comandes disponibles:
- help / ajuda: Mostra aquesta ajuda
- Xn - Destapa la casella a la posició Xn (ex: A3)
- Xn flag / Xn bandera - Marca o desmarca la casella a la posició Xn com a mina
- cheat / trampes - Activa o desactiva el mode trampes
- exit / sortir - Surt del joc''');
}

import 'dart:math';

class Cell {
    bool hasMine;
    bool isUncovered;
    bool hasFlag;
    int adjacentMines = 0;

    Cell({this.hasMine = false, this.isUncovered = false, this.hasFlag = false});
}

class Game {
    List<List<Cell>> board = [];
    bool cheat = false;
    List<({int x, int y})> mines = [];
    int tries = 0;
    
    Game() {
        generateBoard();
    }

    void generateBoard() {
        for (var i = 0; i < 6; i++) {
            board.add(List.generate(10, (_) => Cell(), growable: false));
        }
        placeMines();
        calculateAdjacentMines();
    }

    void placeMines() {
        // 8 mines semi-aleatòries: almenys 2 en les quatre meitats (superior, inferior, esquerra i dreta)
        Random rand = Random();
    
        // Funcions auxiliars per comprovar les meitats
        bool inHalf(int x, int y, String half) {
            switch (half) {
            case 'upper': return y <= 2; // A-C
            case 'lower': return y >= 3; // D-F
            case 'left': return x <= 4;  // 0-4
            case 'right': return x >= 5; // 5-9
            default: return false;
            }
        }
        int countInHalf(String half) {
            return mines.where((pos) => inHalf(pos.x, pos.y, half)).length;
        }
        
        // Col·locar mines fins complir les condicions
        while (mines.length < 8 || 
                countInHalf('upper') < 2 ||
                countInHalf('lower') < 2 ||
                countInHalf('left') < 2 ||
                countInHalf('right') < 2) {
            
            // Si ja hi ha 8 mines, però les meitats no compleixen, eliminar la primera mina
            if (mines.length == 8) {
              mines.removeAt(0);
            }
            
            // Afegir nova mina
            var newPos;
            do {
                newPos = (x: rand.nextInt(10), y: rand.nextInt(6));
            } while (mines.contains(newPos));
            mines.add(newPos);
        }
        
        // Col·locar les mines al tauler
        for (var mine in mines) {
            board[mine.y][mine.x].hasMine = true;
        }
    }

    void replaceMine(int oldX, int oldY) {
        // Moure la mina a una posició buida completament aleatòria
        Random rand = Random();
        var newPos;
        do {
            newPos = (x: rand.nextInt(10), y: rand.nextInt(6));
        } while (board[newPos.y][newPos.x].hasMine || (newPos.x == oldX && newPos.y == oldY));
        board[newPos.y][newPos.x].hasMine = true;
        mines.add(newPos);
    }

    void calculateAdjacentMines() {
        for (int y = 0; y < board.length; y++) {
            for (int x = 0; x < board[y].length; x++) {
                if (board[y][x].hasMine) continue;
                int count = 0;
                for (int dy = -1; dy <= 1; dy++) {
                    for (int dx = -1; dx <= 1; dx++) {
                        int adjacentY = y + dy;
                        int adjacentX = x + dx;
                        if (adjacentY >= 0 && adjacentY < board.length &&
                            adjacentX >= 0 && adjacentX < board[y].length &&
                            board[adjacentY][adjacentX].hasMine) {
                            count++;
                        }
                    }
                }
                board[y][x].adjacentMines = count;
            }
        }
    }

    void showBoard() {
        //  0123456789
        // A··········
        // B··········
        // C··········
        // D··········
        // E··········
        // F··········
        String header = ' ';
        for (int i = 0; i < this.board[0].length; i++) {
            header += i.toString();
        }
        print(header);
        for (int y = 0; y < this.board.length; y++) {
            String row = String.fromCharCode('A'.codeUnitAt(0) + y);
            for (int x = 0; x < this.board[y].length; x++) {
                var cell = this.board[y][x];
                if (cell.isUncovered) {
                    if (cell.hasMine) {
                        row += '*';
                    } else {
                        row += cell.adjacentMines > 0 ? cell.adjacentMines.toString() : ' ';
                    }
                } else if (cell.hasFlag) {
                    row += '#';
                } else if (this.cheat && cell.hasMine) {
                    row += '*';
                } else {
                    row += '·';
                }
            }
            print(row);
        }
        print('');
    }

    void toggleCheatMode() {
        this.cheat = !this.cheat;
    }

    void toggleFlag(int x, int y) {
      this.board[y][x].hasFlag = !this.board[y][x].hasFlag;
    }

    bool uncoverCell(int x, int y, [bool isFirstMove = false, bool isUserMove = true]) {
        // Retorna true si el jugador explota una mina, perdent la partida
        if (x < 0 || x >= this.board[0].length || y < 0 || y >= this.board.length) {
            if (isUserMove) {
                print('Posició fora del tauler.');
            }
            return false;
        }
        Cell cell = this.board[y][x];
        if (cell.isUncovered || cell.hasFlag) {
            if (isUserMove) {
                print('Casella ja destapada o marcada amb bandera.');
            }
            return false;
        }

        if (isUserMove) {
            this.tries++;
        }
        cell.isUncovered = true;
        if (cell.hasMine) {
            if (isFirstMove) {
                cell.hasMine = false;
                replaceMine(x, y); // Moure la mina a una altra posició
                calculateAdjacentMines();
                return uncoverCell(x, y); // Reintentar destapar la mateixa casella
            } else if (isUserMove) {
                return true; // Explosió
            } else {
                return false; // No explota durant la recursivitat
            }
        }
        if (cell.adjacentMines == 0) {
            for (int dy = -1; dy <= 1; dy++) {
                for (int dx = -1; dx <= 1; dx++) {
                    if (dx != 0 || dy != 0) {
                        uncoverCell(x + dx, y + dy, false, false);
                    }
                }
            }
        }
        return false; // No explota
    }

    void gameOver() {
        // Mostrar la posició de totes les mines
        for (var pos in mines) {
            board[pos.y][pos.x].isUncovered = true;
        }
        // Treure totes les banderes
        for (var row in board) {
            for (Cell cell in row) {
                cell.hasFlag = false;
            }
        }
    }

    bool checkWin() {
        bool checkAllCellsUncovered() {
            // Retorna true si s'han destapat totes les caselles sense mines 
            for (var row in board) {
                for (Cell cell in row) {
                    if (!cell.hasMine && !cell.isUncovered) {
                        return false;
                    }
                }
            }
            return true;
        }
        bool checkAllMinesFlagged() {
            // Retorna true si s'han marcat amb banderes totes les mines i cap altra casella        
            for (var row in board) {
                for (Cell cell in row) {
                    if ((cell.hasMine && !cell.hasFlag) || 
                      (!cell.hasMine && cell.hasFlag)) {
                        return false;
                    }
                }
            }
            return true;
        }
        return checkAllCellsUncovered() || checkAllMinesFlagged();
    }

    

}

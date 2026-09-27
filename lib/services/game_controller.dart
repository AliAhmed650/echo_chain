import 'package:flutter/foundation.dart';
import '../models/cell_type.dart';
import '../models/recorded_move.dart';
import '../models/echo.dart';

class GameController extends ChangeNotifier {
  final int gridSize;
  final Map<Position, CellType> cells;
  final Position startPosition;

  Position playerPosition;
  int currentStep = 0;
  bool isButtonPressed = false;
  bool isWon = false;

  final List<RecordedMove> _currentRunMoves = [];
  final List<Echo> echoes = [];

  static const int echoDelay = 6;

  GameController({
    required this.gridSize,
    required this.cells,
    required this.startPosition,
  }) : playerPosition = startPosition;

  bool _isWalkable(Position pos) {
    if (pos.x < 0 || pos.x >= gridSize || pos.y < 0 || pos.y >= gridSize) {
      return false;
    }
    final type = cells[pos] ?? CellType.empty;
    if (type == CellType.wall) return false;
    if (type == CellType.door && !isButtonPressed) return false;
    return true;
  }

  void movePlayer(int dx, int dy) {
    if (isWon) return;

    final newPos = playerPosition.move(dx, dy);
    if (!_isWalkable(newPos)) return;

    playerPosition = newPos;
    currentStep++;

    _currentRunMoves.add(
      RecordedMove(stepIndex: currentStep, position: playerPosition),
    );

    _updateEchoes();
    _checkButton();
    _checkGoal();

    notifyListeners();
  }

  void _updateEchoes() {
    for (final echo in echoes) {
      final echoPos = echo.getPositionAtStep(currentStep);
      if (echoPos != null && cells[echoPos] == CellType.button) {
        isButtonPressed = true;
      }
    }
  }

  void _checkButton() {
    if (cells[playerPosition] == CellType.button) {
      isButtonPressed = true;
    }
  }

  void _checkGoal() {
    if (cells[playerPosition] == CellType.goal) {
      isWon = true;
    }
  }

  void dropEcho() {
    if (_currentRunMoves.isEmpty) return;

    echoes.add(Echo(
      recordedMoves: List.from(_currentRunMoves),
      delaySteps: currentStep - _currentRunMoves.length + echoDelay,
    ));

    _currentRunMoves.clear();
    playerPosition = startPosition;

    notifyListeners();
  }

  void resetLevel() {
    playerPosition = startPosition;
    currentStep = 0;
    isButtonPressed = false;
    isWon = false;
    _currentRunMoves.clear();
    echoes.clear();
    notifyListeners();
  }

  List<Position> getActiveEchoPositions() {
    final result = <Position>[];
    for (final echo in echoes) {
      final pos = echo.getPositionAtStep(currentStep);
      if (pos != null) {
        result.add(pos);
      }
    }
    return result;
  }
}
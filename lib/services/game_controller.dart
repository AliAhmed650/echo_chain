import 'package:flutter/foundation.dart';
import '../models/cell_type.dart';
import '../models/recorded_move.dart';
import '../models/echo.dart';
import '../models/level_data.dart';

class GameController extends ChangeNotifier {
  final LevelData level;

  Position playerPosition;
  int currentStep = 0;
  final Set<Position> pressedButtons = {};
  bool isWon = false;

  final List<RecordedMove> _currentRunMoves = [];
  final List<Echo> echoes = [];

  static const int echoDelay = 6;

  GameController({required this.level})
      : playerPosition = level.startPosition;

  int get gridSize => level.gridSize;
  Map<Position, CellType> get cells => level.cells;

  bool get isDoorOpen => pressedButtons.length >= level.requiredButtons;

  bool _isWalkable(Position pos) {
    if (pos.x < 0 || pos.x >= gridSize || pos.y < 0 || pos.y >= gridSize) {
      return false;
    }
    final type = cells[pos] ?? CellType.empty;
    if (type == CellType.wall) return false;
    if (type == CellType.door && !isDoorOpen) return false;
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
    _checkButton(playerPosition);
    _checkGoal();

    notifyListeners();
  }

  void _updateEchoes() {
    for (final echo in echoes) {
      final echoPos = echo.getPositionAtStep(currentStep);
      if (echoPos != null) {
        _checkButton(echoPos);
      }
    }
  }

  void _checkButton(Position pos) {
    if (cells[pos] == CellType.button) {
      pressedButtons.add(pos);
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
    playerPosition = level.startPosition;

    notifyListeners();
  }

  void resetLevel() {
    playerPosition = level.startPosition;
    currentStep = 0;
    pressedButtons.clear();
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
import 'cell_type.dart';
import 'recorded_move.dart';

class LevelData {
  final int id;
  final String name;
  final int gridSize;
  final Map<Position, CellType> cells;
  final Position startPosition;
  final int requiredButtons; // كام زرار لازم يتفتح عشان الباب يفتح

  LevelData({
    required this.id,
    required this.name,
    required this.gridSize,
    required this.cells,
    required this.startPosition,
    this.requiredButtons = 1,
  });
}
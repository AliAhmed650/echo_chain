import '../models/cell_type.dart';
import '../models/level_data.dart';
import '../models/recorded_move.dart';

class LevelsData {
  static List<LevelData> levels = [
    // المستوى 1: نفس اللي عملناه (زرار واحد بسيط)
    LevelData(
      id: 1,
      name: 'البداية',
      gridSize: 5,
      cells: {
        const Position(2, 2): CellType.button,
        const Position(4, 2): CellType.door,
        const Position(4, 0): CellType.goal,
      },
      startPosition: const Position(0, 4),
      requiredButtons: 1,
    ),

    // المستوى 2: زرارين لازم يتفتحوا مع بعض
    LevelData(
      id: 2,
      name: 'زرارين',
      gridSize: 5,
      cells: {
        const Position(0, 2): CellType.button,
        const Position(4, 2): CellType.button,
        const Position(2, 4): CellType.door,
        const Position(2, 0): CellType.goal,
      },
      startPosition: const Position(2, 2),
      requiredButtons: 2,
    ),

    // المستوى 3: ممر ضيق
    LevelData(
      id: 3,
      name: 'المسار الضيق',
      gridSize: 5,
      cells: {
        const Position(0, 4): CellType.button,
        const Position(1, 2): CellType.wall,
        const Position(1, 1): CellType.wall,
        const Position(1, 3): CellType.wall,
        const Position(3, 2): CellType.wall,
        const Position(3, 1): CellType.wall,
        const Position(3, 3): CellType.wall,
        const Position(4, 2): CellType.door,
        const Position(4, 0): CellType.goal,
      },
      startPosition: const Position(0, 0),
      requiredButtons: 1,
    ),

    // المستوى 4: باب مؤقت (بيتقفل تاني)
    LevelData(
      id: 4,
      name: 'سباق الوقت',
      gridSize: 6,
      cells: {
        const Position(2, 3): CellType.button,
        const Position(5, 3): CellType.door,
        const Position(5, 0): CellType.goal,
      },
      startPosition: const Position(0, 5),
      requiredButtons: 1,
    ),

    // المستوى 5: تسلسل أصداء
    LevelData(
      id: 5,
      name: 'صدى الصدى',
      gridSize: 6,
      cells: {
        const Position(1, 4): CellType.button,
        const Position(4, 1): CellType.button,
        const Position(5, 4): CellType.door,
        const Position(5, 0): CellType.goal,
      },
      startPosition: const Position(0, 5),
      requiredButtons: 2,
    ),

    // المستوى 6: التحدي الكبير
    LevelData(
      id: 6,
      name: 'التحدي الكبير',
      gridSize: 6,
      cells: {
        const Position(0, 3): CellType.button,
        const Position(5, 5): CellType.button,
        const Position(2, 2): CellType.wall,
        const Position(2, 3): CellType.wall,
        const Position(3, 2): CellType.wall,
        const Position(5, 2): CellType.door,
        const Position(5, 0): CellType.goal,
      },
      startPosition: const Position(0, 0),
      requiredButtons: 2,
    ),
  ];

  static LevelData getLevel(int id) {
    return levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
  }
}
import 'package:flutter/foundation.dart';
import '../models/cell_type.dart';
import '../models/recorded_move.dart';
import '../models/level_data.dart';

class GameController extends ChangeNotifier {
  final LevelData level;
  final int echoDelay; // بعد كام خطوة الصدى بيبدأ يتحرك

  int currentStep = 0;
  bool isWon = false;
  bool isDead = false;

  // كل حركة اللاعب الحقيقية من أول اللعبة، بالترتيب
  final List<RecordedMove> fullHistory = [];

  GameController({required this.level, this.echoDelay = 5}) {
    fullHistory.add(
      RecordedMove(stepIndex: 0, position: level.startPosition),
    );
  }

  Position get playerPosition => fullHistory.last.position;

  // مكان الصدى دلوقتي = مكان اللاعب من "echoDelay" خطوة فاتت
  Position? get echoPosition {
    final echoStep = currentStep - echoDelay;
    if (echoStep < 0) return null;
    if (echoStep >= fullHistory.length) return fullHistory.last.position;
    return fullHistory[echoStep].position;
  }

  // الأزرار المشغولة دلوقتي فعليًا (لازم حضور مستمر، مش لمسة بتفضل للأبد)
  Set<Position> get occupiedButtons {
    final occupied = <Position>{};
    if (level.cells[playerPosition] == CellType.button) {
      occupied.add(playerPosition);
    }
    final echoPos = echoPosition;
    if (echoPos != null && level.cells[echoPos] == CellType.button) {
      occupied.add(echoPos);
    }
    return occupied;
  }

  bool get isDoorOpen => occupiedButtons.length >= level.requiredButtons;

  bool _isWalkable(Position pos, bool doorOpenState) {
    if (pos.x < 0 || pos.x >= level.gridSize || pos.y < 0 || pos.y >= level.gridSize) {
      return false;
    }
    final type = level.cells[pos] ?? CellType.empty;
    if (type == CellType.wall) return false;
    if (type == CellType.door && !doorOpenState) return false;
    return true;
  }

  void _advanceStep(Position newPlayerPos) {
    currentStep++;
    fullHistory.add(RecordedMove(stepIndex: currentStep, position: newPlayerPos));

    // فحص التصادم: لو الصدى في نفس مكان اللاعب دلوقتي، اعتبرها فشل بسيط (اختياري تصميميًا)
    final echoPos = echoPosition;
    if (echoPos != null && echoPos == newPlayerPos) {
      // مش هنموت اللاعب حاليًا، بس ممكن تستخدمها بعدين كخطر
    }

    if (level.cells[newPlayerPos] == CellType.goal) {
      isWon = true;
    }

    notifyListeners();
  }

  void movePlayer(int dx, int dy) {
    if (isWon) return;
    final newPos = playerPosition.move(dx, dy);
    if (!_isWalkable(newPos, isDoorOpen)) return;
    _advanceStep(newPos);
  }

  // وقف مكانك (خطوة "انتظار") - أهم أداة في اللعبة عشان تخلي الصدى "يمسك" الزرار لمدة أطول
  void waitInPlace() {
    if (isWon) return;
    _advanceStep(playerPosition);
  }

  void resetLevel() {
    currentStep = 0;
    isWon = false;
    isDead = false;
    fullHistory.clear();
    fullHistory.add(RecordedMove(stepIndex: 0, position: level.startPosition));
    notifyListeners();
  }
}
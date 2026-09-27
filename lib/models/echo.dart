import 'recorded_move.dart';

class Echo {
  final List<RecordedMove> recordedMoves; // كل الحركات اللي عملها اللاعب وقتها
  final int delaySteps; // بعد كام خطوة الصدى ده هيبدأ يتحرك

  Echo({required this.recordedMoves, required this.delaySteps});

  // يرجع مكان الصدى في "الخطوة الحالية" من اللعبة
  Position? getPositionAtStep(int currentStep) {
    final effectiveStep = currentStep - delaySteps;

    if (effectiveStep < 0) return null; // الصدى لسه ما بدأش

    if (effectiveStep >= recordedMoves.length) {
      // الصدى خلص حركاته، فضل واقف في آخر مكان وصله
      return recordedMoves.isEmpty ? null : recordedMoves.last.position;
    }

    return recordedMoves[effectiveStep].position;
  }
}
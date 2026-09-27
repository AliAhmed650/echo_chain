class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position move(int dx, int dy) => Position(x + dx, y + dy);

  @override
  bool operator ==(Object other) =>
      other is Position && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

class RecordedMove {
  final int stepIndex; // رقم الخطوة (مش وقت حقيقي، عشان نتحكم بدقة)
  final Position position; // المكان بعد الحركة دي

  RecordedMove({required this.stepIndex, required this.position});
}
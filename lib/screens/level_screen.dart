import 'package:flutter/material.dart';
import '../models/cell_type.dart';
import '../models/recorded_move.dart';
import '../services/game_controller.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late GameController controller;

  static const Color bgPurple = Color(0xFF1E1B4B);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentCoral = Color(0xFFF87171);

  @override
  void initState() {
    super.initState();
    _buildLevel();
  }

  void _buildLevel() {
    // نفس تصميم المستوى اللي رسمناه: شبكة 5×5
    final cells = <Position, CellType>{
      const Position(2, 2): CellType.button,
      const Position(4, 2): CellType.door,
      const Position(4, 0): CellType.goal,
    };

    controller = GameController(
      gridSize: 5,
      cells: cells,
      startPosition: const Position(0, 4),
    );
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPurple,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: Center(child: _buildGrid())),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Echo Chain',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(
                controller.isButtonPressed
                    ? Icons.lock_open
                    : Icons.lock_outline,
                color: controller.isButtonPressed
                    ? accentTeal
                    : accentAmber,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text('خطوة ${controller.currentStep}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    const cellSize = 56.0;
    final activeEchoes = controller.getActiveEchoPositions();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(controller.gridSize, (y) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(controller.gridSize, (x) {
              final pos = Position(x, y);
              final type = controller.cells[pos] ?? CellType.empty;
              final isPlayer = controller.playerPosition == pos;
              final isEcho = activeEchoes.contains(pos);

              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _cellColor(type),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (type == CellType.button)
                      const Icon(Icons.radio_button_checked,
                          color: Colors.white70, size: 20),
                    if (type == CellType.door)
                      Icon(
                        controller.isButtonPressed
                            ? Icons.door_front_door_outlined
                            : Icons.door_back_door,
                        color: Colors.white70,
                        size: 20,
                      ),
                    if (type == CellType.goal)
                      const Icon(Icons.flag, color: Colors.white, size: 22),
                    if (isEcho)
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accentTeal.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentTeal, width: 2),
                        ),
                      ),
                    if (isPlayer)
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Color _cellColor(CellType type) {
    switch (type) {
      case CellType.wall:
        return Colors.grey.shade800;
      case CellType.button:
        return accentAmber.withOpacity(0.25);
      case CellType.door:
        return controller.isButtonPressed
            ? accentTeal.withOpacity(0.2)
            : accentCoral.withOpacity(0.25);
      case CellType.goal:
        return accentTeal.withOpacity(0.3);
      case CellType.empty:
        return Colors.white.withOpacity(0.03);
    }
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (controller.isWon)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('🎉 كسبت! وصلت للهدف',
                  style: TextStyle(
                      color: accentTeal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_upward, () => controller.movePlayer(0, -1)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_back, () => controller.movePlayer(-1, 0)),
              const SizedBox(width: 40),
              _dirButton(Icons.arrow_forward, () => controller.movePlayer(1, 0)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_downward, () => controller.movePlayer(0, 1)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: controller.dropEcho,
                icon: const Icon(Icons.replay_circle_filled),
                label: const Text('اسقط صدى وارجع البداية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentAmber,
                  foregroundColor: bgPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(controller.resetLevel),
                icon: const Icon(Icons.restart_alt, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dirButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
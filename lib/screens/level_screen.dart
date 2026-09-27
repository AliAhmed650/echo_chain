import 'package:flutter/material.dart';
import '../models/cell_type.dart';
import '../models/recorded_move.dart';
import '../models/level_data.dart';
import '../services/game_controller.dart';

class LevelScreen extends StatefulWidget {
  final LevelData level;

  const LevelScreen({super.key, required this.level});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late GameController controller;

  static const Color bgTop = Color(0xFF12102B);
  static const Color bgBottom = Color(0xFF1E1B4B);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentCoral = Color(0xFFF87171);
  static const double cellSize = 54.0;
  static const double cellGap = 4.0;

  @override
  void initState() {
    super.initState();
    controller = GameController(level: widget.level, echoDelay: 5);
    controller.addListener(() => setState(() {}));
  }

  double _cellCenter(int index) => index * (cellSize + cellGap) + cellSize / 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: Center(child: _buildGrid())),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final occupied = controller.occupiedButtons.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
          Column(
            children: [
              Text(widget.level.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('خطوة ${controller.currentStep}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: controller.isDoorOpen
                  ? accentTeal.withOpacity(0.15)
                  : accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.isDoorOpen ? accentTeal : accentAmber,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.isDoorOpen ? Icons.lock_open : Icons.lock_outline,
                  color: controller.isDoorOpen ? accentTeal : accentAmber,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text('$occupied/${widget.level.requiredButtons}',
                    style: TextStyle(
                        color:
                            controller.isDoorOpen ? accentTeal : accentAmber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final size = widget.level.gridSize;
    final boardSize = size * cellSize + (size - 1) * cellGap;
    final echoPos = controller.echoPosition;

    return Container(
      width: boardSize + 16,
      height: boardSize + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Stack(
        children: [
          // خلفية الشبكة والعناصر الثابتة
          for (int y = 0; y < size; y++)
            for (int x = 0; x < size; x++)
              Positioned(
                left: _cellCenter(x) - cellSize / 2,
                top: _cellCenter(y) - cellSize / 2,
                width: cellSize,
                height: cellSize,
                child: _buildStaticCell(Position(x, y)),
              ),

          // الصدى (شفاف، متحرك بسلاسة)
          if (echoPos != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              left: _cellCenter(echoPos.x) - 19,
              top: _cellCenter(echoPos.y) - 19,
              width: 38,
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  color: accentTeal.withOpacity(0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentTeal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accentTeal.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

          // اللاعب (أبيض، متحرك بسلاسة)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            left: _cellCenter(controller.playerPosition.x) - 20,
            top: _cellCenter(controller.playerPosition.y) - 20,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticCell(Position pos) {
    final type = widget.level.cells[pos] ?? CellType.empty;
    final isOccupied = controller.occupiedButtons.contains(pos);

    Color bg;
    Widget? icon;

    switch (type) {
      case CellType.wall:
        bg = Colors.black.withOpacity(0.35);
        break;
      case CellType.button:
        bg = isOccupied
            ? accentTeal.withOpacity(0.25)
            : accentAmber.withOpacity(0.15);
        icon = Icon(
          isOccupied ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isOccupied ? accentTeal : accentAmber,
          size: 20,
        );
        break;
      case CellType.door:
        bg = controller.isDoorOpen
            ? accentTeal.withOpacity(0.15)
            : accentCoral.withOpacity(0.18);
        icon = Icon(
          controller.isDoorOpen
              ? Icons.meeting_room_outlined
              : Icons.door_back_door,
          color: controller.isDoorOpen ? accentTeal : accentCoral,
          size: 20,
        );
        break;
      case CellType.goal:
        bg = accentTeal.withOpacity(0.2);
        icon = const Icon(Icons.flag_rounded, color: accentTeal, size: 22);
        break;
      case CellType.empty:
        bg = Colors.white.withOpacity(0.02);
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: icon != null ? Center(child: icon) : null,
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (controller.isWon)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  const Text('🎉 كسبت!',
                      style: TextStyle(
                          color: accentTeal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accentTeal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12)),
                    child: const Text('رجوع للمستويات'),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_upward, () => controller.movePlayer(0, -1)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_back, () => controller.movePlayer(-1, 0)),
              const SizedBox(width: 8),
              _dirButton(Icons.pause_circle_outline, controller.waitInPlace,
                  highlight: true),
              const SizedBox(width: 8),
              _dirButton(Icons.arrow_forward, () => controller.movePlayer(1, 0)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_downward, () => controller.movePlayer(0, 1)),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(controller.resetLevel),
            icon: const Icon(Icons.restart_alt, color: Colors.white38, size: 18),
            label: const Text('إعادة المحاولة',
                style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Widget _dirButton(IconData icon, VoidCallback onTap, {bool highlight = false}) {
    return Material(
      color: highlight
          ? accentAmber.withOpacity(0.2)
          : Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon,
              color: highlight ? accentAmber : Colors.white, size: 24),
        ),
      ),
    );
  }
}
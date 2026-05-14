import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameHud extends PositionComponent {
  int lives;
  int gold;
  int currentWave;
  int totalWaves;
  double nextWaveCountdown;
  bool waveInProgress;

  static const int _cols = 10;
  static const double _tileSize = 40.0;
  static const double hudHeight = 48.0;

  GameHud({
    required this.lives,
    required this.gold,
    required this.currentWave,
    required this.totalWaves,
    required this.nextWaveCountdown,
    required this.waveInProgress,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(_cols * _tileSize, hudHeight),
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xDD1A1A2E),
    );

    _drawText(canvas, '❤ $lives', const Offset(8, 14),
        const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold));

    _drawText(canvas, '● $gold g', const Offset(90, 14),
        TextStyle(color: Colors.amber.shade300, fontSize: 14, fontWeight: FontWeight.bold));

    final waveText = waveInProgress
        ? 'Wave $currentWave / $totalWaves'
        : currentWave >= totalWaves
            ? 'All waves done!'
            : 'Next wave: ${nextWaveCountdown.toStringAsFixed(1)}s';

    final waveColor = waveInProgress ? Colors.orange : Colors.lightGreenAccent;
    _drawText(canvas, waveText, Offset(size.x / 2 - 55, 14),
        TextStyle(color: waveColor, fontSize: 13, fontWeight: FontWeight.bold));
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.left))
      ..pushStyle(style.getTextStyle())
      ..addText(text);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 200));
    canvas.drawParagraph(paragraph, offset);
  }
}

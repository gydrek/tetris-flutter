import 'package:flutter/material.dart';
import 'dart:async' as dart_async;

class MoveButtonWidget extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool holdable;

  const MoveButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = const Color.fromARGB(0, 0, 0, 0),
    this.holdable = false,
  });

  @override
  State<MoveButtonWidget> createState() => _MoveButtonWidgetState();
}

class _MoveButtonWidgetState extends State<MoveButtonWidget> {
  dart_async.Timer? _holdTimer;
  dart_async.Timer? _holdDelayTimer;

  void _startHold() {
    // Завжди зупиняємо всі таймери, навіть якщо перемикаємось між кнопками
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;
    // Для не holdable — миттєве виконання
    if (!widget.holdable) {
      widget.onPressed();
      return;
    }
    // Для holdable — стандартна логіка
    widget.onPressed();
    _holdDelayTimer = dart_async.Timer(const Duration(milliseconds: 100), () { // Затримка перед початком повторних натискань
      _holdTimer = dart_async.Timer.periodic(const Duration(milliseconds: 120), (_) { // Затримка між повторними натисканнями
        widget.onPressed();
      });
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    // Для не holdable (розворот) — Listener з onPointerDown
    if (!widget.holdable) {
      return Listener(
        onPointerDown: (_) {
          widget.onPressed();
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 4,
          height: 90,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: Theme.of(context).colorScheme.primary,
            size: 70,
          ),
        ),
      );
    }
    // ...existing code...
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _stopHold(),
      onTapCancel: _stopHold,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        height: 90,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: Theme.of(context).colorScheme.primary,
          size: 70,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ChartBar extends StatefulWidget {
  const ChartBar({
    super.key,
    required this.fill,
  });

  final double fill;

  @override
  State<ChartBar> createState() => _ChartBarState();
}

class _ChartBarState extends State<ChartBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: orientation == Orientation.portrait
              ? const BorderRadius.horizontal(right: Radius.circular(8))
              : const BorderRadius.vertical(bottom: Radius.circular(8)),
          color: isDark
              ? Theme.of(context).colorScheme.inversePrimary
              : Theme.of(context).colorScheme.primary.withOpacity(0.75),
        ),
      ),
      builder: (context, child) => Expanded(
        child: FractionallySizedBox(
          widthFactor: orientation == Orientation.portrait
              ? widget.fill * _controller.value
              : 0.7,
          heightFactor: orientation == Orientation.portrait
              ? 0.7
              : widget.fill * _controller.value,
          child: child,
        ),
      ),
    );
  }
}

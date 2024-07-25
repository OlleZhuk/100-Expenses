import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'colorseed_list.dart';

class ColorSelectOverlay {
  static Future<void> openColorSelectOverlay(context) async {
    final Orientation orientation = MediaQuery.orientationOf(context);
    const Orientation portrait = Orientation.portrait;
    final ColorScheme cScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      // transitionAnimationController: _controller,
      scrollControlDisabledMaxHeightRatio: orientation == portrait ? .4 : .5,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              textAlign: TextAlign.center,
              'Выбери свой цвет:',
              style: TextStyle(
                color: cScheme.primary,
                fontSize: 22,
              ),
            ),
          ),
          const Expanded(child: _ColorSeedGrid()),
        ],
      ),
    );
  }
}

///
class _ColorSeedGrid extends StatelessWidget {
  const _ColorSeedGrid();

  @override
  Widget build(BuildContext context) {
    var setColor = Hive.box<ColorSeed>('colors_box');
    final Orientation orientation = MediaQuery.orientationOf(context);

    return SizedBox(
        child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.landscape ? 10 : 5,
            ),
            itemCount: ColorSeed.values.length,
            itemBuilder: (ctx, index) => InkWell(
                onTap: () {
                  setColor.put('color', ColorSeed.values[index]);
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.palette,
                  size: 50,
                  color: ColorSeed.values[index].color,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(3, 3),
                    ),
                  ],
                ))));
  }
}

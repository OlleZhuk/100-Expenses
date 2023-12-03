import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/colorseed_list.dart';

class ColorSeedGrid extends StatelessWidget {
  const ColorSeedGrid({super.key});

  @override
  Widget build(BuildContext context) {
    var setColor = Hive.box<ColorSeed>('colors_box');
    final orientation = MediaQuery.of(context).orientation;

    return SizedBox(
      height: 340,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

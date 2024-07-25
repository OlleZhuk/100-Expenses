import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'colorseed_list.g.dart';

@HiveType(typeId: 3)
enum ColorSeed {
  @HiveField(0)
  blueAccent(Colors.blueAccent),
  @HiveField(1)
  redAccent(Colors.redAccent),
  @HiveField(2)
  amber(Colors.amber),
  @HiveField(3)
  limeAccent(Colors.limeAccent),
  @HiveField(4)
  green(Colors.green),
  @HiveField(5)
  cyan(Colors.cyan),
  @HiveField(6)
  tealAccent(Colors.tealAccent),
  @HiveField(7)
  deepPurple(Colors.deepPurple),
  @HiveField(8)
  purple(Colors.purple),
  @HiveField(9)
  pink(Colors.pink);

  const ColorSeed(this.color);
  final Color color;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colorseed_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColorSeedAdapter extends TypeAdapter<ColorSeed> {
  @override
  final int typeId = 3;

  @override
  ColorSeed read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ColorSeed.blueAccent;
      case 1:
        return ColorSeed.redAccent;
      case 2:
        return ColorSeed.amber;
      case 3:
        return ColorSeed.limeAccent;
      case 4:
        return ColorSeed.green;
      case 5:
        return ColorSeed.cyan;
      case 6:
        return ColorSeed.tealAccent;
      case 7:
        return ColorSeed.deepPurple;
      case 8:
        return ColorSeed.purple;
      case 9:
        return ColorSeed.pink;
      default:
        return ColorSeed.tealAccent;
    }
  }

  @override
  void write(BinaryWriter writer, ColorSeed obj) {
    switch (obj) {
      case ColorSeed.blueAccent:
        writer.writeByte(0);
        break;
      case ColorSeed.redAccent:
        writer.writeByte(1);
        break;
      case ColorSeed.amber:
        writer.writeByte(2);
        break;
      case ColorSeed.limeAccent:
        writer.writeByte(3);
        break;
      case ColorSeed.green:
        writer.writeByte(4);
        break;
      case ColorSeed.cyan:
        writer.writeByte(5);
        break;
      case ColorSeed.tealAccent:
        writer.writeByte(6);
        break;
      case ColorSeed.deepPurple:
        writer.writeByte(7);
        break;
      case ColorSeed.purple:
        writer.writeByte(8);
        break;
      case ColorSeed.pink:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorSeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

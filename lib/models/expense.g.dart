// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      title: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      category: fields[4] as Category,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 2;

  @override
  Category read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Category.alcohol;
      case 1:
        return Category.business;
      case 2:
        return Category.household;
      case 3:
        return Category.children;
      case 4:
        return Category.wellness;
      case 5:
        return Category.beauty;
      case 6:
        return Category.education;
      case 7:
        return Category.clothes;
      case 8:
        return Category.food;
      case 9:
        return Category.pets;
      case 10:
        return Category.gifts;
      case 11:
        return Category.traveling;
      case 12:
        return Category.leisure;
      case 13:
        return Category.sport;
      case 14:
        return Category.creativity;
      case 15:
        return Category.transport;
      case 16:
        return Category.services;
      case 17:
        return Category.bodycare;
      default:
        return Category.alcohol;
    }
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    switch (obj) {
      case Category.alcohol:
        writer.writeByte(0);
        break;
      case Category.business:
        writer.writeByte(1);
        break;
      case Category.household:
        writer.writeByte(2);
        break;
      case Category.children:
        writer.writeByte(3);
        break;
      case Category.wellness:
        writer.writeByte(4);
        break;
      case Category.beauty:
        writer.writeByte(5);
        break;
      case Category.education:
        writer.writeByte(6);
        break;
      case Category.clothes:
        writer.writeByte(7);
        break;
      case Category.food:
        writer.writeByte(8);
        break;
      case Category.pets:
        writer.writeByte(9);
        break;
      case Category.gifts:
        writer.writeByte(10);
        break;
      case Category.traveling:
        writer.writeByte(11);
        break;
      case Category.leisure:
        writer.writeByte(12);
        break;
      case Category.sport:
        writer.writeByte(13);
        break;
      case Category.creativity:
        writer.writeByte(14);
        break;
      case Category.transport:
        writer.writeByte(15);
        break;
      case Category.services:
        writer.writeByte(16);
        break;
      case Category.bodycare:
        writer.writeByte(17);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

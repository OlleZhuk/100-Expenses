import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:line_icons/line_icons.dart';

part 'expense.g.dart';

const uuid = Uuid();

@HiveType(typeId: 1)
class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final Category category;

  String get formattedDate => (formatDate(
        (date),
        [D, ' ', d, ' ', M, ' ', yyyy],
        locale: const RussianDateLocale(),
      ));
}

@HiveType(typeId: 2)
enum Category {
  @HiveField(0)
  alcohol('Алкоголь'),
  @HiveField(1)
  business('Бизнес'),
  @HiveField(2)
  household('Всё для дома'),
  @HiveField(3)
  children('Дети'),
  @HiveField(4)
  wellness('Здоровье'),
  @HiveField(5)
  beauty('Красота'),
  @HiveField(6)
  education('Обучение'),
  @HiveField(7)
  clothes('Одежда'),
  @HiveField(8)
  food('Питание'),
  @HiveField(9)
  pets('Питомцы'),
  @HiveField(10)
  gifts('Подарки'),
  @HiveField(11)
  traveling('Путешествия'),
  @HiveField(12)
  leisure('Развлечения'),
  @HiveField(13)
  sport('Спорт'),
  @HiveField(14)
  creativity('Творчество'),
  @HiveField(15)
  transport('Транспорт'),
  @HiveField(16)
  services('Услуги'),
  @HiveField(17)
  bodycare('Уход за телом');

  const Category(this.label);
  final String label;
}

const categoryIcons = {
  Category.alcohol: Icons.wine_bar,
  Category.business: Icons.business_center_outlined,
  Category.leisure: LineIcons.crown,
  Category.food: LineIcons.utensils,
  Category.wellness: LineIcons.spa,
  Category.beauty: Icons.face_outlined,
  Category.education: LineIcons.school,
  Category.clothes: LineIcons.tShirt,
  Category.sport: Icons.directions_bike,
  Category.creativity: LineIcons.splotch,
  Category.children: Icons.child_care_outlined,
  Category.transport: Icons.commute_outlined,
  Category.services: Icons.hub_outlined,
  Category.household: Icons.home_outlined,
  Category.bodycare: Icons.accessibility_new,
  Category.gifts: LineIcons.gifts,
  Category.pets: LineIcons.paw,
  Category.traveling: Icons.rocket_launch_outlined,
};

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  final Category category;
  final List<Expense> expenses;

  ExpenseBucket.forCategory(
    List<Expense> allExpenses,
    this.category,
  ) : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  double get totalExpenses {
    double sum = 0;
    for (final Expense expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}

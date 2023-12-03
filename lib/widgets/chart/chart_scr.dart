import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../expenses/filtered_expenses_scr.dart';
import '/models/expense.dart';
import 'chart_bar.dart';

var expenseBox = Hive.box<Expense>('expenses_box');

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  List<Expense> expenses = expenseBox.values.toList();
  NumberFormat myFormat = NumberFormat.decimalPattern('ru');

  List<ExpenseBucket> get buckets => [
        ExpenseBucket.forCategory(expenses, Category.alcohol),
        ExpenseBucket.forCategory(expenses, Category.business),
        ExpenseBucket.forCategory(expenses, Category.household),
        ExpenseBucket.forCategory(expenses, Category.children),
        ExpenseBucket.forCategory(expenses, Category.wellness),
        ExpenseBucket.forCategory(expenses, Category.beauty),
        ExpenseBucket.forCategory(expenses, Category.education),
        ExpenseBucket.forCategory(expenses, Category.clothes),
        ExpenseBucket.forCategory(expenses, Category.food),
        ExpenseBucket.forCategory(expenses, Category.pets),
        ExpenseBucket.forCategory(expenses, Category.gifts),
        ExpenseBucket.forCategory(expenses, Category.traveling),
        ExpenseBucket.forCategory(expenses, Category.leisure),
        ExpenseBucket.forCategory(expenses, Category.sport),
        ExpenseBucket.forCategory(expenses, Category.creativity),
        ExpenseBucket.forCategory(expenses, Category.transport),
        ExpenseBucket.forCategory(expenses, Category.services),
        ExpenseBucket.forCategory(expenses, Category.bodycare),
      ];

  double get maxTotalExpense {
    double maxTotalExpense = 0;
    for (final bucket in buckets) {
      if (bucket.totalExpenses > maxTotalExpense) {
        maxTotalExpense = bucket.totalExpenses;
      }
    }
    return maxTotalExpense;
  }

  totalAmount() {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum.ceil()..toString();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: orientation == Orientation.portrait
          ? AppBar(
              title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Диаграмма расходов:'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      myFormat.format(totalAmount()),
                      style: TextStyle(fontSize: 14, shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          blurRadius: 5,
                          offset: const Offset(1, 1),
                        )
                      ]),
                    ),
                    Icon(
                      Icons.currency_ruble,
                      size: 16,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          blurRadius: 5,
                          offset: const Offset(1, 1),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ))
          : null,
      floatingActionButton: orientation == Orientation.landscape
          ? FloatingActionButton.small(
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.0),
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ],
            begin: orientation == Orientation.landscape
                ? Alignment.topCenter
                : Alignment.centerLeft,
            end: orientation == Orientation.landscape
                ? Alignment.bottomCenter
                : Alignment.centerRight,
            stops: const [0.3, 1],
          ),
        ),
        child: orientation == Orientation.portrait
            ? Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: buckets
                        .map(
                          (final bucket) => Expanded(
                            child: InkWell(
                              onTap: () {
                                final String bcl = bucket.category.label;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryExpenses(onGetCategory: bcl),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '${bucket.category.label}: ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${bucket.totalExpenses.ceil().toString()} ',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Icon(
                                    categoryIcons[bucket.category],
                                    size: 26,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final bucket in buckets)
                          ChartBar(
                            fill: bucket.totalExpenses == 0
                                ? 0
                                : bucket.totalExpenses / maxTotalExpense,
                          )
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: buckets
                        .map(
                          (bucket) => Expanded(
                            child: InkWell(
                              onTap: () {
                                final String bcl = bucket.category.label;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryExpenses(onGetCategory: bcl),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      bucket.category.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      bucket.totalExpenses.ceil().toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    categoryIcons[bucket.category],
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 4)
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final bucket in buckets)
                          ChartBar(
                            fill: bucket.totalExpenses == 0
                                ? 0
                                : bucket.totalExpenses / maxTotalExpense,
                          )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

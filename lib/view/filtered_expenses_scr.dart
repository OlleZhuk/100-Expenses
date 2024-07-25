import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../repository/expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');

class ExpensesCategory extends StatelessWidget {
  const ExpensesCategory({super.key, required this.onGetCategory});

  final String onGetCategory;

  @override
  Widget build(BuildContext context) {
    final NumberFormat myFormat = NumberFormat.decimalPattern('ru');
    final int nowDate = DateTime.now().day;
    final double devW = MediaQuery.sizeOf(context).width;
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, box, _) {
          final String getCategory = onGetCategory;
          final List<Expense> allExpenses = box.values.toList();

          final List<Expense> filteredList = allExpenses
              .where((expense) => expense.category.label == getCategory)
              .toList();
          filteredList.sort((a, b) => b.date.compareTo(a.date));

          totalAmount() {
            double sum = 0;
            for (final expense in filteredList) {
              sum += expense.amount;
            }
            return sum..toString();
          }

          final int perDay = (totalAmount() / nowDate).ceil();

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 90,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: devW,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [
                            cScheme.inversePrimary.withOpacity(0.0),
                            cScheme.inversePrimary.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: const [0.5, 1],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(getCategory),
                          const Spacer(),
                          Text(
                            '${filteredList.length.toString()}/ ${myFormat.format(totalAmount().ceil())}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          const Icon(Icons.currency_ruble),
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${myFormat.format(perDay)}/день',
                        style: const TextStyle(fontSize: 14),
                      ))
                ],
              ),
            ),
            body: filteredList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Center(
                        child: Text(
                      'Нет расходов по данной категории!',
                      style: tTheme.titleLarge,
                      textAlign: TextAlign.center,
                    )))
                : _FadeMask(
                    valuesLength: box.values.length,
                    child: _MainList(list: filteredList),
                  ),
          );
        });
  }
}

///
class _MainList extends StatelessWidget {
  const _MainList({required this.list});

  final List<Expense> list;

  @override
  Widget build(BuildContext context) {
    final NumberFormat myFormat = NumberFormat.decimalPattern('ru');
    final ColorScheme cScheme = Theme.of(context).colorScheme;

    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                dense: true,
                leading: Icon(
                  categoryIcons[list[index].category],
                  size: 38,
                ),
                title: Text(
                  list[index].title,
                  maxLines: 2,
                  style: TextStyle(
                    color: cScheme.onPrimaryContainer,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  list[index].formattedDate,
                  style: TextStyle(
                    color: cScheme.surfaceTint,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      myFormat.format(list[index].amount.ceil()),
                      style: const TextStyle(fontSize: 18),
                    ),
                    Icon(
                      Icons.currency_ruble,
                      color: cScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                iconColor: cScheme.inversePrimary,
              ),
            ));
  }
}

///
class _FadeMask extends StatelessWidget {
  const _FadeMask({
    required this.child,
    required this.valuesLength,
  });

  final Widget child;
  final int valuesLength;

  @override
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (Rect rect) {
          final ColorScheme cScheme = Theme.of(context).colorScheme;

          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              valuesLength >= 10 ? cScheme.inversePrimary : Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              valuesLength >= 10 ? cScheme.inversePrimary : Colors.transparent,
            ],
            stops: const [0.0, 0.06, 0.85, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: child,
      );
}

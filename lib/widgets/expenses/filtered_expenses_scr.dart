import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '/models/expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');

class CategoryExpenses extends StatefulWidget {
  const CategoryExpenses({super.key, required this.onGetCategory});

  final String onGetCategory;

  @override
  State<CategoryExpenses> createState() => _CategoryExpensesState();
}

class _CategoryExpensesState extends State<CategoryExpenses> {
  NumberFormat myFormat = NumberFormat.decimalPattern('ru');

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, box, _) {
          final String getCategory = widget.onGetCategory;
          List<Expense> allExpenses = box.values.toList();

          final filteredList = allExpenses
              .where((expense) => expense.category.label == getCategory)
              .toList();
          filteredList.sort((a, b) => b.date.compareTo(a.date));

          totalAmount() {
            double sum = 0;
            for (final expense in filteredList) {
              sum += expense.amount;
            }
            return myFormat.format(sum.ceil());
          }

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 90,
              title: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.0),
                      Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.8),
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
                    Expanded(
                      flex: 2,
                      child: Text(getCategory),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredList.length.toString()}/ ${totalAmount()}',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const Icon(Icons.currency_ruble),
                  ],
                ),
              ),
            ),
            body: filteredList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Center(
                      child: Text(
                        'Нет расходов по данной категории!',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ShaderMask(
                    shaderCallback: (Rect rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          box.values.length >= 10
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.transparent,
                          Colors.transparent,
                          Colors.transparent,
                          box.values.length >= 10
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.transparent,
                        ],
                        stops: const [0.0, 0.06, 0.85, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstOut,
                    child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (ctx, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  categoryIcons[filteredList[index].category],
                                  size: 38,
                                ),
                                title: Text(
                                  filteredList[index].title,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  filteredList[index].formattedDate,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceTint,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      myFormat.format(
                                          filteredList[index].amount.ceil()),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Icon(
                                      Icons.currency_ruble,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                iconColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            )),
                  ),
          );
        },
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '/../models/expense.dart';
import '../info_item.dart';
import 'new_expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');

class ExpensesList extends StatefulWidget {
  const ExpensesList({super.key});

  @override
  State<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  NumberFormat myFormat = NumberFormat.decimalPattern('ru');

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: expenseBox.listenable(),
      builder: (context, box, _) {
        final Map<dynamic, Expense> expensesMap = box.toMap();
        final List<Expense> expensesList = box.values.toList();
        expensesList.sort((a, b) => b.date.compareTo(a.date));

        return box.values.isEmpty
            ? InfoItem()
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
                    stops: const [
                      0.0,
                      0.06,
                      0.85,
                      1.0
                    ], //^ 6% цвет, 79% transparent, 15% цвет
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: AnimatedList(
                  key: listKey,
                  initialItemCount: expensesList.length,
                  itemBuilder: (context, index, animation) {
                    removeItem(direction) {
                      removed() {
                        expensesMap.forEach((key, value) async {
                          if (value.id == expensesList[index].id) {
                            await box.delete(key);
                          }
                        });
                      }

                      listKey.currentState!.removeItem(
                        index,
                        duration: const Duration(milliseconds: 500),
                        (context, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: const ListTile(),
                          ),
                        ),
                      );
                      return removed();
                    }

                    ActionPane actionPane() => ActionPane(
                          motion: const StretchMotion(),
                          extentRatio: 0.33,
                          children: [
                            SlidableAction(
                              //< Удаление
                              onPressed: removeItem,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceTint
                                  .withOpacity(0.75),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Удалить',
                            ),
                          ],
                        );

                    return Slidable(
                      key: UniqueKey(),
                      startActionPane: actionPane(),
                      endActionPane: actionPane(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizeTransition(
                          sizeFactor: animation,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              categoryIcons[expensesList[index].category],
                              size: 38,
                            ),
                            title: Text(
                              expensesList[index].title,
                              maxLines: 2,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              expensesList[index].formattedDate,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.surfaceTint,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  myFormat.format(
                                      expensesList[index].amount.ceil()),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Icon(
                                  Icons.currency_ruble,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                            iconColor:
                                Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
      });
}

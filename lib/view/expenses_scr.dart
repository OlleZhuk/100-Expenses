/// Список расходов
library;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../repository/add_expense_overlay.dart';
import '../repository/color_select_overlay.dart';
import '../repository/expense.dart';
import '../repository/info_item.dart';
import 'chart_scr.dart';
import 'info_scr.dart';

var expenseBox = Hive.box<Expense>('expenses_box');
var toggleIsBright = Hive.box('set_brightness');

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.orientationOf(context);
    const Orientation portrait = Orientation.portrait;

    return ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, box, _) {
          final List<Expense> allExpenses = box.values.toList();

          int totalAmount() {
            double sum = 0;
            for (final expense in allExpenses) {
              sum += expense.amount;
            }
            return sum.ceil()..toString();
          }

          return SafeArea(
            child: Scaffold(
              appBar: box.values.isEmpty
                  ? null
                  : _TopBar(
                      totalAmount: totalAmount(),
                      valuesLength: box.values.length,
                      height: orientation == portrait ? 90 : 70,
                    ),
              bottomNavigationBar:
                  orientation == portrait ? _BottomBar() : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startDocked,
              floatingActionButton: orientation == portrait
                  ? FloatingActionButton.large(
                      onPressed: () => AddExpenseOverlay.addExpense(context),
                      child: const Icon(Icons.add, size: 48),
                    )
                  : null,
              body: orientation == portrait
                  ? const _ExpensesList()
                  : Row(children: [
                      _VertBar(),
                      const Gap(16),
                      const Expanded(child: _ExpensesList()),
                    ]),
            ),
          );
        });
  }
}

///
class _ExpensesList extends StatelessWidget {
  const _ExpensesList();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final NumberFormat myFormat = NumberFormat.decimalPattern('ru');

    final Widget divider = Expanded(
      child: Container(
          height: 1,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              cScheme.inversePrimary.withOpacity(0.8),
              cScheme.inversePrimary.withOpacity(0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.1, 1],
          ))),
    );

    return ValueListenableBuilder(
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
                            ? cScheme.inversePrimary
                            : Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        box.values.length >= 10
                            ? cScheme.inversePrimary
                            : Colors.transparent,
                      ],
                      stops: const [
                        0.0,
                        0.06,
                        0.85,
                        1.0
                      ], // 6% цвет, 79% transparent, 15% цвет
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: AnimatedList(
                      key: listKey,
                      initialItemCount: expensesList.length,
                      itemBuilder: (context, index, animation) {
                        final Expense indx = expensesList[index];
                        String previousDate = index > 0
                            ? DateFormat('EE, dd MMMM', 'ru')
                                .format(expensesList[index - 1].date)
                            : '';
                        String date =
                            DateFormat('EE, dd MMMM', 'ru').format(indx.date);

                        removeItem(direction) {
                          removed() {
                            expensesMap.forEach((key, value) async {
                              if (value.id == indx.id) {
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
                                )),
                          );
                          return removed();
                        }

                        ActionPane actionPane() => ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 0.33,
                              children: [
                                SlidableAction(
                                  // Удаление
                                  onPressed: removeItem,
                                  backgroundColor:
                                      cScheme.surfaceTint.withOpacity(0.75),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Удалить',
                                ),
                              ],
                            );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            date != previousDate
                                ? Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Text(date),
                                      ),
                                      divider,
                                    ],
                                  )
                                : const Gap(0),
                            Slidable(
                                key: UniqueKey(),
                                startActionPane: actionPane(),
                                endActionPane: actionPane(),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      child: ListTile(
                                        dense: true,
                                        leading: Icon(
                                          categoryIcons[indx.category],
                                          size: 38,
                                        ),
                                        iconColor:
                                            cScheme.primary.withOpacity(.4),
                                        title: Text(
                                          indx.title,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: cScheme.onPrimaryContainer,
                                            fontSize: 18,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              myFormat
                                                  .format(indx.amount.ceil()),
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            Icon(
                                              Icons.currency_ruble,
                                              color: cScheme.primary,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))),
                          ],
                        );
                      }));
        });
  }
}

///
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final bool isBright = Theme.of(context).brightness == Brightness.light;
    final double prefixGap = MediaQuery.sizeOf(context).width * .25;

    return BottomAppBar(
        notchMargin: 7,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Gap(prefixGap),
                //* Диаграмма
                IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      size: 30,
                      color: cScheme.primary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const Chart()))),
                //* Очистка
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 30,
                    color: cScheme.primary,
                  ),
                  onPressed: () => expenseBox.isNotEmpty
                      ? _CleanExpenses.cleanExpenses(context)
                      : null,
                ),
                //* Палитра цветов
                IconButton(
                  icon: Icon(
                    Icons.palette,
                    size: 30,
                    color: cScheme.primary,
                  ),
                  onPressed: () =>
                      ColorSelectOverlay.openColorSelectOverlay(context),
                ),
                //* Тема темная/светлая
                IconButton(
                  icon: Icon(
                    isBright ? Icons.dark_mode : Icons.light_mode_outlined,
                    size: 30,
                    color: cScheme.primary,
                  ),
                  onPressed: () => toggleIsBright.put('isBright', !isBright),
                ),
              ],
            )));
  }
}

///
class _VertBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final bool isBright = Theme.of(context).brightness == Brightness.light;

    return Container(
        height: double.infinity,
        width: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isBright
                  ? cScheme.inversePrimary.withOpacity(0)
                  : Colors.transparent,
              isBright
                  ? cScheme.inversePrimary.withOpacity(.8)
                  : cScheme.inversePrimary.withOpacity(.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0, .3],
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  isBright ? Icons.dark_mode : Icons.light_mode_outlined,
                  size: 30,
                  color: cScheme.primary,
                ),
                onPressed: () => toggleIsBright.put('isBright', !isBright),
              ),
              IconButton(
                icon: Icon(
                  Icons.palette,
                  size: 30,
                  color: cScheme.primary,
                ),
                onPressed: () =>
                    ColorSelectOverlay.openColorSelectOverlay(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 30,
                  color: cScheme.primary,
                ),
                onPressed: () => expenseBox.isNotEmpty
                    ? _CleanExpenses.cleanExpenses(context)
                    : null,
              ),
              IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    size: 30,
                    color: cScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Chart()))),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30,
                  color: cScheme.primary,
                ),
                onPressed: () => AddExpenseOverlay.addExpense(context),
              ),
            ]));
  }
}

///
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({
    required this.totalAmount,
    required this.valuesLength,
    required this.height,
  });

  final int totalAmount;
  final int valuesLength;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.orientationOf(context);
    const portrait = Orientation.portrait;
    final NumberFormat myFormat = NumberFormat.decimalPattern('ru');

    return AppBar(
        toolbarHeight: orientation == portrait ? 90 : 70,
        title: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
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
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const InfoScreen(),
                    ));
                  },
                  child: const Text('100 затрат:'),
                ),
                const Spacer(),
                Text(
                  '${valuesLength.toString()}/ ${myFormat.format(totalAmount)}',
                  style: const TextStyle(fontSize: 22),
                ),
                const Icon(Icons.currency_ruble),
              ],
            )));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

///
class _CleanExpenses {
  static Future<void> cleanExpenses(context) async {
    final ColorScheme cScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Полная очистка'),
        content: const Text('Вы действительно хотите удалить все расходы?'),
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        actions: [
          FilledButton(
            child: const Text('НЕТ ЕЩЁ'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cScheme.error),
            child: const Text('ДА'),
            onPressed: () {
              expenseBox.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../chart/chart_scr.dart';
import '../colorseed_grid.dart';
import '/models/expense.dart';
import 'expenses_list.dart';
import '../info_scr.dart';
import 'new_expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');
var toggleIsBright = Hive.box('set_brightness');

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> with TickerProviderStateMixin {
  NumberFormat myFormat = NumberFormat.decimalPattern('ru');
  late AnimationController _controller;

  @override
  initState() {
    _controller = BottomSheet.createAnimationController(this);
    _controller.duration = const Duration(seconds: 1);
    _controller.reverseDuration = const Duration(milliseconds: 400);
    super.initState();
  }

  void _openColorSelectOverlay() {
    showModalBottomSheet(
      context: context,
      transitionAnimationController: _controller,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              textAlign: TextAlign.center,
              'Выбери свой цвет:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 22,
              ),
            ),
          ),
          const Expanded(child: ColorSeedGrid()),
        ],
      ),
    );
  }

  _openAddExpenseOverlay() {
    showModalBottomSheet(
      transitionAnimationController: _controller,
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => const NewExpense(),
    );
  }

  _cleanExpenses() {
    showDialog(
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FilledButton(
            onPressed: () {
              expenseBox.clear();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('ДА'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: expenseBox.listenable(),
      builder: (context, box, _) {
        final isBright = Theme.of(context).brightness == Brightness.light;
        List<Expense> allExpenses = box.values.toList();

        totalAmount() {
          double sum = 0;
          for (final expense in allExpenses) {
            sum += expense.amount;
          }
          return sum.ceil()..toString();
        }

        return Scaffold(
          appBar: box.values.isEmpty
              ? null
              : AppBar(
                  toolbarHeight: 90,
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
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
                          '${box.values.length.toString()}/ ${myFormat.format(totalAmount())}',
                          style: const TextStyle(fontSize: 22),
                        ),
                        const Icon(Icons.currency_ruble),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BottomAppBar(
            notchMargin: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 100),
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Chart(),
                      ));
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        expenseBox.isNotEmpty ? _cleanExpenses() : null;
                      }),
                  IconButton(
                    icon: Icon(
                      Icons.palette,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _openColorSelectOverlay,
                  ),
                  IconButton(
                    icon: Icon(
                      isBright ? Icons.dark_mode : Icons.light_mode_outlined,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      toggleIsBright.put('isBright', !isBright);
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: _openAddExpenseOverlay,
            child: const Icon(Icons.add, size: 48),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startDocked,
          body: const ExpensesList(),
        );
      });
}

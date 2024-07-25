import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter_awesome_calculator/flutter_awesome_calculator.dart';
import 'expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');

final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

class AddExpenseOverlay {
  static Future<void> addExpense(context) async {
    ColorScheme cScheme = Theme.of(context).colorScheme;
    bool isBright = Theme.of(context).brightness == Brightness.light;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: _AddExpense(),
        backgroundColor: isBright
            ? cScheme.surface.withOpacity(.8)
            : cScheme.surface.withOpacity(.5),
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        //
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

///
class _AddExpense extends StatefulWidget {
  @override
  State<_AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<_AddExpense> {
  final _titleInputController = TextEditingController();
  final _amountInputController = TextEditingController();
  AnimatedListState? animatedList = listKey.currentState;
  DateTime? _selectedDate = DateTime.now();
  Category _selectedCategory = Category.food;
  late Expense expense;

  @override
  void dispose() {
    super.dispose();
    _titleInputController.dispose();
    _amountInputController.dispose();
  }

  _titleField() => FormBuilderTextField(
        name: 'Название',
        controller: _titleInputController,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 50,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          return value!.isEmpty ? 'Введите название!' : null;
        },
        decoration: InputDecoration(
          labelText: 'Название:',
          suffixIcon: IconButton(
            onPressed: _titleInputController.clear,
            icon: const Icon(Icons.clear, size: 20),
          ),
        ),
      );

  _amountField() => FormBuilderTextField(
        name: 'Сумма',
        controller: _amountInputController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value!.isEmpty || double.tryParse(value) == 0) {
            return 'Введите сумму!';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Сумма:',
          prefix: const Icon(Icons.currency_ruble, size: 14),
          suffixIcon: IconButton(
            onPressed: _amountInputController.clear,
            icon: const Icon(Icons.clear, size: 20),
          ),
        ),
      );

  _dateField() => FormBuilderDateTimePicker(
        name: 'Дата',
        decoration: const InputDecoration(labelText: 'Выбор даты:'),
        format: DateFormat('d MMM yyyy', 'ru'),
        locale: const Locale('ru'),
        inputType: InputType.date,
        initialDate: DateTime.now(),
        initialValue: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        onChanged: (value) {
          setState(() => _selectedDate = value!);
        },
      );

  _categoryField() => FormBuilderDropdown(
        name: 'Категория',
        initialValue: _selectedCategory,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        decoration: const InputDecoration(labelText: 'Выбор категории:'),
        items: Category.values
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedCategory = value!);
        },
      );

  Future<void> _addToLocalDB() async {
    final enteredAmount = double.tryParse(_amountInputController.text);

    await expenseBox.add(
      expense = Expense(
        title: _titleInputController.text,
        amount: enteredAmount!,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );
    animatedList?.insertItem(
      0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _calculator() async {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final bool isBright = Theme.of(context).brightness == Brightness.light;
    final Orientation orientation = MediaQuery.orientationOf(context);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: FlutterAwesomeCalculator(
          context: context,
          height: orientation == Orientation.portrait ? 400 : 250,
          clearButtonColor: cScheme.inversePrimary,
          digitsButtonColor:
              isBright ? cScheme.primaryContainer : cScheme.onPrimaryContainer,
          operatorsButtonColor: cScheme.primary,
          backgroundColor: cScheme.surface,
          expressionAnswerColor: cScheme.primary,
          showAnswerField: true,
          fractionDigits: 0,
          buttonRadius: 8,
          onChanged: (ans, expression) {},
        ),
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final Orientation orientation = MediaQuery.orientationOf(context);
    const Orientation portrait = Orientation.portrait;

    final calcBttn = FloatingActionButton(
      onPressed: _calculator,
      child: const Icon(
        Icons.calculate_outlined,
        size: 30,
      ),
    );

    final saveBttn = FloatingActionButton.extended(
      label: const Text(
        'Сохранить',
        style: TextStyle(fontSize: 14),
      ),
      onPressed: () {
        if (!formKey.currentState!.validate()) return;
        _addToLocalDB();
        Navigator.pop(context);
      },
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //
          orientation == portrait
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('НОВЫЙ РАСХОД:',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Pangolin',
                        fontWeight: FontWeight.w600,
                        color: cScheme.primary,
                      )))
              : const Gap(0),
          //
          orientation == portrait
              ? FormBuilder(
                  key: formKey,
                  child: Column(children: [
                    //
                    _titleField(),
                    const Gap(6),
                    //
                    Row(children: [
                      Expanded(child: _amountField()),
                      const Gap(10),
                      calcBttn,
                    ]),
                    const Gap(28),
                    //
                    _categoryField(),
                    const Gap(28),
                    Row(
                      children: [
                        Expanded(child: _dateField()),
                        const Gap(10),
                        saveBttn,
                      ],
                    ),
                  ]),
                )
              : FormBuilder(
                  key: formKey,
                  child: Column(children: [
                    //
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _titleField()),
                          const Gap(10),
                          Expanded(child: _amountField()),
                        ]),
                    const Gap(14),
                    //
                    Row(children: [
                      Expanded(
                          flex: 2,
                          child: Row(children: [
                            Expanded(child: _categoryField()),
                            const Gap(10),
                            Expanded(child: _dateField()),
                            const Gap(10),
                          ])),
                      Expanded(
                          child: Row(children: [
                        calcBttn,
                        const Gap(6),
                        saveBttn,
                      ])),
                    ]),
                  ]),
                ),
        ],
      ),
    );
  }
}

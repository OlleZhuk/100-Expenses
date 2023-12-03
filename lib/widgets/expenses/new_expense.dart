import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '/models/expense.dart';

var expenseBox = Hive.box<Expense>('expenses_box');
final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final _titleInputController = TextEditingController();
  final _amountInputController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  Category _selectedCategory = Category.food;
  late Expense expense;

  AnimatedListState? get _animatedList => listKey.currentState;

  @override
  void dispose() {
    _titleInputController.dispose();
    _amountInputController.dispose();
    super.dispose();
  }

  _titleField() => FormBuilderTextField(
        name: 'Название',
        controller: _titleInputController,
        keyboardType: TextInputType.text,
        maxLength: 50,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Введите название!';
          }
          return null;
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
          setState(() {
            _selectedDate = value!;
          });
        },
      );

  _categoryField() => FormBuilderDropdown(
        name: 'Категория',
        dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
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
          setState(() {
            _selectedCategory = value!;
          });
        },
      );

  _onSave() => FloatingActionButton.extended(
        label: const Text(
          'Сохранить',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          _onAddExpenseData();

          Navigator.pop(context);
        },
      );

  void _onAddExpenseData() {
    final enteredAmount = double.tryParse(_amountInputController.text);
    var expenseKey = UniqueKey().toString();

    expenseBox.put(
      expenseKey,
      expense = Expense(
        title: _titleInputController.text,
        amount: enteredAmount!,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );
    _animatedList?.insertItem(
      0,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'НОВЫЙ РАСХОД:',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Pangolin',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          orientation == Orientation.landscape
              ? FormBuilder(
                  key: _formKey,
                  child: Expanded(
                    child: Column(
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _titleField()),
                              const SizedBox(width: 10),
                              Expanded(child: _amountField()),
                            ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: _categoryField()),
                          const SizedBox(width: 10),
                          Expanded(child: _dateField()),
                          const SizedBox(width: 10),
                          _onSave(),
                        ])
                      ],
                    ),
                  ),
                )
              : FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      _titleField(),
                      const SizedBox(height: 6),
                      Row(children: [
                        Expanded(child: _amountField()),
                        const SizedBox(width: 10),
                        Expanded(child: _dateField()),
                      ]),
                      const SizedBox(height: 28),
                      Row(children: [
                        Expanded(child: _categoryField()),
                        const SizedBox(width: 10),
                        _onSave(),
                      ])
                    ],
                  ),
                )
        ],
      ),
    );
  }
}

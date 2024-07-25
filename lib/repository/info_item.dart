import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InfoItem extends StatelessWidget {
  InfoItem({super.key});

  final List<String> tips = [
    'Округляйте сумму до рублей.',
    'Расход безвозвратно удаляется смахиванием вправо - влево.',
    'Диаграмма покажет более детальную информацию, если нажать на сумму или название категории.',
    'В последний день месяца рекомендуется сделать скриншот диаграммы и очистить все расходы.',
    'К этой информации потом можно вернуться, если нажать на заголовок "100 затрат".',
    'И постарайтесь реально не делать больше 100 расходов в месяц.',
  ];

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.orientationOf(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isDark
              ? const AssetImage("assets/images/dark2.jpg")
              : const AssetImage("assets/images/light2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          orientation == Orientation.portrait
              ? const Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 38),
                      child: Text(
                        '100',
                        style: TextStyle(
                          fontSize: 120,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      'ЗАТРАТ',
                      style: TextStyle(
                        fontSize: 56,
                        fontFamily: 'Lato',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '100',
                      style: TextStyle(fontSize: 50, fontFamily: 'Lato'),
                    ),
                    Gap(10),
                    Text(
                      'ЗАТРАТ',
                      style: TextStyle(fontSize: 50, fontFamily: 'Lato'),
                    ),
                  ],
                ),
          const Gap(10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: orientation == Orientation.portrait ? 76 : 100,
            ),
            child: Column(
              children: tips
                  .map(
                    (tip) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "\u2022  ",
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

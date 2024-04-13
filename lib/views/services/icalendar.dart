import 'package:cczu_helper/views/widgets/adaptive.dart';
import 'package:cczu_helper/views/widgets/progressive.dart';
import 'package:flutter/material.dart';

class ICalendarServicePage extends StatefulWidget {
  const ICalendarServicePage({super.key});

  @override
  State<StatefulWidget> createState() => ICalendarServicePageState();
}

class ICalendarServicePageState extends State<ICalendarServicePage> {
  @override
  Widget build(BuildContext context) {
    return ProgressiveView(
      children: [
        AdaptiveView(
            cardMargin: const EdgeInsets.only(bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "设置日期",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Card.outlined(
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Padding(
                        padding: EdgeInsets.all(8), child: Text("说明....")),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: FilledButton(
                      onPressed: () {
                        showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now());
                      },
                      child: const Text("更改日期"),
                    ),
                  ),
                )
              ],
            )),
        const Text("hello"),
        const Text("hello")
      ],
      onSubmit: () {},
    );
  }
}

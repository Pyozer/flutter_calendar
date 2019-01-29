import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

main() => runApp(CalendarViewApp());

class CalendarViewApp extends StatelessWidget {
  void handleNewDate(date) {
    print("handleNewDate $date");
  }

  Widget get event => Event();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = {
      now: [event, event],
      now.add(Duration(days: 4)): [event, event, event],
      now.add(Duration(days: 7)): [event, event, event, event],
      now.add(Duration(days: 9)): [event],
    };

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Calendar')),
        body: Container(
          margin: EdgeInsets.all(8),
          child: Calendar(
            onSelectedRangeChange: (start, end) =>
                print("Range is $start, $end"),
            monthView: false,
            firstDate: DateTime(2019, 1, 28),
            dayBuilder: (context, date) {
              DateTime key = dates.keys.firstWhere((dateKey) => DateUtils.isSameDay(date, dateKey), orElse: () => null);
              if (key != null) return dates[key];
              return [];
            },
          ),
        ),
      ),
    );
  }
}

class Event extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(top: 2.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        'Example of an event',
        maxLines: 1,
        style: const TextStyle(fontSize: 10.0, color: Colors.white),
      ),
    );
  }
}

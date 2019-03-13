import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

main() => runApp(CalendarViewApp());

class CalendarViewApp extends StatelessWidget {
  DateTime getDate([int days = 0, int minutes = 0]) {
    return DateTime.now().add(Duration(days: days, minutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    final dates = {
      getDate(): [
        Event('Event #1', getDate()),
        Event('Event #2', getDate(0, 3)),
        Event('Event #2', getDate(0, 5))
      ],
      getDate(4): [
        Event('Event #3', getDate(4)),
        Event('Event #4', getDate(4, 3))
      ],
      getDate(7): [
        Event('Event #5', getDate(7)),
        Event('Event #6', getDate(7, 3)),
        Event('Event #7', getDate(7, 3))
      ],
      getDate(9): [Event('Event #8', getDate(9))],
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
              DateTime key = dates.keys.firstWhere(
                (dateKey) => DateUtils.isSameDay(date, dateKey),
                orElse: () => null,
              );
              if (key != null)
                return dates[key].map((e) => DayEvent(event: e)).toList();
              return [];
            },
          ),
        ),
      ),
    );
  }
}

class DayEvent extends StatelessWidget {
  final Event event;

  const DayEvent({Key key, this.event}) : super(key: key);

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
        event.title,
        maxLines: 1,
        style: const TextStyle(fontSize: 10.0, color: Colors.white),
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime date;

  Event(this.title, this.date);
}

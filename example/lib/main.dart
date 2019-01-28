import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

main() => runApp(CalendarViewApp());

class CalendarViewApp extends StatelessWidget {
  void handleNewDate(date) {
    print("handleNewDate $date");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Calendar')),
        body: Container(
          margin: EdgeInsets.all(8),
          child: Calendar(
            onSelectedRangeChange: (start, end) =>
                print("Range is $start, $end"),
            monthView: true,
            firstDate: DateTime(2019, 1, 28),
            initialCalendarDateOverride: DateTime.now(),
            dayBuilder: (context, date) => [
                  Event(),
                  Event(),
                  Event(),
                  Event(),
                ],
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
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        'Example of an event',
        maxLines: 1,
        style: TextStyle(fontSize: 11.0),
      ),
    );
  }
}

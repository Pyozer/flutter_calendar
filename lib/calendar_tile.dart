import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final List<Widget> children;

  CalendarTile({
    this.onDateSelected,
    this.date,
    this.children,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek: false,
    this.isSelected: false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDayOfWeek) {
      return InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(dayOfWeek, style: dayOfWeekStyles),
        ),
      );
    }
    final borderColor =
        isSelected ? Theme.of(context).accentColor : Colors.transparent;

    return InkWell(
      onTap: onDateSelected,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5.0),
            Text(
              DateUtils.formatDay(date).toString(),
              style: isSelected ? Theme.of(context).textTheme.body1 : dateStyles,
            ),
            const SizedBox(height: 5.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: children ?? [],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

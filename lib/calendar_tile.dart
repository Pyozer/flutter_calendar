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
    return InkWell(
      onTap: onDateSelected,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).primaryColor,
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5.0),
            Text(
              Utils.formatDay(date).toString(),
              style: isSelected
                  ? Theme.of(context).primaryTextTheme.body1
                  : dateStyles,
            ),
            const SizedBox(height: 5.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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

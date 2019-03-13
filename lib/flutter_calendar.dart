import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/calendar_tile.dart';
import 'package:flutter_calendar/date_utils.dart';

typedef List<Widget> DayBuilder(BuildContext context, DateTime day);
typedef void SelectedRangeChanged(DateTime start, DateTime end);

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final SelectedRangeChanged onSelectedRangeChange;
  final bool monthView;
  final DayBuilder dayBuilder;
  final bool showChevronsToChangeRange;
  final bool showTodayAction;
  final bool isCalendarPicker;
  final DateTime initialSelectedDate;
  final DateTime firstDate;
  final DateTime endDate;
  final bool startMonday;
  final List<String> weekdays;

  const Calendar({
    this.onDateSelected,
    this.onSelectedRangeChange,
    this.monthView: true,
    this.dayBuilder,
    this.showTodayAction: true,
    this.showChevronsToChangeRange: true,
    this.isCalendarPicker: true,
    this.initialSelectedDate,
    this.firstDate,
    this.endDate,
    this.startMonday = true,
    this.weekdays = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<DateTime> _calendarDays = [];
  DateTime _selectedDate;
  String _displayMonth;

  @override
  void initState() {
    super.initState();
    _initCalendar();
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initCalendar();
  }

  void _initCalendar() {
    _selectedDate = widget.initialSelectedDate ?? DateTime.now();
    DateUtils.setIsMondayFirstDayOfWeek(widget.startMonday);
    _updateListDays(_selectedDate, false);
  }

  void _updateListDays(DateTime newDate, [bool callback = true]) {
    _selectedDate = newDate;
    if (widget.monthView) {
      _calendarDays = DateUtils.daysInMonth(_selectedDate);
    } else {
      final firstDayOfWeek = DateUtils.firstDayOfWeek(_selectedDate);
      final lastDayOfWeek = DateUtils.lastDayOfWeek(_selectedDate);
      _calendarDays = DateUtils.daysInRange(
        firstDayOfWeek,
        lastDayOfWeek,
      ).toList();
      _calendarDays = _calendarDays.sublist(0, min(7, _calendarDays.length));
    }
    setState(() => _displayMonth = DateUtils.formatMonth(_selectedDate));
    if (callback) _updateSelectedRange(_calendarDays.first, _calendarDays.last);
  }

  Widget get nameAndIconRow {
    var leftInnerIcon;
    var leftOuterIcon;
    var rightOuterIcon;

    if (widget.showChevronsToChangeRange) {
      leftOuterIcon = IconButton(
        onPressed: widget.monthView ? previousMonth : previousWeek,
        icon: const Icon(Icons.chevron_left),
      );
      rightOuterIcon = IconButton(
        onPressed: widget.monthView ? nextMonth : nextWeek,
        icon: const Icon(Icons.chevron_right),
      );
    }

    if (widget.showTodayAction) {
      leftInnerIcon = FlatButton(
        child: const Text('Today'),
        onPressed: resetToToday,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftOuterIcon,
        Expanded(child: leftInnerIcon ?? const SizedBox.shrink()),
        GestureDetector(
          onTap: widget.isCalendarPicker ? _selectDateFromPicker : null,
          child: Text(_displayMonth, style: const TextStyle(fontSize: 20.0)),
        ),
        Expanded(child: const SizedBox.shrink()),
        rightOuterIcon,
      ]..removeWhere((e) => e == null),
    );
  }

  Widget get calendarGridView {
    return GestureDetector(
      onHorizontalDragStart: beginSwipe,
      onHorizontalDragUpdate: getDirection,
      onHorizontalDragEnd: endSwipe,
      child: Column(children: calendarRowsBuilder()),
    );
  }

  Widget _buildRow([List<Widget> children]) {
    return Expanded(
      child: (children == null)
          ? const SizedBox.shrink()
          : Row(children: children),
    );
  }

  List<Widget> calendarRowsBuilder() {
    List<Widget> weeksWidgets = [];

    bool monthStarted = false;
    bool monthEnded = false;

    int dayNum = 1;
    List<Widget> weekDays = [];
    _calendarDays.forEach((day) {
      if (dayNum > 7) {
        weeksWidgets.add(_buildRow(weekDays.toList()));
        weekDays.clear();
        dayNum = 1;
      }

      if (monthStarted && day.day == 1) monthEnded = true;
      if (DateUtils.isFirstDayOfMonth(day)) monthStarted = true;

      final dayWidget = Expanded(
        child: CalendarTile(
          onDateSelected: () => handleSelectedDateAndUserCallback(day),
          date: day,
          dateStyles: configureDateStyle(monthStarted, monthEnded),
          isSelected: DateUtils.isSameDay(_selectedDate, day),
          children: (widget.dayBuilder != null)
              ? widget.dayBuilder(context, day)
              : [],
        ),
      );
      weekDays.add(dayWidget);
      dayNum++;
    });
    if (weekDays.length > 0)
      weeksWidgets.add(_buildRow(weekDays.toList())); // Add last row
    // Add empty extended row to always have 6 rows
    while (widget.monthView && weeksWidgets.length < 6)
      weeksWidgets.add(_buildRow());

    return weeksWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    final TextStyle body1Style = Theme.of(context).textTheme.body1;

    if (widget.monthView) {
      return monthStarted && !monthEnded
          ? body1Style
          : body1Style.copyWith(color: body1Style.color.withAlpha(100));
    }
    return body1Style;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        nameAndIconRow,
        const SizedBox(height: 12.0),
        Row(
          children: widget.weekdays.map((day) {
            return Expanded(
              child: CalendarTile(isDayOfWeek: true, dayOfWeek: day),
            );
          }).toList(),
        ),
        const SizedBox(height: 12.0),
        Expanded(child: calendarGridView),
      ],
    );
  }

  void resetToToday() {
    _updateListDays(DateTime.now());
    _launchDateSelectionCallback(_selectedDate);
  }

  void nextMonth() => _updateListDays(DateUtils.nextMonth(_selectedDate));
  void previousMonth() =>
      _updateListDays(DateUtils.previousMonth(_selectedDate));

  void nextWeek() => _updateListDays(DateUtils.nextWeek(_selectedDate));
  void previousWeek() => _updateListDays(DateUtils.previousWeek(_selectedDate));

  Future<Null> _selectDateFromPicker() async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1960),
      lastDate: widget.endDate ?? DateTime(2050),
    );

    if (selected != null) {
      _updateListDays(selected);
      _launchDateSelectionCallback(selected);
    }
  }

  var gestureStart, gestureDirection;

  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart)
      gestureDirection = 'rightToLeft';
    else
      gestureDirection = 'leftToRight';
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (widget.monthView)
        nextMonth();
      else
        nextWeek();
    } else {
      if (widget.monthView)
        previousMonth();
      else
        previousWeek();
    }
  }

  void _updateSelectedRange(DateTime start, DateTime end) {
    if (widget.onSelectedRangeChange != null)
      widget.onSelectedRangeChange(start, end);
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    _updateListDays(day);
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) widget.onDateSelected(day);
  }
}

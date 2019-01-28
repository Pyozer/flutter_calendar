import 'dart:async';

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
  final bool showCalendarPickerIcon;
  final DateTime initialCalendarDateOverride;
  final DateTime firstDate;
  final DateTime endDate;
  final bool startMonday;
  final List<String> weekdays;

  Calendar({
    this.onDateSelected,
    this.onSelectedRangeChange,
    this.monthView: true,
    this.dayBuilder,
    this.showTodayAction: true,
    this.showChevronsToChangeRange: true,
    this.showCalendarPickerIcon: true,
    this.initialCalendarDateOverride,
    this.firstDate,
    this.endDate,
    this.startMonday = true,
    this.weekdays = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final calendarUtils = Utils();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  DateTime _selectedDate = DateTime.now();
  String currentMonth;
  String displayMonth;

  @override
  void initState() {
    super.initState();
    if (widget.initialCalendarDateOverride != null)
      _selectedDate = widget.initialCalendarDateOverride;
    Utils.setIsMondayFirstDayOfWeek(widget.startMonday);
    selectedMonthsDays = Utils.daysInMonth(_selectedDate);
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
    selectedWeeksDays =
        Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
            .toList()
            .sublist(0, 7);
    displayMonth = Utils.formatMonth(_selectedDate);
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
        GestureDetector(
          onTap: _selectDateFromPicker,
          child: Text(displayMonth, style: const TextStyle(fontSize: 20.0)),
        ),
        rightOuterIcon,
      ]..removeWhere((e) => e == null),
    );
  }

  Widget get calendarGridView {
    return GestureDetector(
      onHorizontalDragStart: beginSwipe,
      onHorizontalDragUpdate: getDirection,
      onHorizontalDragEnd: endSwipe,
      child: Column(
        children: calendarRowsBuilder(),
      ),
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
    List<DateTime> calendarDays =
        widget.monthView ? selectedMonthsDays : selectedWeeksDays;

    bool monthStarted = false;
    bool monthEnded = false;

    int dayNum = 1;
    List<Widget> weekDays = [];
    calendarDays.forEach((day) {
      if (dayNum > 7) {
        weeksWidgets.add(_buildRow(weekDays.toList()));
        weekDays.clear();
        dayNum = 1;
      }

      if (monthStarted && day.day == 1) monthEnded = true;
      if (Utils.isFirstDayOfMonth(day)) monthStarted = true;

      final dayWidget = Expanded(
        child: CalendarTile(
          onDateSelected: () => handleSelectedDateAndUserCallback(day),
          date: day,
          dateStyles: configureDateStyle(monthStarted, monthEnded),
          isSelected: Utils.isSameDay(_selectedDate, day),
          children: (widget.dayBuilder != null)
              ? widget.dayBuilder(context, day)
              : [],
        ),
      );
      weekDays.add(dayWidget);
      dayNum++;
    });
    // If week row is not finished
    if (weekDays.length > 0 && weekDays.length < 7) {
      weekDays.addAll(List.generate(7 - weekDays.length, (_) => _buildRow()));
    }
    weeksWidgets.add(_buildRow(weekDays.toList())); // Add last row
    // Add empty extended row to always have 6 rows
    if (weeksWidgets.length != 6) weeksWidgets.add(_buildRow());

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
    _selectedDate = DateTime.now();
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);

    setState(() {
      selectedWeeksDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      displayMonth = Utils.formatMonth(_selectedDate);
    });

    _launchDateSelectionCallback(_selectedDate);
  }

  void nextMonth() => updateMonth(Utils.nextMonth(_selectedDate));

  void previousMonth() => updateMonth(Utils.previousMonth(_selectedDate));

  void updateMonth(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      displayMonth = Utils.formatMonth(_selectedDate);
    });
  }

  void nextWeek() => _updateWeek(Utils.nextWeek(_selectedDate));

  void previousWeek() => _updateWeek(Utils.previousWeek(_selectedDate));

  void _updateWeek(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList()
              .sublist(0, 7);
      displayMonth = Utils.formatMonth(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange(start, end);
    }
  }

  Future<Null> _selectDateFromPicker() async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1960),
      lastDate: widget.endDate ?? DateTime(2050),
    );

    if (selected != null) {
      final firstDayOfCurrentWeek = Utils.firstDayOfWeek(selected);
      final lastDayOfCurrentWeek = Utils.lastDayOfWeek(selected);

      setState(() {
        _selectedDate = selected;
        selectedWeeksDays =
            Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
                .toList();
        selectedMonthsDays = Utils.daysInMonth(selected);
        displayMonth = Utils.formatMonth(selected);
      });
      // updating selected date range based on selected week
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      _launchDateSelectionCallback(selected);
    }
  }

  var gestureStart;
  var gestureDirection;

  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
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

  void handleSelectedDateAndUserCallback(DateTime day) {
    final firstDayOfCurrentWeek = Utils.firstDayOfWeek(day);
    final lastDayOfCurrentWeek = Utils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      selectedWeeksDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = Utils.daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);
    }
  }
}

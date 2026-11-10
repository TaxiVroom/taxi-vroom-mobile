const _weekdays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

const _shortMonths = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

// "Ven. 25 sept., 18:42".
String formatShortDateTime(DateTime time) =>
    '${formatShortWeekday(time)}. ${time.day} '
    '${_shortMonths[time.month - 1]}, ${formatClockTime(time)}';

// "Ven", e.g. under a chart bar.
String formatShortWeekday(DateTime day) =>
    _weekdays[day.weekday - 1].substring(0, 3);

// "Lundi 28 sept.".
String formatLongDate(DateTime day) =>
    '${_weekdays[day.weekday - 1]} ${day.day} ${_shortMonths[day.month - 1]}';

// "11 mars 2027", e.g. the end of validity of a document.
String formatDateWithYear(DateTime day) =>
    '${day.day} ${_shortMonths[day.month - 1]} ${day.year}';

// 15:01 -> "15:01".
String formatClockTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

// "Aujourd'hui", "Demain", then "Lundi 28".
String formatDayLabel(DateTime day, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final daysFromToday = DateTime(
    day.year,
    day.month,
    day.day,
  ).difference(today).inDays;
  return switch (daysFromToday) {
    0 => "Aujourd'hui",
    1 => 'Demain',
    _ => '${_weekdays[day.weekday - 1]} ${day.day}',
  };
}

// null -> "Maintenant", otherwise "Demain 06:15".
String formatPickupTime(DateTime? scheduledPickup, {required DateTime now}) =>
    scheduledPickup == null
    ? 'Maintenant'
    : '${formatDayLabel(scheduledPickup, now: now)} '
          '${formatClockTime(scheduledPickup)}';

// Same, inside a sentence: "Réserver pour demain 06:15".
String formatPickupTimeInSentence(
  DateTime? scheduledPickup, {
  required DateTime now,
}) {
  final label = formatPickupTime(scheduledPickup, now: now);
  return '${label[0].toLowerCase()}${label.substring(1)}';
}

// Time waited: 72 seconds -> "1:12".
String formatWaitingTime(Duration waited) =>
    '${waited.inMinutes}:'
    '${(waited.inSeconds % 60).toString().padLeft(2, '0')}';

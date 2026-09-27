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
    '${_weekdays[time.weekday - 1].substring(0, 3)}. ${time.day} '
    '${_shortMonths[time.month - 1]}, ${formatClockTime(time)}';

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

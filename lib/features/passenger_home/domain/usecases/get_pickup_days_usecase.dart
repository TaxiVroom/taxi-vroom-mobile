import 'package:mobile/features/passenger_home/domain/entities/pickup_day.dart';

// Days and time slots offered when booking a taxi in advance.
class GetPickupDaysUseCase {
  const GetPickupDaysUseCase();

  // Today and the next 30 days.
  static const _bookableDays = 31;
  static const _slotStep = Duration(minutes: 15);

  // A booked taxi needs time to be assigned: no pickup sooner than this.
  static const _minimumLeadTime = Duration(minutes: 30);

  static bool isBookable(DateTime pickup, {required DateTime now}) =>
      !pickup.isBefore(now.add(_minimumLeadTime));

  List<PickupDay> call({required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var offset = 0; offset < _bookableDays; offset++)
        _pickupDay(DateTime(today.year, today.month, today.day + offset), now),
    ].where((day) => day.slots.isNotEmpty).toList();
  }

  PickupDay _pickupDay(DateTime date, DateTime now) {
    final nextDay = DateTime(date.year, date.month, date.day + 1);
    return PickupDay(
      date: date,
      slots: [
        for (
          var slot = date;
          slot.isBefore(nextDay);
          slot = slot.add(_slotStep)
        )
          if (isBookable(slot, now: now)) slot,
      ],
    );
  }
}

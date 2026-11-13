import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_bookings_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_flow_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/trip_stops.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 9: rides booked in advance, to pick or already accepted.
class DriverBookingsTab extends StatefulWidget {
  const DriverBookingsTab({super.key});

  @override
  State<DriverBookingsTab> createState() => _DriverBookingsTabState();
}

class _DriverBookingsTabState extends State<DriverBookingsTab> {
  // Which list is shown: a display choice only, it stays in the widget.
  bool _showsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<DriverBookingsBloc, DriverBookingsState>(
        // A failed answer: the same message at the bottom as elsewhere.
        listenWhen: (_, current) =>
            current is DriverBookingsReady && current.failureMessage != null,
        listener: (context, state) => showMessageToast(
          context,
          title: 'Action impossible',
          message: (state as DriverBookingsReady).failureMessage!,
        ),
        builder: (context, state) => switch (state) {
          // Departed: the pickup screen opens, the lists reload meanwhile.
          DriverBookingsLoading() || DriverBookingsDeparted() => const Center(
            child: CircularProgressIndicator(),
          ),
          DriverBookingsFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () => context.read<DriverBookingsBloc>().add(
              const DriverBookingsRequested(),
            ),
          ),
          DriverBookingsReady() => _buildReady(context, state),
        },
      ),
    );
  }

  // "Les réservations après le 11 mars 2027 ne vous sont pas proposées :
  // Carte professionnelle de taxi expire le 11 mars 2027." Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
  Widget _buildHiddenByDocuments(BuildContext context) {
    final flow = context.watch<DriverFlowBloc>().state;
    final documents = flow is DriverFlowHome ? flow.documents : null;
    final soonest = documents?.soonestEnd;
    if (soonest == null || !soonest.needsAction) {
      return const SizedBox.shrink();
    }
    final when = _hiddenFrom(soonest);
    if (when == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Alert(
        leading: const Icon(Icons.info_outline),
        title: Text('Réservations $when non proposées'),
        content: Text('${soonest.name} : envoyez le nouveau pour les voir.'),
      ),
    );
  }

  // "après le 11 mars 2027", or "à partir du 1 mars 2027" for a new type.
  String? _hiddenFrom(DriverDocument document) {
    final lastValidDay = document.lastValidDay;
    if (lastValidDay != null) {
      return 'après le ${formatDateWithYear(lastValidDay)}';
    }
    final requiredFrom = document.requiredFrom;
    if (requiredFrom == null) return null;
    return 'à partir du ${formatDateWithYear(requiredFrom.toLocal())}';
  }

  Widget _buildReady(BuildContext context, DriverBookingsReady state) {
    final bookings = state.bookings;
    final shown = _showsAccepted ? bookings.accepted : bookings.available;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Réservations',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ChoiceButton(
                label: 'Disponibles',
                isSelected: !_showsAccepted,
                onPressed: () => setState(() => _showsAccepted = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceButton(
                label: 'Acceptées (${bookings.accepted.length})',
                isSelected: _showsAccepted,
                onPressed: () => setState(() => _showsAccepted = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!_showsAccepted) _buildHiddenByDocuments(context),
        if (shown.isEmpty)
          Text(
            _showsAccepted
                ? 'Aucune réservation acceptée.'
                : 'Aucune réservation dans votre zone pour l’instant.',
            style: const TextStyle(color: AppColors.muted),
          ),
        for (final booking in shown)
          _buildBooking(
            context,
            booking,
            isAnswering: state.answeringId == booking.id,
            isRefusing: state.isRefusing,
            canAnswer: state.answeringId == null,
          ),
      ],
    );
  }

  // One answer at a time: while one is sent, no button reacts, and the
  // loader turns on the button tapped.
  Widget _buildBooking(
    BuildContext context,
    DriverBooking booking, {
    required bool isAnswering,
    required bool isRefusing,
    required bool canAnswer,
  }) {
    final bloc = context.read<DriverBookingsBloc>();
    final requirement = booking.requirement;
    final passengers = booking.passengerCount > 1
        ? '${booking.passengerCount} passagers'
        : '${booking.passengerCount} passager';
    final details = [
      formatDistanceKm(booking.distanceKm),
      requirement ?? passengers,
    ].join(', ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPickupTime(booking),
              Text(
                formatEuroRange(booking.minPriceCents, booking.maxPriceCents),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TripStops(
            pickupName: booking.pickupName,
            destinationName: booking.destinationName,
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          if (_showsAccepted && booking.canDepart)
            PrimaryButton(
              onPressed: canAnswer
                  ? () => bloc.add(DriverBookingDeparted(bookingId: booking.id))
                  : null,
              alignment: Alignment.center,
              trailing: isAnswering ? _loader(onSurface: true) : null,
              child: const Text('Je pars'),
            )
          else if (_showsAccepted)
            OutlineButton(
              onPressed: canAnswer
                  ? () =>
                        bloc.add(DriverBookingWithdrawn(bookingId: booking.id))
                  : null,
              alignment: Alignment.center,
              trailing: isAnswering ? _loader(onSurface: false) : null,
              child: const Text('Se désister'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    onPressed: canAnswer
                        ? () => bloc.add(
                            DriverBookingRefused(bookingId: booking.id),
                          )
                        : null,
                    alignment: Alignment.center,
                    trailing: isAnswering && isRefusing
                        ? _loader(onSurface: false)
                        : null,
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    onPressed: canAnswer
                        ? () => bloc.add(
                            DriverBookingAccepted(bookingId: booking.id),
                          )
                        : null,
                    alignment: Alignment.center,
                    trailing: isAnswering && !isRefusing
                        ? _loader(onSurface: true)
                        : null,
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // In a button, as long as its text: onSurface on a filled button.
  Widget _loader({required bool onSurface}) => AspectRatio(
    aspectRatio: 1,
    child: CircularProgressIndicator(onSurface: onSurface),
  );

  // "Demain 06:15", green like the other bookings in the app.
  Widget _buildPickupTime(DriverBooking booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_outlined, size: 14, color: AppColors.freeTaxi),
          const SizedBox(width: 6),
          Text(
            formatPickupTime(booking.scheduledPickup, now: DateTime.now()),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.freeTaxi,
            ),
          ),
        ],
      ),
    );
  }
}

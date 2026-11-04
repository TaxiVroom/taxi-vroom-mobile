import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/passenger_home/domain/entities/pickup_day.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/arrival_pickup_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Opens mockup screen 6 and stores the chosen pickup time in the flow.
///
/// With an [arrivalPickupBloc] (the destination is known), the passenger can
/// also choose an arrival time.
Future<void> openPickupTimeSheet(
  BuildContext context, {
  ArrivalPickupBloc? arrivalPickupBloc,
}) async {
  final flowBloc = context.read<PassengerFlowBloc>()
    ..add(const PassengerPickupTimeSheetOpened());
  final choice = await showModalBottomSheet<({DateTime? scheduledPickup})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocBuilder<PassengerFlowBloc, PassengerFlowState>(
      bloc: flowBloc,
      // The sheet shows once its days are computed.
      buildWhen: (previous, current) =>
          previous.pickupDays.isEmpty && current.pickupDays.isNotEmpty,
      builder: (_, flowState) => flowState.pickupDays.isEmpty
          ? const SizedBox.shrink()
          : PickupTimeSheet(
              pickupDays: flowState.pickupDays,
              scheduledPickup: flowState.scheduledPickup,
              arrivalPickupBloc: arrivalPickupBloc,
            ),
    ),
  );
  // Null choice: the sheet was closed without confirming.
  if (choice != null) {
    flowBloc.add(
      PassengerPickupTimeChanged(scheduledPickup: choice.scheduledPickup),
    );
  }
}

/// "Maintenant" or "Plus tard", with a day and a pickup (or arrival) time
/// slot.
class PickupTimeSheet extends StatefulWidget {
  const PickupTimeSheet({
    required this.pickupDays,
    required this.scheduledPickup,
    this.arrivalPickupBloc,
    super.key,
  });

  final List<PickupDay> pickupDays;
  final DateTime? scheduledPickup;
  final ArrivalPickupBloc? arrivalPickupBloc;

  @override
  State<PickupTimeSheet> createState() => _PickupTimeSheetState();
}

class _PickupTimeSheetState extends State<PickupTimeSheet> {
  late bool _isLater = widget.scheduledPickup != null;
  // Reopened after an "Arriver à" choice: show that arrival time again.
  late bool _isArrival = _previousArrival != null;
  // The pickup time, or the arrival time when [_isArrival].
  late DateTime? _slot = _previousArrival ?? widget.scheduledPickup;
  late int _dayIndex = _initialDayIndex();

  DateTime? get _previousArrival {
    final arrivalPickup = widget.arrivalPickupBloc?.state;
    return arrivalPickup is ArrivalPickupReady &&
            arrivalPickup.pickup == widget.scheduledPickup
        ? arrivalPickup.arrival
        : null;
  }

  int _initialDayIndex() {
    final index = widget.pickupDays.indexWhere(
      (day) => day.slots.contains(_slot),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final arrivalPickupBloc = widget.arrivalPickupBloc;
    return BottomPanel(
      child: SafeArea(
        top: false,
        child: arrivalPickupBloc == null
            ? _buildContent(null)
            : BlocBuilder<ArrivalPickupBloc, ArrivalPickupState>(
                bloc: arrivalPickupBloc,
                builder: (_, arrivalPickup) => _buildContent(arrivalPickup),
              ),
      ),
    );
  }

  Widget _buildContent(ArrivalPickupState? arrivalPickup) {
    final pickup = _pickup(arrivalPickup);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildNowOrLater(),
        if (_isLater && widget.pickupDays.isNotEmpty) ...[
          if (arrivalPickup != null) ...[
            const SizedBox(height: 8),
            _buildDepartureOrArrival(),
          ],
          ..._buildLaterPicker(),
          if (_isArrival && arrivalPickup != null && _slot != null) ...[
            const SizedBox(height: 8),
            _buildArrivalPickup(arrivalPickup),
          ],
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          onPressed: !_isLater || pickup != null
              ? () => _onConfirmed(pickup)
              : null,
          alignment: Alignment.center,
          child: Text(_confirmLabel(pickup)),
        ),
      ],
    );
  }

  // The pickup time to book, once known.
  DateTime? _pickup(ArrivalPickupState? arrivalPickup) {
    if (!_isArrival) return _slot;
    return arrivalPickup is ArrivalPickupReady && arrivalPickup.arrival == _slot
        ? arrivalPickup.pickup
        : null;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Quand partez-vous ?',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        GhostButton(
          density: ButtonDensity.icon,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildNowOrLater() {
    return Row(
      children: [
        Expanded(
          child: ChoiceButton(
            label: 'Maintenant',
            isSelected: !_isLater,
            onPressed: () => setState(() => _isLater = false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceButton(
            label: 'Plus tard',
            isSelected: _isLater,
            onPressed: () => setState(() => _isLater = true),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartureOrArrival() {
    return Row(
      children: [
        Expanded(
          child: ChoiceButton(
            label: 'Partir à',
            isSelected: !_isArrival,
            onPressed: () => _onDepartureOrArrivalChanged(isArrival: false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceButton(
            label: 'Arriver à',
            isSelected: _isArrival,
            onPressed: () => _onDepartureOrArrivalChanged(isArrival: true),
          ),
        ),
      ],
    );
  }

  // A pickup slot is not an arrival slot: switching clears it.
  void _onDepartureOrArrivalChanged({required bool isArrival}) {
    if (isArrival == _isArrival) return;
    setState(() {
      _isArrival = isArrival;
      _slot = null;
    });
  }

  Widget _buildArrivalPickup(ArrivalPickupState arrivalPickup) {
    return switch (arrivalPickup) {
      ArrivalPickupReady(:final arrival, :final pickup) => Text(
        'Prise en charge conseillée à ${formatClockTime(pickup)} pour '
        'arriver à ${formatClockTime(arrival)}, selon le trafic habituel.',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      ArrivalPickupFailure(:final message) => Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.muted),
      ),
      ArrivalPickupLoading() || ArrivalPickupIdle() => const Text(
        'Calcul de l’heure de prise en charge…',
        style: TextStyle(fontSize: 13, color: AppColors.muted),
      ),
    };
  }

  void _onSlotSelected(DateTime slot) {
    setState(() => _slot = slot);
    final arrivalPickupBloc = widget.arrivalPickupBloc;
    if (_isArrival && arrivalPickupBloc != null) {
      arrivalPickupBloc.add(ArrivalTimeChanged(arrival: slot));
    }
  }

  List<Widget> _buildLaterPicker() {
    final now = DateTime.now();
    final selectedDay = widget.pickupDays[_dayIndex];
    return [
      const SizedBox(height: 16),
      const SectionLabel('Jour'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (index, day) in widget.pickupDays.indexed)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceButton(
                  label: formatDayLabel(day.date, now: now),
                  isSelected: index == _dayIndex,
                  // A slot belongs to one day: changing day clears it.
                  onPressed: () => setState(() {
                    _dayIndex = index;
                    _slot = null;
                  }),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionLabel(
        _isArrival ? 'Heure d’arrivée' : 'Heure de prise en charge',
      ),
      SizedBox(
        height: 200,
        child: GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final slot in selectedDay.slots)
              ChoiceButton(
                label: formatClockTime(slot),
                isSelected: slot == _slot,
                onPressed: () => _onSlotSelected(slot),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Annulation gratuite.',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ];
  }

  String _confirmLabel(DateTime? pickup) {
    if (!_isLater) return 'Partir maintenant';
    if (pickup == null) return 'Choisissez une heure';
    return 'Réserver pour '
        '${formatPickupTimeInSentence(pickup, now: DateTime.now())}';
  }

  void _onConfirmed(DateTime? pickup) {
    Navigator.of(context).pop((scheduledPickup: _isLater ? pickup : null));
  }
}

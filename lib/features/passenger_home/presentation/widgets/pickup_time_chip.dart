import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/arrival_pickup_cubit.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_cubit.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/pickup_time_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Shows the chosen pickup time ("Maintenant", "Demain 06:15") and opens the
/// sheet to change it.
class PickupTimeChip extends StatelessWidget {
  const PickupTimeChip({this.canChooseArrival = false, super.key});

  // Offers "Arriver à" in the sheet: needs an [ArrivalPickupCubit] above,
  // i.e. a known destination.
  final bool canChooseArrival;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerFlowCubit, PassengerFlowState>(
      buildWhen: (previous, current) =>
          previous.scheduledPickup != current.scheduledPickup,
      builder: (context, state) => OutlineButton(
        onPressed: () => openPickupTimeSheet(
          context,
          arrivalPickupCubit: canChooseArrival
              ? context.read<ArrivalPickupCubit>()
              : null,
        ),
        leading: const Icon(Icons.schedule, size: 16),
        child: Text(
          formatPickupTime(state.scheduledPickup, now: DateTime.now()),
        ),
      ),
    );
  }
}

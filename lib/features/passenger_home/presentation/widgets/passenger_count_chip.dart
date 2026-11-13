import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Shows how many people travel ("1 passager", "6 passagers") and opens the
/// list from "1 passager" to "8 passagers" to change it: a taxi has eight
/// seats at most (article L3121-1 du code des transports). Spec
/// taxi-vroom-api/docs/specs/nombre-de-passagers.md.
class PassengerCountChip extends StatelessWidget {
  const PassengerCountChip({super.key});

  static const _maxPassengers = 8;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerFlowBloc, PassengerFlowState>(
      buildWhen: (previous, current) =>
          previous.passengerCount != current.passengerCount,
      builder: (context, state) {
        final flowBloc = context.read<PassengerFlowBloc>();
        // The menu opens under the button that was tapped.
        return Builder(
          builder: (buttonContext) => OutlineButton(
            onPressed: () => showDropdown<void>(
              context: buttonContext,
              builder: (_) => DropdownMenu(
                children: [
                  MenuRadioGroup<int>(
                    value: state.passengerCount,
                    onChanged: (_, chosen) => flowBloc.add(
                      PassengerCountChanged(passengerCount: chosen),
                    ),
                    children: [
                      for (var count = 1; count <= _maxPassengers; count++)
                        MenuRadio(value: count, child: Text(_label(count))),
                    ],
                  ),
                ],
              ),
            ),
            leading: const Icon(Icons.person_outline, size: 16),
            child: Text(_label(state.passengerCount)),
          ),
        );
      },
    );
  }

  static String _label(int count) =>
      count > 1 ? '$count passagers' : '$count passager';
}

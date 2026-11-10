import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_flow_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// On the home, a document to renew or to provide: "Carte professionnelle :
/// valable jusqu'au 11 mars 2027 inclus · Renouveler". Nothing when everything is in order.
/// Spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class DocumentsBanner extends StatelessWidget {
  const DocumentsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverFlowBloc, DriverFlowState>(
      buildWhen: (previous, current) => current is DriverFlowHome,
      builder: (context, state) {
        final documents = state is DriverFlowHome ? state.documents : null;
        final next = documents?.nextToProvide;
        if (documents == null || next == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Alert(
            leading: const Icon(Icons.description_outlined),
            title: Text(next.name),
            content: Text(_detail(next)),
            trailing: GhostButton(
              onPressed: () => context.read<DriverFlowBloc>().add(
                DriverDocumentsOpened(documents: documents),
              ),
              child: const Text('Renouveler'),
            ),
          ),
        );
      },
    );
  }

  String _detail(DriverDocument document) {
    final requiredFrom = document.requiredFrom;
    final lastValidDay = document.lastValidDay;
    if (document.status == DriverDocumentStatus.toProvide &&
        requiredFrom != null) {
      return 'À fournir avant le ${formatDateWithYear(requiredFrom.toLocal())}';
    }
    if (document.blocksDriving) return 'Vous ne pouvez plus passer en ligne';
    if (lastValidDay == null) return 'À envoyer';
    return 'Valable jusqu’au ${formatDateWithYear(lastValidDay)} inclus';
  }
}

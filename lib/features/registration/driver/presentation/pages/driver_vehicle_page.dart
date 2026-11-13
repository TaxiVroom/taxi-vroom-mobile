import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextCapitalization, TextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/vehicle_color.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/search_text_field.dart';
import 'package:mobile/features/registration/driver/domain/entities/commune.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/driver/domain/usecases/search_communes_usecase.dart';
import 'package:mobile/features/registration/driver/presentation/bloc/commune_search_bloc.dart';
import 'package:mobile/features/registration/driver/presentation/bloc/driver_registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_event.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Votre taxi", between the name and the documents: what the passengers
/// will look for. The carte grise sent next proves it. Spec
/// taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md.
class DriverVehiclePage extends StatelessWidget {
  const DriverVehiclePage({required this.searchCommunesUseCase, super.key});

  final SearchCommunesUseCase searchCommunesUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CommuneSearchBloc(searchCommunesUseCase: searchCommunesUseCase),
      child: const _DriverVehicleView(),
    );
  }
}

class _DriverVehicleView extends StatefulWidget {
  const _DriverVehicleView();

  @override
  State<_DriverVehicleView> createState() => _DriverVehicleViewState();
}

class _DriverVehicleViewState extends State<_DriverVehicleView> {
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _adsNumberController = TextEditingController();
  final _communeController = TextEditingController();
  VehicleColor? _color;
  Commune? _commune;

  // The passenger seats, from 1 to 8: a taxi has eight seats at most (article
  // L3121-1 du code des transports). Null until one is chosen.
  int? _passengerSeats;
  static const _maxPassengerSeats = 8;

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    if (state is DriverRegVehicleReady) _fill(state.vehicle);
  }

  // The vehicle given before, shown again. Also on arriving at this step: the
  // page may have been built under the documents, at a restart, before the
  // step's state carried the vehicle.
  void _fill(RegistrationVehicle? vehicle) {
    if (vehicle == null) return;
    _modelController.text = vehicle.model;
    _plateController.text = vehicle.plate;
    _adsNumberController.text = vehicle.adsNumber;
    _color = vehicle.color;
    _passengerSeats = vehicle.passengerSeats;
    _commune = Commune(
      code: vehicle.communeCode,
      name: vehicle.communeName,
      departmentCode: '',
    );
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _adsNumberController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  // Null while a field is missing or the plate is not "AB-123-CD".
  RegistrationVehicle? get _vehicle {
    final plate = RegistrationVehicle.formatPlate(_plateController.text);
    final color = _color;
    final commune = _commune;
    final passengerSeats = _passengerSeats;
    final model = _modelController.text.trim();
    final adsNumber = _adsNumberController.text.trim();
    if (plate == null || color == null || commune == null) return null;
    if (passengerSeats == null) return null;
    if (model.length < 2 || adsNumber.isEmpty) return null;
    return RegistrationVehicle(
      model: model,
      color: color,
      plate: plate,
      adsNumber: adsNumber,
      communeCode: commune.code,
      communeName: commune.name,
      passengerSeats: passengerSeats,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listenWhen: (previous, current) =>
          previous is! DriverRegVehicleReady &&
          current is DriverRegVehicleReady,
      listener: (context, state) =>
          setState(() => _fill((state as DriverRegVehicleReady).vehicle)),
      builder: (context, state) {
        final vehicleState = state is DriverRegVehicleReady ? state : null;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBackPressed();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            headers: [
              AppBar(
                leading: [
                  GhostButton(
                    density: ButtonDensity.icon,
                    onPressed: _onBackPressed,
                    child: const Icon(Icons.arrow_back),
                  ),
                ],
                title: const Text('Votre taxi'),
                backgroundColor: Colors.white,
              ),
            ],
            footers: [
              _buildContinueButton(
                isSubmitting: vehicleState?.isSubmitting ?? false,
              ),
            ],
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ce que les passagers verront pour reconnaître votre '
                    'taxi. La carte grise demandée ensuite le confirme.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Marque et modèle'),
                  TextField(
                    controller: _modelController,
                    placeholder: const Text('Renault Austral'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Couleur'),
                  _buildColors(),
                  const SizedBox(height: 16),
                  _buildLabel('Plaque d’immatriculation'),
                  _buildPlate(vehicleState),
                  const SizedBox(height: 16),
                  _buildLabel('N° d’autorisation de stationnement'),
                  _buildAdsNumber(vehicleState),
                  const SizedBox(height: 16),
                  _buildLabel('Commune de rattachement'),
                  _buildCommune(),
                  const SizedBox(height: 16),
                  _buildLabel('Places passagers'),
                  _buildPassengerSeats(),
                  if (_otherFailure(vehicleState) case final failure?) ...[
                    const SizedBox(height: 16),
                    Text(
                      failure.message,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildColors() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in VehicleColor.values)
          ChoiceButton(
            label: color.label,
            isSelected: color == _color,
            onPressed: () => setState(() => _color = color),
          ),
      ],
    );
  }

  // Eight buttons like the colors: one tap, every choice in sight. Only
  // taxis with as many seats as passengers get a ride. Spec
  // taxi-vroom-api/docs/specs/nombre-de-passagers.md.
  Widget _buildPassengerSeats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var seats = 1; seats <= _maxPassengerSeats; seats++)
          ChoiceButton(
            label: '$seats',
            isSelected: seats == _passengerSeats,
            onPressed: () => setState(() => _passengerSeats = seats),
          ),
      ],
    );
  }

  // A plate or a taxi number already taken is told under its field, and
  // only while it is still the one refused. Spec
  // taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md, point 7.
  Failure? _otherFailure(DriverRegVehicleReady? state) {
    final failure = state?.failure;
    if (failure is VehiclePlateTakenFailure) return null;
    if (failure is VehicleLicenceTakenFailure) return null;
    return failure;
  }

  String? _plateTakenMessage(DriverRegVehicleReady? state) {
    final failure = state?.failure;
    if (failure is! VehiclePlateTakenFailure) return null;
    final plate = RegistrationVehicle.formatPlate(_plateController.text);
    if (plate != state?.vehicle?.plate) return null;
    return failure.message;
  }

  String? _licenceTakenMessage(DriverRegVehicleReady? state) {
    final failure = state?.failure;
    if (failure is! VehicleLicenceTakenFailure) return null;
    final refused = state?.vehicle;
    if (_adsNumberController.text.trim() != refused?.adsNumber) return null;
    if (_commune?.code != refused?.communeCode) return null;
    return failure.message;
  }

  Widget _buildAdsNumber(DriverRegVehicleReady? state) {
    final takenMessage = _licenceTakenMessage(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _adsNumberController,
          placeholder: const Text('118'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
        ),
        if (takenMessage != null) _buildFieldError(takenMessage),
      ],
    );
  }

  Widget _buildFieldError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.danger),
      ),
    );
  }

  // Told only once something was typed, not on an empty field.
  Widget _buildPlate(DriverRegVehicleReady? state) {
    final typed = _plateController.text.trim();
    final isInvalid =
        typed.isNotEmpty && RegistrationVehicle.formatPlate(typed) == null;
    final takenMessage = _plateTakenMessage(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _plateController,
          placeholder: const Text('AB-123-CD'),
          textCapitalization: TextCapitalization.characters,
          // Only a hint to the keyboard, which may ignore it: the letters
          // are written in capitals whatever is typed.
          inputFormatters: [
            TextInputFormatter.withFunction(
              (_, typed) => typed.copyWith(text: typed.text.toUpperCase()),
            ),
          ],
          onChanged: (_) => setState(() {}),
        ),
        if (isInvalid) _buildFieldError('Plaque au format AB-123-CD'),
        if (takenMessage != null) _buildFieldError(takenMessage),
      ],
    );
  }

  // Chosen in a list, by its INSEE code: the same commune is always written
  // the same way.
  Widget _buildCommune() {
    final commune = _commune;
    if (commune != null) {
      return PlaceListTile(
        icon: Icons.location_city,
        title: commune.name,
        subtitle: commune.departmentCode.isEmpty
            ? 'Commune choisie'
            : 'Département ${commune.departmentCode}',
        trailing: GhostButton(
          onPressed: () => setState(() => _commune = null),
          child: const Text('Changer'),
        ),
      );
    }
    return BlocBuilder<CommuneSearchBloc, CommuneSearchState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchTextField(
            controller: _communeController,
            placeholder: 'Strasbourg',
            isLoading: state.isLoading,
            onChanged: (query) => context.read<CommuneSearchBloc>().add(
              CommuneQueryChanged(query: query),
            ),
          ),
          _buildCommuneResults(state),
        ],
      ),
    );
  }

  Widget _buildCommuneResults(CommuneSearchState state) {
    return SearchResults(
      isLoading: state.isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failureMessage case final message?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          // The list only knows French communes.
          if (state.foundNothing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucune commune trouvée en France',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          for (final found in state.communes)
            PlaceListTile(
              icon: Icons.location_city,
              title: found.name,
              subtitle: 'Département ${found.departmentCode}',
              onPressed: () => setState(() => _commune = found),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton({required bool isSubmitting}) {
    final vehicle = _vehicle;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          onPressed: vehicle == null || isSubmitting
              ? null
              : () => context.read<RegistrationBloc>().add(
                  DriverRegistrationVehicleSubmitted(vehicle: vehicle),
                ),
          alignment: Alignment.center,
          trailing: isSubmitting
              ? const AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(onSurface: true),
                )
              : null,
          child: const Text('Continuer'),
        ),
      ),
    );
  }

  void _onBackPressed() {
    context.read<RegistrationBloc>().add(const RegistrationBackPressed());
  }
}

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart' show MaterialPage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_ride_history_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/update_notifications_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/account_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_cubit.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_home_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/pages/destination_search_page.dart';
import 'package:mobile/features/passenger_home/presentation/pages/ride_page.dart';
import 'package:mobile/features/passenger_home/presentation/pages/taxi_choice_page.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/account_tab.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/passenger_home_map.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/retry_message.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/ride_history_tab.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/where_to_panel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Passenger area after login. [PassengerFlowCubit] states map to the page
/// stack: tabs (home) → destination search → taxi choice, then the ride.
class PassengerHomePage extends StatelessWidget {
  const PassengerHomePage({
    required this.loadPassengerHomeUseCase,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.loadTaxiChoiceUseCase,
    required this.getPickupDaysUseCase,
    required this.requestRideUseCase,
    required this.watchRideUseCase,
    required this.cancelRideUseCase,
    required this.rateRideUseCase,
    required this.bookRideUseCase,
    required this.getPickupForArrivalUseCase,
    required this.loadRideHistoryUseCase,
    required this.cancelBookingUseCase,
    required this.loadAccountUseCase,
    required this.updateNotificationsUseCase,
    required this.onSignOutRequested,
    super.key,
  });

  final LoadPassengerHomeUseCase loadPassengerHomeUseCase;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final LoadTaxiChoiceUseCase loadTaxiChoiceUseCase;
  final GetPickupDaysUseCase getPickupDaysUseCase;
  final RequestRideUseCase requestRideUseCase;
  final WatchRideUseCase watchRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final RateRideUseCase rateRideUseCase;
  final BookRideUseCase bookRideUseCase;
  final GetPickupForArrivalUseCase getPickupForArrivalUseCase;
  final LoadRideHistoryUseCase loadRideHistoryUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final LoadAccountUseCase loadAccountUseCase;
  final UpdateNotificationsUseCase updateNotificationsUseCase;

  /// Lets the parent ([AuthNavigator]) sign the passenger out, without this
  /// widget knowing about authentication.
  final VoidCallback onSignOutRequested;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PassengerHomeBloc(
            loadPassengerHomeUseCase: loadPassengerHomeUseCase,
          )..add(const PassengerHomeStarted()),
        ),
        BlocProvider(
          create: (_) =>
              PassengerFlowCubit(getPickupDaysUseCase: getPickupDaysUseCase),
        ),
        BlocProvider(
          create: (_) => RideHistoryBloc(
            loadRideHistoryUseCase: loadRideHistoryUseCase,
            cancelBookingUseCase: cancelBookingUseCase,
          )..add(const RideHistoryRequested()),
        ),
        BlocProvider(
          create: (_) => AccountBloc(
            loadAccountUseCase: loadAccountUseCase,
            updateNotificationsUseCase: updateNotificationsUseCase,
          )..add(const AccountRequested()),
        ),
      ],
      child: BlocBuilder<PassengerFlowCubit, PassengerFlowState>(
        builder: (context, flowState) => FlowBuilder<PassengerFlowState>(
          state: flowState,
          onGeneratePages: (state, _) => _onGeneratePages(context, state),
        ),
      ),
    );
  }

  List<Page<void>> _onGeneratePages(
    BuildContext context,
    PassengerFlowState flowState,
  ) {
    final tabsPage = MaterialPage<void>(
      key: const ValueKey('passenger-tabs'),
      child: _PassengerTabs(onSignOutRequested: onSignOutRequested),
    );

    // The destination search needs the passenger's position: only reachable
    // once the home is loaded.
    final homeState = context.read<PassengerHomeBloc>().state;
    if (homeState is! PassengerHomeReady) return [tabsPage];

    final destinationPage = MaterialPage<void>(
      key: const ValueKey('destination-search'),
      child: DestinationSearchPage(
        origin: homeState.home.position,
        recentDestinations: homeState.home.recentDestinations,
        suggestDestinationsUseCase: suggestDestinationsUseCase,
        selectDestinationUseCase: selectDestinationUseCase,
      ),
    );

    return switch (flowState) {
      PassengerFlowHome() => [tabsPage],
      PassengerFlowDestinationSearch() => [tabsPage, destinationPage],
      PassengerFlowTaxiChoice(:final destination, :final scheduledPickup) => [
        tabsPage,
        destinationPage,
        MaterialPage<void>(
          key: const ValueKey('taxi-choice'),
          child: TaxiChoicePage(
            origin: homeState.home.position,
            destination: destination,
            loadTaxiChoiceUseCase: loadTaxiChoiceUseCase,
            requestRideUseCase: requestRideUseCase,
            bookRideUseCase: bookRideUseCase,
            getPickupForArrivalUseCase: getPickupForArrivalUseCase,
            scheduledPickup: scheduledPickup,
          ),
        ),
      ],
      PassengerFlowRide(:final rideId) => [
        tabsPage,
        MaterialPage<void>(
          key: ValueKey('ride-$rideId'),
          child: RidePage(
            rideId: rideId,
            origin: homeState.home.position,
            watchRideUseCase: watchRideUseCase,
            cancelRideUseCase: cancelRideUseCase,
            rateRideUseCase: rateRideUseCase,
          ),
        ),
      ],
    };
  }
}

/// Tabs Accueil / Courses / Compte.
class _PassengerTabs extends StatefulWidget {
  const _PassengerTabs({required this.onSignOutRequested});

  final VoidCallback onSignOutRequested;

  @override
  State<_PassengerTabs> createState() => _PassengerTabsState();
}

class _PassengerTabsState extends State<_PassengerTabs> {
  static const _homeTab = ValueKey('home');
  static const _ridesTab = ValueKey('rides');
  static const _accountTab = ValueKey('account');
  static const List<Key> _tabs = [_homeTab, _ridesTab, _accountTab];

  Key _selectedTab = _homeTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      footers: [_buildTabBar()],
      // IndexedStack keeps the map alive when switching tabs.
      child: IndexedStack(
        index: _tabs.indexOf(_selectedTab),
        children: [
          const _HomeTab(),
          const RideHistoryTab(),
          AccountTab(onSignOutRequested: widget.onSignOutRequested),
        ],
      ),
    );
  }

  void _onTabSelected(Key? key) {
    setState(() => _selectedTab = key ?? _homeTab);
    // Rides may have changed since the tab was last shown (booking, ride).
    if (key == _ridesTab) {
      context.read<RideHistoryBloc>().add(const RideHistoryRequested());
    }
  }

  Widget _buildTabBar() {
    return NavigationBar(
      alignment: NavigationBarAlignment.spaceEvenly,
      labelType: NavigationLabelType.all,
      selectedKey: _selectedTab,
      onSelected: _onTabSelected,
      children: const [
        NavigationItem(
          key: _homeTab,
          label: Text('Accueil'),
          child: Icon(Icons.home_outlined),
        ),
        NavigationItem(
          key: _ridesTab,
          label: Text('Courses'),
          child: Icon(Icons.list),
        ),
        NavigationItem(
          key: _accountTab,
          label: Text('Compte'),
          child: Icon(Icons.person_outline),
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerHomeBloc, PassengerHomeState>(
      builder: (context, state) => switch (state) {
        PassengerHomeLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        PassengerHomeFailure(:final message) => RetryMessage(
          message: message,
          onRetry: () => context.read<PassengerHomeBloc>().add(
            const PassengerHomeStarted(),
          ),
        ),
        PassengerHomeReady(:final home) => Stack(
          children: [
            Positioned.fill(
              child: PassengerHomeMap(
                position: home.position,
                nearbyTaxis: home.nearbyTaxis,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: WhereToPanel(
                recentDestinations: home.recentDestinations,
                nearbyTaxiCount: home.nearbyTaxis.length,
                onWhereToPressed: () => context
                    .read<PassengerFlowCubit>()
                    .destinationSearchOpened(),
              ),
            ),
          ],
        ),
      },
    );
  }
}

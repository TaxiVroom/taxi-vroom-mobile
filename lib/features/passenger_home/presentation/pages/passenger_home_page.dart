import 'package:flow_builder/flow_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/authentication/presentation/navigator/auth_navigator.dart'
    show AuthNavigator;
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_current_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_ride_history_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/account_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_home_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/pages/destination_search_page.dart';
import 'package:mobile/features/passenger_home/presentation/pages/ride_page.dart';
import 'package:mobile/features/passenger_home/presentation/pages/taxi_choice_page.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/account_tab.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/passenger_home_map.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/ride_history_tab.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/where_to_panel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Passenger area after login. [PassengerFlowBloc] states map to the page
/// stack: tabs (home) → destination search → taxi choice, then the ride.
class PassengerHomePage extends StatelessWidget {
  const PassengerHomePage({
    required this.loadPassengerHomeUseCase,
    required this.watchNearbyTaxisUseCase,
    required this.watchConnectionUseCase,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.loadTaxiChoiceUseCase,
    required this.getPickupDaysUseCase,
    required this.requestRideUseCase,
    required this.loadCurrentRideUseCase,
    required this.watchPushedRidesUseCase,
    required this.watchRideUseCase,
    required this.cancelRideUseCase,
    required this.rateRideUseCase,
    required this.bookRideUseCase,
    required this.getPickupForArrivalUseCase,
    required this.loadRideHistoryUseCase,
    required this.cancelBookingUseCase,
    required this.loadAccountUseCase,
    required this.onSignOutRequested,
    super.key,
  });

  final LoadPassengerHomeUseCase loadPassengerHomeUseCase;
  final WatchNearbyTaxisUseCase watchNearbyTaxisUseCase;
  final WatchConnectionUseCase watchConnectionUseCase;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final LoadTaxiChoiceUseCase loadTaxiChoiceUseCase;
  final GetPickupDaysUseCase getPickupDaysUseCase;
  final RequestRideUseCase requestRideUseCase;
  final LoadCurrentRideUseCase loadCurrentRideUseCase;
  final WatchPushedRidesUseCase watchPushedRidesUseCase;
  final WatchRideUseCase watchRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final RateRideUseCase rateRideUseCase;
  final BookRideUseCase bookRideUseCase;
  final GetPickupForArrivalUseCase getPickupForArrivalUseCase;
  final LoadRideHistoryUseCase loadRideHistoryUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final LoadAccountUseCase loadAccountUseCase;

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
            watchNearbyTaxisUseCase: watchNearbyTaxisUseCase,
            watchConnectionUseCase: watchConnectionUseCase,
          )..add(const PassengerHomeStarted()),
        ),
        BlocProvider(
          create: (_) => PassengerFlowBloc(
            getPickupDaysUseCase: getPickupDaysUseCase,
            loadCurrentRideUseCase: loadCurrentRideUseCase,
            watchPushedRidesUseCase: watchPushedRidesUseCase,
          ),
        ),
        BlocProvider(
          create: (_) =>
              RideHistoryBloc(
                  loadRideHistoryUseCase: loadRideHistoryUseCase,
                  cancelBookingUseCase: cancelBookingUseCase,
                  watchPushedRidesUseCase: watchPushedRidesUseCase,
                )
                ..add(const RideHistoryRequested())
                ..add(const RideHistoryPushesWatched()),
        ),
        BlocProvider(
          create: (_) => AccountBloc(
            loadAccountUseCase: loadAccountUseCase,
          )..add(const AccountRequested()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // The ride page needs the passenger's position: looking for a ride,
          // or opening the one of a notification, before the home is loaded
          // would leave it out of the pages for good.
          BlocListener<PassengerHomeBloc, PassengerHomeState>(
            listenWhen: (previous, current) =>
                previous is! PassengerHomeReady &&
                current is PassengerHomeReady,
            listener: (context, _) => context.read<PassengerFlowBloc>()
              ..add(const PassengerFlowStarted())
              ..add(const PassengerPushesWatched()),
          ),
          // Its error and "Réessayer" replace the start's loader.
          BlocListener<PassengerHomeBloc, PassengerHomeState>(
            listenWhen: (_, current) => current is PassengerHomeFailure,
            listener: (context, _) => context.read<PassengerFlowBloc>().add(
              const PassengerHomeFailed(),
            ),
          ),
        ],
        child: BlocBuilder<PassengerFlowBloc, PassengerFlowState>(
          builder: (context, flowState) => FlowBuilder<PassengerFlowState>(
            state: flowState,
            onGeneratePages: (state, _) => _onGeneratePages(context, state),
          ),
        ),
      ),
    );
  }

  List<Page<void>> _onGeneratePages(
    BuildContext context,
    PassengerFlowState flowState,
  ) {
    // Until the app knows where to go: nothing to tap that would lead
    // elsewhere than the ride about to open.
    if (flowState is PassengerFlowStarting) {
      return const [
        MaterialPage<void>(
          key: ValueKey('passenger-starting'),
          child: Scaffold(child: Center(child: CircularProgressIndicator())),
        ),
      ];
    }

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
      // The start is handled above; listed for the switch to be complete.
      PassengerFlowStarting() || PassengerFlowHome() => [tabsPage],
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
  static const ValueKey<String> _homeTab = ValueKey('home');
  static const ValueKey<String> _ridesTab = ValueKey('rides');
  static const ValueKey<String> _accountTab = ValueKey('account');
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

  // Height of the "Où allez-vous ?" panel over the map.
  static const _panelHeight = 300.0;

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
        PassengerHomeReady(
          :final home,
          :final nearbyTaxis,
          :final isConnected,
        ) =>
          Stack(
            children: [
              Positioned.fill(
                child: PassengerHomeMap(
                  position: home.position,
                  nearbyTaxis: nearbyTaxis,
                  bottomPadding: _panelHeight,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: WhereToPanel(
                  recentDestinations: home.recentDestinations,
                  nearbyTaxiCount: nearbyTaxis.length,
                  isConnected: isConnected,
                  onWhereToPressed: () => context.read<PassengerFlowBloc>().add(
                    const PassengerDestinationSearchOpened(),
                  ),
                ),
              ),
            ],
          ),
      },
    );
  }
}

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/presentation/bloc/notification_permission_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/widgets/map_pill.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/notifications_blocked.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/arrive_at_pickup_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/complete_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/decline_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/depart_for_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_current_driver_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_account_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_ride_checkout_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_weekly_earnings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/refuse_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_receives_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_passenger_cancellation_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_account_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_bookings_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_flow_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_home_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/earnings_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/ride_request_bloc.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_boarding_page.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_checkout_page.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_documents_page.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_pickup_page.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_ride_page.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driver_account_tab.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driver_bookings_tab.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driver_home_map.dart';
import 'package:mobile/features/driver_home/presentation/widgets/earnings_tab.dart';
import 'package:mobile/features/driver_home/presentation/widgets/offline_panel.dart';
import 'package:mobile/features/driver_home/presentation/widgets/online_panel.dart';
import 'package:mobile/features/driver_home/presentation/widgets/ride_request_sheet.dart';
import 'package:mobile/features/driver_home/presentation/widgets/status_dot.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Driver area once the account is validated. [DriverFlowBloc] states map
/// to the page stack: documents check at login, then the tabs Conduire /
/// Réservations / Gains / Compte.
class DriverHomePage extends StatelessWidget {
  const DriverHomePage({
    required this.loadCurrentDriverRideUseCase,
    required this.loadDriverDocumentsUseCase,
    required this.loadDriverHomeUseCase,
    required this.setOnlineUseCase,
    required this.setReceivesBookingsUseCase,
    required this.shareDriverPositionUseCase,
    required this.watchConnectionUseCase,
    required this.watchRideRequestsUseCase,
    required this.acceptRideRequestUseCase,
    required this.declineRideRequestUseCase,
    required this.watchGuidanceUseCase,
    required this.arriveAtPickupUseCase,
    required this.startRideUseCase,
    required this.reportNoShowUseCase,
    required this.withdrawFromRideUseCase,
    required this.watchPassengerCancellationUseCase,
    required this.loadRideCheckoutUseCase,
    required this.completeRideUseCase,
    required this.loadDriverBookingsUseCase,
    required this.acceptBookingUseCase,
    required this.withdrawFromBookingUseCase,
    required this.refuseBookingUseCase,
    required this.departForBookingUseCase,
    required this.watchPushedRidesUseCase,
    required this.loadWeeklyEarningsUseCase,
    required this.loadDriverAccountUseCase,
    required this.onSignOutRequested,
    super.key,
  });

  final LoadCurrentDriverRideUseCase loadCurrentDriverRideUseCase;
  final LoadDriverDocumentsUseCase loadDriverDocumentsUseCase;
  final LoadDriverHomeUseCase loadDriverHomeUseCase;
  final SetOnlineUseCase setOnlineUseCase;
  final SetReceivesBookingsUseCase setReceivesBookingsUseCase;
  final ShareDriverPositionUseCase shareDriverPositionUseCase;
  final WatchConnectionUseCase watchConnectionUseCase;
  final WatchRideRequestsUseCase watchRideRequestsUseCase;
  final AcceptRideRequestUseCase acceptRideRequestUseCase;
  final DeclineRideRequestUseCase declineRideRequestUseCase;
  final WatchGuidanceUseCase watchGuidanceUseCase;
  final ArriveAtPickupUseCase arriveAtPickupUseCase;
  final StartRideUseCase startRideUseCase;
  final ReportNoShowUseCase reportNoShowUseCase;
  final WithdrawFromRideUseCase withdrawFromRideUseCase;
  final WatchPassengerCancellationUseCase watchPassengerCancellationUseCase;
  final LoadRideCheckoutUseCase loadRideCheckoutUseCase;
  final CompleteRideUseCase completeRideUseCase;
  final LoadDriverBookingsUseCase loadDriverBookingsUseCase;
  final AcceptBookingUseCase acceptBookingUseCase;
  final WithdrawFromBookingUseCase withdrawFromBookingUseCase;
  final RefuseBookingUseCase refuseBookingUseCase;
  final DepartForBookingUseCase departForBookingUseCase;
  final WatchPushedRidesUseCase watchPushedRidesUseCase;
  final LoadWeeklyEarningsUseCase loadWeeklyEarningsUseCase;
  final LoadDriverAccountUseCase loadDriverAccountUseCase;

  /// Lets the parent ([AuthNavigator]) sign the driver out, without this
  /// widget knowing about authentication.
  final VoidCallback onSignOutRequested;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DriverFlowBloc(
            loadCurrentDriverRideUseCase: loadCurrentDriverRideUseCase,
            loadDriverDocumentsUseCase: loadDriverDocumentsUseCase,
            arriveAtPickupUseCase: arriveAtPickupUseCase,
            withdrawFromRideUseCase: withdrawFromRideUseCase,
            watchPassengerCancellationUseCase:
                watchPassengerCancellationUseCase,
          )..add(const DriverFlowStarted()),
        ),
        BlocProvider(
          create: (_) => DriverHomeBloc(
            loadDriverHomeUseCase: loadDriverHomeUseCase,
            setOnlineUseCase: setOnlineUseCase,
            setReceivesBookingsUseCase: setReceivesBookingsUseCase,
            shareDriverPositionUseCase: shareDriverPositionUseCase,
            watchConnectionUseCase: watchConnectionUseCase,
          )..add(const DriverHomeStarted()),
        ),
        BlocProvider(
          create: (_) => DriverAccountBloc(
            loadDriverAccountUseCase: loadDriverAccountUseCase,
          )..add(const DriverAccountRequested()),
        ),
        BlocProvider(
          create: (_) => EarningsBloc(
            loadWeeklyEarningsUseCase: loadWeeklyEarningsUseCase,
          )..add(const EarningsRequested()),
        ),
        BlocProvider(
          create: (_) =>
              DriverBookingsBloc(
                  loadDriverBookingsUseCase: loadDriverBookingsUseCase,
                  acceptBookingUseCase: acceptBookingUseCase,
                  withdrawFromBookingUseCase: withdrawFromBookingUseCase,
                  refuseBookingUseCase: refuseBookingUseCase,
                  departForBookingUseCase: departForBookingUseCase,
                  watchPushedRidesUseCase: watchPushedRidesUseCase,
                )
                ..add(const DriverBookingsRequested())
                ..add(const DriverBookingsPushesWatched()),
        ),
        BlocProvider(
          create: (_) => RideRequestBloc(
            watchRideRequestsUseCase: watchRideRequestsUseCase,
            acceptRideRequestUseCase: acceptRideRequestUseCase,
            declineRideRequestUseCase: declineRideRequestUseCase,
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DriverFlowBloc, DriverFlowState>(
            listenWhen: (previous, _) =>
                previous is DriverFlowCheckingDocuments,
            listener: (context, _) => _goBackOnlineDuringRide(context),
          ),
          BlocListener<DriverHomeBloc, DriverHomeState>(
            listenWhen: (previous, current) =>
                previous is! DriverHomeReady && current is DriverHomeReady,
            listener: (context, _) => _goBackOnlineDuringRide(context),
          ),
        ],
        child: BlocBuilder<DriverFlowBloc, DriverFlowState>(
          builder: (context, flowState) => FlowBuilder<DriverFlowState>(
            state: flowState,
            onGeneratePages: (state, _) => _onGeneratePages(context, state),
          ),
        ),
      ),
    );
  }

  // The app started during a ride: the passenger must see the taxi move. The
  // ride and the home load in any order.
  void _goBackOnlineDuringRide(BuildContext context) {
    final isDuringRide = switch (context.read<DriverFlowBloc>().state) {
      DriverFlowPickup() || DriverFlowBoarding() || DriverFlowInRide() => true,
      _ => false,
    };
    final homeState = context.read<DriverHomeBloc>().state;
    if (isDuringRide &&
        homeState is DriverHomeReady &&
        !homeState.home.activity.isOnline) {
      context.read<DriverHomeBloc>().add(
        const DriverOnlineToggled(isOnline: true),
      );
    }
  }

  List<Page<void>> _onGeneratePages(
    BuildContext context,
    DriverFlowState flowState,
  ) {
    final tabsPage = MaterialPage<void>(
      key: const ValueKey('driver-tabs'),
      child: _DriverTabs(onSignOutRequested: onSignOutRequested),
    );
    return switch (flowState) {
      DriverFlowCheckingDocuments() => [
        const MaterialPage<void>(
          key: ValueKey('driver-documents-check'),
          child: Scaffold(child: Center(child: CircularProgressIndicator())),
        ),
      ],
      DriverFlowDocumentsFailure(:final message) => [
        MaterialPage<void>(
          key: const ValueKey('driver-documents-check'),
          child: Scaffold(
            child: RetryMessage(
              message: message,
              onRetry: () => context.read<DriverFlowBloc>().add(
                const DriverFlowStarted(),
              ),
            ),
          ),
        ),
      ],
      DriverFlowDocuments(:final documents) => [
        MaterialPage<void>(
          key: const ValueKey('driver-documents'),
          child: DriverDocumentsPage(
            documents: documents,
            onPostponed: () => context.read<DriverFlowBloc>().add(
              const DriverDocumentsPostponed(),
            ),
          ),
        ),
      ],
      DriverFlowHome() => [tabsPage],
      DriverFlowDocumentsReview(:final documents) => [
        tabsPage,
        MaterialPage<void>(
          key: const ValueKey('driver-documents-review'),
          child: DriverDocumentsPage(
            documents: documents,
            closeLabel: 'Retour',
            onPostponed: () => context.read<DriverFlowBloc>().add(
              const DriverDocumentsClosed(),
            ),
          ),
        ),
      ],
      // The tabs stay below, so the home keeps its map and its state.
      DriverFlowPickup(
        :final ride,
        :final isSubmitting,
        :final failureMessage,
      ) =>
        [
          tabsPage,
          MaterialPage<void>(
            key: ValueKey('driver-pickup-${ride.id}'),
            child: DriverPickupPage(
              ride: ride,
              watchGuidanceUseCase: watchGuidanceUseCase,
              isSubmitting: isSubmitting,
              failureMessage: failureMessage,
              onArrived: () => context.read<DriverFlowBloc>().add(
                const DriverArrivedAtPickup(),
              ),
              onWithdrawRequested: () => context.read<DriverFlowBloc>().add(
                const DriverWithdrawRequested(),
              ),
            ),
          ),
        ],
      DriverFlowInRide(:final ride) => [tabsPage, _ridePage(context, ride)],
      // The ride stays below, its guidance running, until the amount is
      // validated: "Reprendre la course" finds it as it was.
      DriverFlowCheckout(:final ride) => [
        tabsPage,
        _ridePage(context, ride),
        MaterialPage<void>(
          key: ValueKey('driver-checkout-${ride.id}'),
          child: DriverCheckoutPage(
            ride: ride,
            loadRideCheckoutUseCase: loadRideCheckoutUseCase,
            completeRideUseCase: completeRideUseCase,
            onCompleted: () => context.read<DriverFlowBloc>().add(
              const DriverRideCompleted(),
            ),
            onResumed: () => context.read<DriverFlowBloc>().add(
              const DriverRideResumed(),
            ),
          ),
        ),
      ],
      DriverFlowBoarding(:final ride, :final arrivedAt) => [
        tabsPage,
        MaterialPage<void>(
          key: ValueKey('driver-boarding-${ride.id}'),
          child: DriverBoardingPage(
            ride: ride,
            arrivedAt: arrivedAt,
            startRideUseCase: startRideUseCase,
            reportNoShowUseCase: reportNoShowUseCase,
            withdrawFromRideUseCase: withdrawFromRideUseCase,
            onRideStarted: () => context.read<DriverFlowBloc>().add(
              const DriverRideStarted(),
            ),
            onNoShowReported: () => context.read<DriverFlowBloc>().add(
              const DriverNoShowReported(),
            ),
            onWithdrawn: () => context.read<DriverFlowBloc>().add(
              const DriverRideWithdrawn(),
            ),
          ),
        ),
      ],
    };
  }

  // The same key in both states: the page keeps its guidance when the
  // checkout opens above it, then closes.
  Page<void> _ridePage(BuildContext context, DriverRide ride) {
    return MaterialPage<void>(
      key: ValueKey('driver-ride-${ride.id}'),
      child: DriverRidePage(
        ride: ride,
        watchGuidanceUseCase: watchGuidanceUseCase,
        onFinished: () => context.read<DriverFlowBloc>().add(
          const DriverRideFinished(),
        ),
      ),
    );
  }
}

class _DriverTabs extends StatefulWidget {
  const _DriverTabs({required this.onSignOutRequested});

  final VoidCallback onSignOutRequested;

  @override
  State<_DriverTabs> createState() => _DriverTabsState();
}

class _DriverTabsState extends State<_DriverTabs> {
  static const ValueKey<String> _driveTab = ValueKey('drive');
  static const ValueKey<String> _bookingsTab = ValueKey('bookings');
  static const ValueKey<String> _earningsTab = ValueKey('earnings');
  static const ValueKey<String> _accountTab = ValueKey('account');
  static const List<Key> _tabs = [
    _driveTab,
    _bookingsTab,
    _earningsTab,
    _accountTab,
  ];

  Key _selectedTab = _driveTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      footers: [_buildTabBar()],
      // IndexedStack keeps the map alive when switching tabs.
      child: IndexedStack(
        index: _tabs.indexOf(_selectedTab),
        children: [
          _DriveTab(onProfilePressed: () => _onTabSelected(_accountTab)),
          const DriverBookingsTab(),
          const EarningsTab(),
          DriverAccountTab(
            onDocumentsPressed: (documents) => context
                .read<DriverFlowBloc>()
                .add(DriverDocumentsOpened(documents: documents)),
            onSignOutRequested: widget.onSignOutRequested,
          ),
        ],
      ),
    );
  }

  void _onTabSelected(Key? key) {
    setState(() => _selectedTab = key ?? _driveTab);
    // Bookings may have changed since the tab was last shown.
    if (key == _bookingsTab) {
      context.read<DriverBookingsBloc>().add(const DriverBookingsRequested());
    }
    // A ride may have ended since the tab was last shown.
    if (key == _earningsTab) {
      context.read<EarningsBloc>().add(const EarningsRequested());
    }
  }

  Widget _buildTabBar() {
    return NavigationBar(
      alignment: NavigationBarAlignment.spaceEvenly,
      selectedKey: _selectedTab,
      onSelected: _onTabSelected,
      children: const [
        NavigationItem(
          key: _driveTab,
          label: Text('Conduire'),
          child: Icon(Icons.local_taxi_outlined),
        ),
        NavigationItem(
          key: _bookingsTab,
          label: Text('Réservations'),
          child: Icon(Icons.event_outlined),
        ),
        NavigationItem(
          key: _earningsTab,
          label: Text('Gains'),
          child: Icon(Icons.euro),
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

/// Mockup screens 2 (offline) and 3 (online, waiting for a ride).
class _DriveTab extends StatelessWidget {
  const _DriveTab({required this.onProfilePressed});

  final VoidCallback onProfilePressed;

  // Room kept for the request card when framing its roads on the map.
  static const _requestCardHeight = 470.0;
  static const _panelHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Online: requests come by notification when the app is not on
        // screen.
        BlocListener<DriverHomeBloc, DriverHomeState>(
          listenWhen: (previous, current) =>
              !_isOnline(previous) && _isOnline(current),
          listener: (context, _) => _checkNotifications(
            context,
            NotificationNeed.rideRequests,
          ),
        ),
        // "Accepter": the booking's reminder comes by notification.
        BlocListener<DriverBookingsBloc, DriverBookingsState>(
          listenWhen: _isBookingAccepted,
          listener: (context, _) => _checkNotifications(
            context,
            NotificationNeed.bookingReminder,
          ),
        ),
        // Only the settings can allow them now: the driver is told what they
        // miss, once per check.
        BlocListener<NotificationPermissionBloc, NotificationPermissionState>(
          listenWhen: (previous, current) =>
              current.checks != previous.checks && current.blockedFor != null,
          listener: (context, state) =>
              showNotificationsBlockedToast(context, state.blockedFor!),
        ),
        // Requests only come in while the driver is online.
        BlocListener<DriverHomeBloc, DriverHomeState>(
          listenWhen: (previous, current) =>
              _isOnline(previous) != _isOnline(current),
          listener: _onOnlineChanged,
        ),
        BlocListener<RideRequestBloc, RideRequestState>(
          listenWhen: (previous, current) =>
              previous is! RideRequestOffered && current is RideRequestOffered,
          listener: (context, _) => openRideRequestSheet(context),
        ),
        // The request on screen was taken away: the sheet closes by itself,
        // the driver is told why.
        BlocListener<RideRequestBloc, RideRequestState>(
          listenWhen: (previous, current) =>
              previous is RideRequestOffered &&
              current is RideRequestWaiting &&
              current.notice != null,
          listener: (context, state) => showMessageToast(
            context,
            title: 'Demande annulée',
            message: (state as RideRequestWaiting).notice!,
          ),
        ),
        // Accepted: the driver goes to the passenger (mockup screen 5).
        BlocListener<RideRequestBloc, RideRequestState>(
          listenWhen: (_, current) => current is RideRequestTaken,
          listener: (context, state) => context.read<DriverFlowBloc>().add(
            DriverRideAccepted(ride: (state as RideRequestTaken).ride),
          ),
        ),
        // "Je pars" on a booking: the same pickup screen as an accepted
        // request.
        BlocListener<DriverBookingsBloc, DriverBookingsState>(
          listenWhen: (_, current) => current is DriverBookingsDeparted,
          listener: (context, state) => context.read<DriverFlowBloc>().add(
            DriverRideAccepted(ride: (state as DriverBookingsDeparted).ride),
          ),
        ),
        // Back from a ride: new requests can come in again.
        BlocListener<DriverFlowBloc, DriverFlowState>(
          listenWhen: (previous, current) =>
              _isOnRide(previous) && current is DriverFlowHome,
          listener: (context, state) {
            final notice = (state as DriverFlowHome).notice;
            if (notice != null) {
              showMessageToast(
                context,
                title: 'Course annulée',
                message: notice,
              );
            }
            _onOnlineChanged(context, context.read<DriverHomeBloc>().state);
          },
        ),
      ],
      child: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) => switch (state) {
          DriverHomeLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DriverHomeFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () =>
                context.read<DriverHomeBloc>().add(const DriverHomeStarted()),
          ),
          DriverHomeReady() => _buildReady(context, state),
        },
      ),
    );
  }

  // The request waiting for an answer, drawn on the map.
  RoutedRideRequest? _offer(RideRequestState state) => switch (state) {
    RideRequestOffered(:final offer) => offer,
    _ => null,
  };

  bool _isOnRide(DriverFlowState state) =>
      state is DriverFlowPickup ||
      state is DriverFlowBoarding ||
      state is DriverFlowInRide ||
      state is DriverFlowCheckout;

  bool _isOnline(DriverHomeState state) =>
      state is DriverHomeReady && state.home.activity.isOnline;

  // The answer sent was "Accepter", and the booking is now an accepted one.
  bool _isBookingAccepted(
    DriverBookingsState previous,
    DriverBookingsState current,
  ) {
    if (previous is! DriverBookingsReady || current is! DriverBookingsReady) {
      return false;
    }
    final bookingId = previous.answeringId;
    if (bookingId == null || previous.isRefusing) return false;
    final wasAvailable = previous.bookings.available.any(
      (booking) => booking.id == bookingId,
    );
    final isAccepted = current.bookings.accepted.any(
      (booking) => booking.id == bookingId,
    );
    return wasAvailable && isAccepted;
  }

  void _checkNotifications(BuildContext context, NotificationNeed need) =>
      context.read<NotificationPermissionBloc>().add(
        NotificationPermissionChecked(need: need),
      );

  void _onOnlineChanged(BuildContext context, DriverHomeState state) {
    final rideRequests = context.read<RideRequestBloc>();
    if (state is DriverHomeReady && state.home.activity.isOnline) {
      rideRequests.add(
        RideRequestsWatched(driverPosition: state.home.position),
      );
    } else {
      rideRequests.add(const RideRequestsUnwatched());
    }
  }

  Widget _buildReady(BuildContext context, DriverHomeReady state) {
    final home = state.home;
    return Stack(
      children: [
        Positioned.fill(
          child: BlocBuilder<RideRequestBloc, RideRequestState>(
            // Not on every second of the countdown: only when the request
            // itself comes or goes.
            buildWhen: (previous, current) =>
                _offer(previous) != _offer(current),
            builder: (context, requestState) => DriverHomeMap(
              position: home.position,
              isOnline: home.activity.isOnline,
              demandZones: home.demand.zones,
              bottomPadding: _requestCardHeight,
              panelHeight: _panelHeight,
              offer: _offer(requestState),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: SafeArea(child: _buildTopBar(home)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: home.activity.isOnline
              ? _buildOnlinePanel(context, state)
              : _buildOfflinePanel(context, state),
        ),
      ],
    );
  }

  Widget _buildTopBar(DriverHome home) {
    final earnings = MapPill(
      text: 'Aujourd’hui ${formatEuro(home.activity.todayEarningsCents)}',
    );
    if (home.activity.isOnline) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.freeTaxi,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const StatusDot(
              label: 'En ligne',
              color: Colors.white,
              textColor: Colors.white,
            ),
          ),
          earnings,
        ],
      );
    }
    // The notifications are not built yet.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SecondaryButton(
          density: ButtonDensity.icon,
          shape: ButtonShape.circle,
          onPressed: onProfilePressed,
          child: const Icon(Icons.person_outline),
        ),
        earnings,
        SecondaryButton(
          density: ButtonDensity.icon,
          shape: ButtonShape.circle,
          onPressed: () {},
          child: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildOfflinePanel(BuildContext context, DriverHomeReady state) {
    return OfflinePanel(
      activity: state.home.activity,
      nextBooking: state.home.nextBooking,
      isSwitching: state.isSwitchingOnline,
      failureMessage: state.switchFailureMessage,
      onGoOnlinePressed: () => context.read<DriverHomeBloc>().add(
        const DriverOnlineToggled(isOnline: true),
      ),
    );
  }

  Widget _buildOnlinePanel(BuildContext context, DriverHomeReady state) {
    return OnlinePanel(
      demand: state.home.demand,
      receivesBookings: state.home.activity.receivesBookings,
      isConnected: state.isConnected,
      isSwitching: state.isSwitchingOnline,
      failureMessage: state.switchFailureMessage,
      onGoOfflinePressed: () => context.read<DriverHomeBloc>().add(
        const DriverOnlineToggled(isOnline: false),
      ),
      onReceivesBookingsChanged: (receivesBookings) => context
          .read<DriverHomeBloc>()
          .add(DriverBookingsToggled(receivesBookings: receivesBookings)),
    );
  }
}

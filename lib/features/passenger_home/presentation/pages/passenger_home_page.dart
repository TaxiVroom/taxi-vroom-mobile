import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_home_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/passenger_home_map.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/where_to_panel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Passenger home after login: tabs Accueil / Courses / Compte.
class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({required this.loadPassengerHomeUseCase, super.key});

  final LoadPassengerHomeUseCase loadPassengerHomeUseCase;

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  static const _homeTab = ValueKey('home');
  static const _ridesTab = ValueKey('rides');
  static const _accountTab = ValueKey('account');
  static const List<Key> _tabs = [_homeTab, _ridesTab, _accountTab];

  Key _selectedTab = _homeTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PassengerHomeBloc(
        loadPassengerHomeUseCase: widget.loadPassengerHomeUseCase,
      )..add(const PassengerHomeStarted()),
      child: Scaffold(
        backgroundColor: Colors.white,
        footers: [_buildTabBar()],
        // IndexedStack keeps the map alive when switching tabs.
        child: IndexedStack(
          index: _tabs.indexOf(_selectedTab),
          children: const [
            _HomeTab(),
            _ComingSoonTab(title: 'Mes courses'),
            _ComingSoonTab(title: 'Compte'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return NavigationBar(
      alignment: NavigationBarAlignment.spaceEvenly,
      labelType: NavigationLabelType.all,
      selectedKey: _selectedTab,
      onSelected: (key) => setState(() => _selectedTab = key ?? _homeTab),
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
        PassengerHomeLoading() => const Center(child: CircularProgressIndicator()),
        PassengerHomeFailure(:final message) => _buildFailure(context, message),
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
                ),
              ),
            ],
          ),
      },
    );
  }

  Widget _buildFailure(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => context
                  .read<PassengerHomeBloc>()
                  .add(const PassengerHomeStarted()),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

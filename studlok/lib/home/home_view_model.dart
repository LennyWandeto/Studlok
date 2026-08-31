import 'package:flutter/material.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';

/// Wraps the dashboard's two data sources (native shared state + local
/// session history) as one observable ViewModel, so [HomeScreen] is a pure
/// View — no bridge calls, no loading-state juggling in build().
class HomeViewModel extends ChangeNotifier with WidgetsBindingObserver {
  HomeViewModel({StudlokNativeBridge? bridge, SessionHistoryStore? historyStore})
      : _bridge = bridge ?? StudlokNativeBridge(),
        _historyStore = historyStore ?? SessionHistoryStore() {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  final StudlokNativeBridge _bridge;
  final SessionHistoryStore _historyStore;

  StudlokSharedState? state;
  List<SessionHistoryEntry> history = const [];

  bool get isLoading => state == null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    final newState = await _bridge.getSharedState();
    final newHistory = await _historyStore.load();
    state = newState;
    history = newHistory;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

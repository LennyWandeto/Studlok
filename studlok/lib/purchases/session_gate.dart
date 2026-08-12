import '../history/session_history_store.dart';
import 'purchases_config.dart';

/// Whether the user is allowed to start another Deep Work/Quiz session
/// right now, and how many they've already earned today (for messaging).
class SessionGateResult {
  const SessionGateResult({required this.allowed, required this.sessionsToday});

  final bool allowed;
  final int sessionsToday;
}

/// Free tier: capped at [PurchasesConfig.freeDailySessionCap] earned
/// sessions per day. Premium entitlement removes the cap entirely.
class SessionGate {
  SessionGate({SessionHistoryStore? historyStore}) : _historyStore = historyStore ?? SessionHistoryStore();

  final SessionHistoryStore _historyStore;

  Future<SessionGateResult> check() async {
    final isPremium = await PurchasesConfig.isPremium();
    if (isPremium) {
      return const SessionGateResult(allowed: true, sessionsToday: 0);
    }
    final sessionsToday = await _historyStore.countToday();
    return SessionGateResult(
      allowed: sessionsToday < PurchasesConfig.freeDailySessionCap,
      sessionsToday: sessionsToday,
    );
  }
}

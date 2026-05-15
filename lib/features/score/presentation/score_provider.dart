import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/score/data/local_score_repository.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final localScoreRepositoryProvider = FutureProvider<LocalScoreRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalScoreRepository(prefs);
});

final bestScoreProvider = FutureProvider.family<int, String>((
  ref,
  gameId,
) async {
  final repository = await ref.watch(localScoreRepositoryProvider.future);
  return repository.getBestScore(gameId);
});

final leaderboardRecordsProvider =
    FutureProvider.family<List<ScoreRecord>, String>((ref, gameId) async {
      final repository = await ref.watch(localScoreRepositoryProvider.future);
      return repository.getRecords(gameId: gameId, limit: 10);
    });

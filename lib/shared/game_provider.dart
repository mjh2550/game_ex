import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/shared/game_info.dart';
import 'package:game_ex/shared/game_manager.dart';
import 'package:game_ex/shared/game_state.dart';

final gameManagerProvider = Provider((ref) => GameManager());

final selectedGameProvider = Provider<GameInfo?>((ref) => null);

final gameListProvider = Provider<List<GameInfo>>((ref) {
  final gameManager = ref.watch(gameManagerProvider);
  return gameManager.games;
});
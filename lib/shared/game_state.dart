import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_ex/shared/game_info.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
abstract class GameState with _$GameState {
  const factory GameState({required final List<GameInfo> gameList}) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
}

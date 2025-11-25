import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

part 'game_state_provider.g.dart';

/// 게임 진행 상태 모델
class GameState {
  final int score;
  final double playTime;
  final int combo;
  final int nearMissCount;
  final int difficultyLevel;
  final bool isPaused;
  final bool isGameOver;

  const GameState({
    required this.score,
    required this.playTime,
    required this.combo,
    required this.nearMissCount,
    required this.difficultyLevel,
    required this.isPaused,
    required this.isGameOver,
  });

  const GameState.initial()
      : score = 0,
        playTime = 0.0,
        combo = 0,
        nearMissCount = 0,
        difficultyLevel = 1,
        isPaused = false,
        isGameOver = false;

  GameState copyWith({
    int? score,
    double? playTime,
    int? combo,
    int? nearMissCount,
    int? difficultyLevel,
    bool? isPaused,
    bool? isGameOver,
  }) {
    return GameState(
      score: score ?? this.score,
      playTime: playTime ?? this.playTime,
      combo: combo ?? this.combo,
      nearMissCount: nearMissCount ?? this.nearMissCount,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

/// 게임 상태 관리 Provider
@riverpod
class GameStateNotifier extends _$GameStateNotifier {
  FlameGame? _game;

  @override
  GameState build() {
    return const GameState.initial();
  }

  /// 게임 인스턴스 설정
  void setGame(FlameGame game) {
    _game = game;
  }

  /// 게임 상태 업데이트 (매 프레임마다 호출)
  void updateFromGame() {
    if (_game == null) return;

    if (_game is! DdongDodgeGame) return;

    final game = _game as DdongDodgeGame;

    state = GameState(
      score: game.scoreSystem.score,
      playTime: game.scoreSystem.survivalTime,
      combo: game.scoreSystem.combo,
      nearMissCount: game.scoreSystem.nearMissCount,
      difficultyLevel: game.difficultySystem.getDifficultyLevel(),
      isPaused: game.paused,
      isGameOver: game.isGameOver,
    );
  }

  /// 게임 상태 직접 업데이트
  void updateState(GameState newState) {
    state = newState;
  }

  /// 점수 업데이트
  void updateScore(int newScore) {
    state = state.copyWith(score: newScore);
  }

  /// 플레이 타임 업데이트
  void updatePlayTime(double newTime) {
    state = state.copyWith(playTime: newTime);
  }

  /// 콤보 업데이트
  void updateCombo(int newCombo) {
    state = state.copyWith(combo: newCombo);
  }

  /// 일시정지 토글
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// 게임 오버 설정
  void setGameOver(bool isOver) {
    state = state.copyWith(isGameOver: isOver);
  }

  /// 게임 리셋
  void reset() {
    state = const GameState.initial();
  }
}

// /// 현재 점수만 가져오는 Provider
// @riverpod
// int currentScore(Ref ref) {
//   return ref.watch(gameStateProvider.select((state) => state.score));
// }

// /// 현재 플레이 타임만 가져오는 Provider
// @riverpod
// double currentPlayTime(Ref ref) {
//   return ref.watch(gameStateProvider.select((state) => state.playTime));
// }

// /// 현재 콤보만 가져오는 Provider
// @riverpod
// int currentCombo(Ref ref) {
//   return ref.watch(gameStateProvider.select((state) => state.combo));
// }

// /// 게임 일시정지 상태만 가져오는 Provider
// @riverpod
// bool isGamePaused(Ref ref) {
//   return ref.watch(gameStateProvider.select((state) => state.isPaused));
// }

// /// 게임 오버 상태만 가져오는 Provider
// @riverpod
// bool isGameOver(Ref ref) {
//   return ref.watch(gameStateProvider.select((state) => state.isGameOver));
// }

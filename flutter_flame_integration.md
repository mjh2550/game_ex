# Flutter(Riverpod) ↔ Flame Game 통합 가이드

## 🔄 기본 개념

Flutter 앱과 Flame 게임은 **완전히 독립적**으로 동작하면서도 **자유롭게 전환**할 수 있습니다.

```
Flutter App (Riverpod)
    ↓
  GameWidget (브릿지)
    ↓
  FlameGame
    ↓
  (게임 종료 후)
    ↓
Flutter App으로 복귀
```

---

## 📱 구현 방법

### 방법 1: Navigation으로 게임 화면 이동 (권장)

가장 일반적이고 깔끔한 방법입니다.

#### 1.1 라우터 설정 (go_router)[O]

#### 1.2 홈 화면에서 게임 선택[O]

#### 1.3 게임 화면 (Flutter + Flame 통합)[O]

#### 1.4 Flame 게임에서 콜백 사용[O]

---

### 방법 2: Riverpod으로 게임 상태 관리

더 세밀한 제어가 필요한 경우 Riverpod으로 게임 상태를 관리할 수 있습니다.

#### 2.1 게임 상태 프로바이더

```dart
// lib/features/games/shared/providers/game_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state_provider.freezed.dart';

// 게임 상태
@freezed
class GameState with _$GameState {
  const factory GameState({
    @Default(GameStatus.notStarted) GameStatus status,
    @Default(0) int score,
    @Default(0.0) double playTime,
    Map<String, dynamic>? result,
  }) = _GameState;
}

enum GameStatus {
  notStarted,
  playing,
  paused,
  gameOver,
}

// 게임 상태 노티파이어
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void startGame() {
    state = state.copyWith(status: GameStatus.playing);
  }

  void pauseGame() {
    state = state.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    state = state.copyWith(status: GameStatus.playing);
  }

  void updateScore(int score, double playTime) {
    state = state.copyWith(
      score: score,
      playTime: playTime,
    );
  }

  void endGame(Map<String, dynamic> result) {
    state = state.copyWith(
      status: GameStatus.gameOver,
      result: result,
    );
  }

  void resetGame() {
    state = const GameState();
  }
}

// 프로바이더
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// 현재 게임 인스턴스 프로바이더
final currentGameProvider = StateProvider<FlameGame?>((ref) => null);
```

#### 2.2 게임과 Riverpod 연결

```dart
// lib/features/games/ddong_dodge/presentation/game/ddong_dodge_game.dart
class DdongDodgeGame extends FlameGame with HasCollisionDetection {
  final StateNotifierProvider<GameStateNotifier, GameState> gameStateProvider;
  final Ref ref;

  DdongDodgeGame({
    required this.gameStateProvider,
    required this.ref,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 게임 시작 알림
    ref.read(gameStateProvider.notifier).startGame();
    
    // 초기화...
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!paused && !isGameOver) {
      scoreSystem.update(dt);
      
      // 📊 Riverpod 상태 업데이트
      ref.read(gameStateProvider.notifier).updateScore(
        scoreSystem.score,
        scoreSystem.survivalTime,
      );
    }
  }

  void triggerGameOver() {
    isGameOver = true;
    pauseEngine();

    // 📊 Riverpod로 게임 종료 알림
    ref.read(gameStateProvider.notifier).endGame({
      'score': scoreSystem.score,
      'playTime': scoreSystem.survivalTime,
      'stats': {...},
    });
  }
}
```

#### 2.3 게임 화면에서 상태 감지

---

## 🔄 데이터 흐름 예시

### 시나리오: 홈 → 게임 → 결과 → 홈

```dart
1. 홈 화면 (Flutter + Riverpod)
   ↓
   사용자가 게임 카드 탭
   ↓
   context.push('/game/ddong_dodge')
   ↓

2. 게임 화면 (Flutter + Flame)
   ↓
   GameWidget(game: DdongDodgeGame(...))
   ↓
   게임 플레이 중...
   ↓
   player.takeDamage() → game.triggerGameOver()
   ↓
   onGameOver 콜백 호출
   ↓

3. 결과 화면 (Flutter + Riverpod)
   ↓
   점수 저장 (Firestore)
   ↓
   리더보드 업데이트
   ↓
   사용자가 "홈으로" 버튼 탭
   ↓
   context.go('/home')
   ↓

4. 홈 화면 (Flutter + Riverpod)
   ↓
   업데이트된 베스트 스코어 표시
```

---

## 🎯 실전 예제: 완전한 통합

---

## 💡 핵심 포인트

### ✅ 가능한 것들

1. **자유로운 화면 전환**
   - `go_router`로 Flutter 화면 ↔ Flame 게임 이동
   - 뒤로가기 버튼 지원
   - Deep linking 가능

2. **양방향 통신**
   - Flame → Flutter: 콜백 함수 (onGameOver, onPause 등)
   - Flutter → Flame: 메서드 호출 (game.pauseGame(), game.resetGame() 등)
   - Riverpod: 양쪽에서 공통 상태 공유

3. **데이터 공유**
   - Riverpod Provider로 전역 상태 관리
   - 게임 결과를 Firestore에 저장
   - 실시간 점수 동기화

4. **리소스 관리**
   - 게임 화면 나갈 때 자동으로 dispose
   - 메모리 최적화
   - 백그라운드 처리

### ⚠️ 주의사항

1. **게임 인스턴스 생명주기**
   ```dart
   // GameScreen의 dispose에서 정리 필수
   @override
   void dispose() {
     game.onRemove();
     super.dispose();
   }
   ```

2. **상태 동기화**
   ```dart
   // Flame 내부 상태와 Riverpod 상태를 혼용하지 말 것
   // 게임 로직: Flame 내부
   // UI 상태: Riverpod
   ```

3. **성능 고려**
   ```dart
   // 게임 중에는 불필요한 Riverpod watch 피하기
   // 게임 오버 등 특정 이벤트만 listen
   ```

---

## 🎮 요약

**Flutter(Riverpod) ↔ Flame 통합은 완전히 가능하며, 다음과 같이 구현합니다:**

1. **go_router로 화면 라우팅** (홈 ↔ 게임 ↔ 결과)
2. **콜백 함수로 통신** (게임 → Flutter)
3. **게임 인스턴스 참조로 제어** (Flutter → 게임)
4. **Riverpod로 전역 상태 관리** (선택사항)
5. **GameWidget으로 Flame 렌더링**

이 방식으로 여러 게임을 자유롭게 추가하고, 깔끔하게 관리할 수 있습니다! 🚀

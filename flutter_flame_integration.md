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

#### 1.1 라우터 설정 (go_router)

```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // 홈 화면 (Flutter UI)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // 게임 화면 (Flame Game)
      GoRoute(
        path: '/game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GameScreen(gameId: gameId);
        },
      ),
      
      // 게임 오버 후 결과 화면 (Flutter UI)
      GoRoute(
        path: '/game-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GameResultScreen(
            gameId: extra['gameId'],
            score: extra['score'],
            stats: extra['stats'],
          );
        },
      ),
      
      // 리더보드
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      
      // 프로필
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
```

#### 1.2 홈 화면에서 게임 선택

```dart
// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final games = ref.watch(availableGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 사용자 정보 카드
          _UserInfoCard(user: user),
          
          // 게임 목록
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return _GameCard(
                  game: game,
                  onTap: () {
                    // 🎮 게임 화면으로 이동!
                    context.push('/game/${game.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: game.isUnlocked ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 게임 썸네일
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    game.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  if (!game.isUnlocked)
                    Container(
                      color: Colors.black54,
                      child: const Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            
            // 게임 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (game.bestScore != null)
                      Text(
                        'Best: ${game.bestScore}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 1.3 게임 화면 (Flutter + Flame 통합)

```dart
// lib/features/games/shared/presentation/screens/game_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FlameGame game;

  @override
  void initState() {
    super.initState();
    
    // 🎮 게임 인스턴스 생성
    game = _createGame(widget.gameId);
  }

  FlameGame _createGame(String gameId) {
    // 게임 팩토리 패턴
    switch (gameId) {
      case 'bullet_dodge':
        return BulletDodgeGame(
          onGameOver: _handleGameOver,
          onPause: _handlePause,
          userId: ref.read(currentUserProvider).id,
        );
      
      case 'game_2':
        return Game2(
          onGameOver: _handleGameOver,
          onPause: _handlePause,
          userId: ref.read(currentUserProvider).id,
        );
      
      default:
        throw Exception('Unknown game: $gameId');
    }
  }

  // 🏁 게임 오버 처리
  void _handleGameOver(GameResult result) {
    // 점수 저장
    ref.read(scoreRepositoryProvider).saveScore(
      gameId: widget.gameId,
      score: result.score,
      metadata: result.metadata,
    );

    // 결과 화면으로 이동
    context.go('/game-result', extra: {
      'gameId': widget.gameId,
      'score': result.score,
      'stats': result.stats,
    });
  }

  // ⏸️ 일시정지 처리
  void _handlePause() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseDialog(
        onResume: () {
          Navigator.of(context).pop();
          game.resumeEngine();
        },
        onQuit: () {
          Navigator.of(context).pop();
          context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎮 GameWidget으로 Flame 게임 렌더링
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          // HUD (점수, 시간 등)
          'hud': (context, game) {
            return GameHUD(game: game as dynamic);
          },
          
          // 일시정지 메뉴
          'pause': (context, game) {
            return PauseMenu(
              onResume: () {
                game.overlays.remove('pause');
                game.resumeEngine();
              },
              onQuit: () {
                context.go('/home');
              },
            );
          },
          
          // 게임 오버 화면
          'game_over': (context, game) {
            return GameOverOverlay(
              game: game as dynamic,
              onRetry: () {
                game.overlays.remove('game_over');
                (game as dynamic).resetGame();
              },
              onHome: () {
                context.go('/home');
              },
            );
          },
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }

  @override
  void dispose() {
    // 게임 리소스 정리
    game.onRemove();
    super.dispose();
  }
}
```

#### 1.4 Flame 게임에서 콜백 사용

```dart
// lib/features/games/bullet_dodge/presentation/game/bullet_dodge_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';

class GameResult {
  final int score;
  final double playTime;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> metadata;

  GameResult({
    required this.score,
    required this.playTime,
    required this.stats,
    required this.metadata,
  });
}

class BulletDodgeGame extends FlameGame with HasCollisionDetection {
  final Function(GameResult) onGameOver;
  final VoidCallback onPause;
  final String userId;

  BulletDodgeGame({
    required this.onGameOver,
    required this.onPause,
    required this.userId,
  });

  late Player player;
  late ScoreSystem scoreSystem;
  late DifficultySystem difficultySystem;
  
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 게임 초기화
    scoreSystem = ScoreSystem();
    difficultySystem = DifficultySystem();

    // 컴포넌트 추가
    world.add(Background());
    
    player = Player();
    world.add(player);
    
    world.add(BulletSpawner(difficultySystem));

    // HUD 오버레이 표시
    overlays.add('hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!paused && !isGameOver) {
      scoreSystem.update(dt);
      difficultySystem.update(dt);
    }
  }

  // 🏁 게임 오버 처리
  void triggerGameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    pauseEngine();

    // 결과 데이터 생성
    final result = GameResult(
      score: scoreSystem.score,
      playTime: scoreSystem.survivalTime,
      stats: {
        'near_miss_count': scoreSystem.nearMissCount,
        'max_combo': scoreSystem.maxCombo,
        'difficulty_reached': difficultySystem.getDifficultyLevel(),
      },
      metadata: {
        'bullets_spawned': difficultySystem.totalBulletsSpawned,
        'game_version': '1.0.0',
      },
    );

    // 🔄 Flutter 앱으로 콜백
    onGameOver(result);
  }

  // ⏸️ 일시정지
  void pauseGame() {
    pauseEngine();
    onPause();
  }

  // 🔄 게임 리셋
  void resetGame() {
    isGameOver = false;
    scoreSystem.reset();
    difficultySystem.reset();
    
    // 모든 총알 제거
    world.children.whereType<Bullet>().forEach((bullet) {
      bullet.removeFromParent();
    });
    
    // 플레이어 위치 초기화
    player.reset();
    
    resumeEngine();
  }
}
```

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
// lib/features/games/bullet_dodge/presentation/game/bullet_dodge_game.dart
class BulletDodgeGame extends FlameGame with HasCollisionDetection {
  final StateNotifierProvider<GameStateNotifier, GameState> gameStateProvider;
  final Ref ref;

  BulletDodgeGame({
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

```dart
// lib/features/games/shared/presentation/screens/game_screen.dart
class GameScreen extends ConsumerStatefulWidget {
  final String gameId;
  const GameScreen({required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FlameGame game;

  @override
  void initState() {
    super.initState();
    game = BulletDodgeGame(
      gameStateProvider: gameStateProvider,
      ref: ref,
    );
    
    // 현재 게임 인스턴스 저장
    ref.read(currentGameProvider.notifier).state = game;
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 게임 상태 감지
    ref.listen<GameState>(gameStateProvider, (previous, next) {
      if (next.status == GameStatus.gameOver) {
        // 게임 오버 처리
        _handleGameOver(next.result!);
      }
    });

    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 게임 화면
          GameWidget(game: game),
          
          // 실시간 점수 표시 (Riverpod 상태 사용)
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Score: ${gameState.score}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // 상태에 따른 오버레이
          if (gameState.status == GameStatus.paused)
            _buildPauseOverlay(),
        ],
      ),
    );
  }

  void _handleGameOver(Map<String, dynamic> result) {
    // 점수 저장
    ref.read(scoreRepositoryProvider).saveScore(
      gameId: widget.gameId,
      score: result['score'],
      metadata: result,
    );

    // 결과 화면으로 이동
    Future.delayed(Duration(milliseconds: 500), () {
      context.go('/game-result', extra: result);
    });
  }
}
```

---

## 🔄 데이터 흐름 예시

### 시나리오: 홈 → 게임 → 결과 → 홈

```dart
1. 홈 화면 (Flutter + Riverpod)
   ↓
   사용자가 게임 카드 탭
   ↓
   context.push('/game/bullet_dodge')
   ↓

2. 게임 화면 (Flutter + Flame)
   ↓
   GameWidget(game: BulletDodgeGame(...))
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

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Game Hub',
      theme: ThemeData.dark(),
      routerConfig: router,
    );
  }
}
```

```dart
// lib/features/home/presentation/widgets/game_card.dart
class GameCard extends ConsumerWidget {
  final GameInfo game;

  const GameCard({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // 🎮 게임으로 이동
        if (game.isUnlocked) {
          // 게임 상태 초기화
          ref.read(gameStateProvider.notifier).resetGame();
          
          // 게임 화면으로 이동
          context.push('/game/${game.id}');
        } else {
          // 잠금 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unlock by reaching Level ${game.requiredLevel}')),
          );
        }
      },
      child: Card(
        // UI 코드...
      ),
    );
  }
}
```

```dart
// lib/features/games/bullet_dodge/presentation/game/components/player.dart
class Player extends SpriteComponent with HasGameRef, CollisionCallbacks {
  
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Bullet) {
      takeDamage();
    }
  }

  void takeDamage() {
    // 🏁 게임 오버!
    (gameRef as BulletDodgeGame).triggerGameOver();
  }
}
```

```dart
// lib/features/games/shared/presentation/screens/game_result_screen.dart
class GameResultScreen extends ConsumerWidget {
  final String gameId;
  final int score;
  final Map<String, dynamic> stats;

  const GameResultScreen({
    required this.gameId,
    required this.score,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 순위 정보 가져오기
    final rank = ref.watch(userRankProvider(gameId));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Over', style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            Text('Score: $score', style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Text('Your Rank: #${rank.rank}'),
            SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.replay),
                  label: Text('Play Again'),
                  onPressed: () {
                    // 🔄 같은 게임 다시 플레이
                    context.go('/game/$gameId');
                  },
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  onPressed: () {
                    // 🏠 홈으로 돌아가기
                    context.go('/home');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

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

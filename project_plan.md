# 종합 게임 앱 프로젝트 계획서

## 🎯 프로젝트 개요

**목표**: 하나의 계정으로 여러 미니게임을 즐기고 기록을 경쟁하는 종합 게임 플랫폼

**첫 번째 게임**: 똥 피하기 게임 (Ddong Dodge)

---

## 📋 전체 프로젝트 단계

### Phase 0: 프로젝트 초기 설계 (1-2일)
```
목표: 아키텍처 설계 및 기술 스택 결정
```

#### 0.1 아키텍처 설계
- [ ] 앱 전체 구조 설계
- [ ] 데이터베이스 스키마 설계
- [ ] 게임 추가 확장성 고려
- [ ] 상태 관리 방식 결정

#### 0.2 기술 스택 선정
```dart
Frontend:
  ✓ Flutter (UI 프레임워크)
  ✓ Flame (게임 엔진)
  ✓ Riverpod (상태 관리)
  ✓ go_router (라우팅)

Backend/Database: => 서버는 싱글플레이 선행 작업 후 도입
  - Firebase (추천) 
    • Authentication (계정 관리)
    • Firestore (데이터 저장)
    • Cloud Functions (서버 로직)
  
  또는
  
  - Supabase (오픈소스 대안)
    • PostgreSQL 기반
    • 실시간 기능
    • Row Level Security

Local Storage:
  - shared_preferences (설정)
  - hive/isar (로컬 캐시)
```

---

## 🏗️ 아키텍처 설계

### 전체 앱 구조
```
┌────────────────────────────────────────────────────┐
│              Game Hub App                          │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │         Authentication Layer                │  │
│  │  • Login/Signup                              │  │
│  │  • User Profile                              │  │
│  │  • Session Management                        │  │
│  └──────────────────────────────────────────────┘  │
│                      ▼                             │
│  ┌──────────────────────────────────────────────┐  │
│  │         Navigation Layer                     │  │
│  │  • Home Screen (게임 목록)                     │  │
│  │  • Leaderboard (전체 순위)                     │  │
│  │  • Profile (내 기록)                          │  │
│  │  • Settings                                  │  │
│  └──────────────────────────────────────────────┘  │
│                      ▼                             │
│  ┌──────────────────────────────────────────────┐  │
│  │         Game Manager Layer                   │  │
│  │  • Game Registry (게임 등록소)                  │  │
│  │  • Score Manager (점수 관리)                   │  │
│  │  • Achievement System (업적)                  │  │
│  └──────────────────────────────────────────────┘  │
│                      ▼                              │
│  ┌──────────────────────────────────────────────┐  │
│  │         Individual Games                     │  │
│  │  ┌─────────────────┐  ┌─────────────────┐   │  │
│  │  │ Ddong Dodge    │  │  Game 2 (예정)  │   │  │
│  │  │ (FlameGame)     │  │  (FlameGame)    │   │  │
│  │  └─────────────────┘  └─────────────────┘   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐   │  │
│  │  │  Game 3 (예정)  │  │  Game 4 (예정)  │   │  │
│  │  └─────────────────┘  └─────────────────┘   │  │
│  └──────────────────────────────────────────────┘  │
│                      ▼                               │
│  ┌──────────────────────────────────────────────┐  │
│  │         Data Layer                           │  │
│  │  • Remote DB (Firebase/Supabase)            │  │
│  │  • Local Cache (Hive/Isar)                  │  │
│  │  • Repository Pattern                        │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 폴더 구조 (Clean Architecture)
```
lib/
├── core/
│   ├── constants/           # 상수, 설정값
│   ├── theme/              # 앱 테마, 스타일
│   ├── utils/              # 유틸리티 함수
│   ├── errors/             # 에러 처리
│   └── network/            # API 클라이언트
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── data_sources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── home/               # 게임 목록 화면
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── leaderboard/        # 순위표
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/            # 프로필
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── games/              # 개별 게임들
│       ├── shared/         # 게임 공통 요소
│       │   ├── base_game.dart
│       │   ├── game_score_manager.dart
│       │   └── game_ui_overlay.dart
│       │
│       ├── ddong_dodge/   # 똥 피하기 게임
│       │   ├── data/
│       │   │   ├── models/
│       │   │   └── repositories/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   └── usecases/
│       │   └── presentation/
│       │       ├── game/
│       │       │   ├── ddong_dodge_game.dart
│       │       │   ├── components/
│       │       │   │   ├── player.dart
│       │       │   │   ├── ddong.dart
│       │       │   │   ├── ddong_spawner.dart
│       │       │   │   └── world.dart
│       │       │   └── systems/
│       │       │       ├── collision_system.dart
│       │       │       ├── difficulty_system.dart
│       │       │       └── score_system.dart
│       │       ├── screens/
│       │       │   ├── game_screen.dart
│       │       │   └── game_over_screen.dart
│       │       └── widgets/
│       │           ├── game_hud.dart
│       │           └── pause_menu.dart
│       │
│       └── game_2/         # 두 번째 게임 (미래)
│           └── ...
│
├── shared/
│   ├── widgets/            # 공통 위젯
│   ├── models/             # 공통 모델
│   └── providers/          # 공통 프로바이더
│
└── main.dart
```

---

## 🗄️ 데이터베이스 스키마

### Users (사용자)
```typescript
{
  id: string,              // UUID
  email: string,           // 이메일
  username: string,        // 닉네임
  avatar_url?: string,     // 프로필 이미지
  created_at: timestamp,
  updated_at: timestamp,
  total_score: number,     // 전체 게임 총점
  level: number,           // 사용자 레벨
  exp: number             // 경험치
}
```

### Games (게임 정보)
```typescript
{
  id: string,              // 게임 ID
  name: string,            // 게임 이름
  description: string,     // 설명
  thumbnail_url: string,   // 썸네일
  is_active: boolean,      // 활성화 여부
  min_version: string,     // 최소 앱 버전
  created_at: timestamp
}
```

### Scores (게임 기록)
```typescript
{
  id: string,
  user_id: string,         // FK: Users
  game_id: string,         // FK: Games
  score: number,           // 점수
  rank: number,            // 순위
  play_time: number,       // 플레이 시간 (초)
  metadata: json,          // 게임별 추가 정보
  created_at: timestamp
}
```

### Leaderboards (순위표)
```typescript
{
  game_id: string,
  user_id: string,
  username: string,
  best_score: number,      // 최고 점수
  total_plays: number,     // 플레이 횟수
  average_score: number,   // 평균 점수
  last_played: timestamp,
  rank: number             // 전체 순위
}
```

### Achievements (업적)
```typescript
{
  id: string,
  user_id: string,
  game_id: string,
  achievement_type: string, // 업적 종류
  unlocked_at: timestamp,
  metadata: json
}
```

---

## 📅 구현 단계별 상세 계획

### Phase 1: 프로젝트 기반 구축 (3-4일)

#### 1.1 프로젝트 셋업
```bash
# 의존성 추가
flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add shared_preferences
flutter pub add freezed_annotation json_annotation
flutter pub add google_fonts

# Dev 의존성
flutter pub add --dev build_runner freezed json_serializable
```

#### 1.2 폴더 구조 생성
- [v] Clean Architecture 폴더 구조 생성
- [ ] 각 feature별 기본 파일 생성
- [ ] 공통 모듈 셋업

#### 1.3 Firebase/Supabase 설정
- [ ] 프로젝트 생성
- [ ] 인증 설정
- [ ] 데이터베이스 스키마 생성
- [ ] 보안 규칙 설정

#### 1.4 기본 테마 및 상수 설정
```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF00D9FF),
      secondary: Color(0xFFFF006E),
    ),
  );
}

// lib/core/constants/game_constants.dart
class GameConstants {
  static const double gameWidth = 360;
  static const double gameHeight = 640;
  static const int targetFPS = 60;
}
```

---

### Phase 2: 인증 시스템 구현 (2-3일)

#### 2.1 Auth Feature 구현
- [ ] 로그인 화면 UI
- [ ] 회원가입 화면 UI
- [ ] Firebase Auth 연동
- [ ] 이메일/비밀번호 인증
- [ ] Google 소셜 로그인 (선택)
- [ ] 세션 관리
- [ ] 에러 처리

#### 2.2 사용자 프로필 초기 설정
- [ ] 닉네임 설정
- [ ] 프로필 이미지 (기본값)
- [ ] Firestore에 사용자 정보 저장

```dart
// lib/features/auth/domain/entities/user.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? avatarUrl,
    @Default(0) int totalScore,
    @Default(1) int level,
    @Default(0) int exp,
  }) = _User;
}
```

---

### Phase 3: 네비게이션 및 홈 화면 (2-3일)

#### 3.1 라우팅 설정 (go_router)
```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'game/:gameId',
          builder: (context, state) {
            final gameId = state.pathParameters['gameId']!;
            return GameScreen(gameId: gameId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => LeaderboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
  ],
);
```

#### 3.2 홈 화면 구현
- [ ] 게임 목록 그리드/리스트
- [ ] 각 게임 카드 UI
- [ ] 잠금/해금 상태 표시
- [ ] 베스트 스코어 표시
- [ ] 하단 네비게이션 바

```dart
홈 화면 구성:
┌─────────────────────────┐
│  Game Hub  🏆  👤       │  ← 상단 바
├─────────────────────────┤
│  Your Best: 15,230 pts  │  ← 사용자 정보
│  Level 5  ▓▓▓░░░ 67%   │
├─────────────────────────┤
│  ┌─────┐  ┌─────┐      │
│  │Game1│  │Game2│      │  ← 게임 목록
│  │ 🎯  │  │ 🔒  │      │
│  │1,234│  │ Soon│      │
│  └─────┘  └─────┘      │
│  ┌─────┐  ┌─────┐      │
│  │Game3│  │Game4│      │
│  │ 🔒  │  │ 🔒  │      │
│  └─────┘  └─────┘      │
├─────────────────────────┤
│  🏠  📊  👤  ⚙️        │  ← 하단 네비게이션
└─────────────────────────┘
```

---

### Phase 4: 게임 공통 시스템 (2-3일)

#### 4.1 BaseGame 추상 클래스
```dart
// lib/features/games/shared/base_game.dart
abstract class BaseGameHub extends FlameGame {
  final String gameId;
  final GameScoreManager scoreManager;
  
  BaseGameHub({
    required this.gameId,
    required this.scoreManager,
  });
  
  // 공통 메서드
  void pauseGame();
  void resumeGame();
  void gameOver(int finalScore);
  void saveScore();
  
  // 추상 메서드 (각 게임이 구현)
  void setupGame();
  void resetGame();
}
```

#### 4.2 점수 관리 시스템
```dart
// lib/features/games/shared/game_score_manager.dart
class GameScoreManager {
  int currentScore = 0;
  int highScore = 0;
  int combo = 0;
  
  void addScore(int points) {
    currentScore += points * (1 + combo * 0.1);
  }
  
  void increaseCombo() {
    combo++;
  }
  
  void resetCombo() {
    combo = 0;
  }
  
  Future<void> saveToFirestore() async {
    // Firestore 저장 로직
  }
}
```

#### 4.3 공통 UI 오버레이
- [ ] 일시정지 메뉴
- [ ] 게임 오버 화면
- [ ] HUD (점수, 시간, 콤보)
- [ ] 카운트다운

---

### Phase 5: 똥 피하기 게임 구현 (5-7일)

#### 5.1 게임 기획 상세
```
게임명: Ddong Dodge (똥 피하기)

목표: 
  - 위에서 떨어지는 똥을 피해 최대한 오래 살아남기
  - 시간이 지날수록 똥 속도와 개수 증가

조작:
  - 좌우 드래그/터치로 플레이어 이동
  - 화면 경계를 넘어갈 수 없음

점수 시스템:
  - 생존 시간: 1초당 10점
  - 근접 회피: 똥과 아슬아슬하게 피하면 보너스 (+50점)
  - 콤보: 연속 근접 회피시 점수 배율 증가

난이도:
  - 0-30초: 똥 2-3개, 느린 속도
  - 30-60초: 똥 4-5개, 중간 속도
  - 60-90초: 똥 6-8개, 빠른 속도
  - 90초+: 똥 10개+, 매우 빠른 속도

게임 종료:
  - 똥에 맞으면 즉시 게임 오버
  - 최종 점수 표시 및 순위 확인
```

#### 5.2 게임 컴포넌트 구현

##### Player Component
```dart
// lib/features/games/ddong_dodge/presentation/game/components/player.dart
class Player extends SpriteComponent 
    with HasGameRef, CollisionCallbacks, DragCallbacks {
  
  static const double speed = 300.0;
  static const double size = 40.0;
  
  Vector2 velocity = Vector2.zero();
  bool isInvulnerable = false;
  
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
    size = Vector2.all(size);
    anchor = Anchor.center;
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
    
    add(CircleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // 위치 업데이트
    position += velocity * dt;
    
    // 경계 체크
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    velocity.x = event.delta.x / event.dt;
  }
  
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Ddong && !isInvulnerable) {
      gameRef.gameOver();
    }
  }
  
  void takeDamage() {
    if (!isInvulnerable) {
      // 게임 오버 처리
      gameRef.gameOver();
    }
  }
}
```

##### Ddong Component

##### Ddong Spawner System

#### 5.3 게임 시스템 구현

##### Difficulty System

##### Score System

##### Collision System

#### 5.4 Main Game Class

#### 5.5 UI 오버레이

##### Game HUD

##### Game Over Screen

---

### Phase 6: 리더보드 및 프로필 (2-3일)

#### 6.1 리더보드 화면


#### 6.2 프로필 화면

---

### Phase 7: 테스트 및 최적화 (2-3일)

#### 7.1 테스트
- [ ] 단위 테스트 (Business Logic)
- [ ] 위젯 테스트 (UI Components)
- [ ] 통합 테스트 (전체 플로우)
- [ ] 게임 밸런스 테스트
- [ ] 성능 테스트 (FPS, 메모리)

#### 7.2 최적화
- [ ] 게임 성능 최적화
- [ ] 네트워크 요청 최적화
- [ ] 이미지/에셋 최적화
- [ ] 빌드 사이즈 최적화

#### 7.3 버그 수정 및 폴리싱
- [ ] 버그 수정
- [ ] 애니메이션 추가
- [ ] 사운드 효과 (선택)
- [ ] 햅틱 피드백

---

### Phase 8: 배포 준비 (1-2일)

#### 8.1 스토어 준비
- [ ] 앱 아이콘 디자인
- [ ] 스크린샷 준비
- [ ] 스토어 설명 작성
- [ ] 개인정보 처리방침

#### 8.2 릴리즈 빌드
- [ ] Android 빌드
- [ ] iOS 빌드 (선택)
- [ ] 베타 테스트 (Firebase App Distribution)

---

## 🎨 에셋 및 리소스 준비

### 필요한 에셋
```
assets/
├── images/
│   ├── backgrounds/
│   │   └── game_bg.png
│   ├── player/
│   │   ├── player.png
│   │   └── player_hit.png
│   ├── ddongs/
│   │   ├── ddong_red.png
│   │   ├── ddong_blue.png
│   │   └── ddong_explosion.png
│   ├── ui/
│   │   ├── button_play.png
│   │   ├── button_pause.png
│   │   └── icons/
│   └── effects/
│       ├── particle.png
│       └── shield.png
│
├── audio/ (선택사항)
│   ├── music/
│   │   └── game_bgm.mp3
│   └── sfx/
│       ├── ddong_fire.mp3
│       ├── explosion.mp3
│       └── near_miss.mp3
│
└── fonts/
    └── game_font.ttf
```

### 에셋 제작 도구
- **이미지**: Figma, Adobe Illustrator, Aseprite
- **무료 에셋**: itch.io, OpenGameArt.org
- **사운드**: Freesound.org, Bfxr (효과음 생성기)

---

## 📊 개발 일정 요약

| Phase | 내용 | 예상 기간 | 우선순위 |
|-------|------|-----------|----------|
| 0 | 프로젝트 설계 | 1-2일 | 필수 |
| 1 | 프로젝트 셋업 | 3-4일 | 필수 |
| 2 | 인증 시스템 | 2-3일 | 필수 |
| 3 | 네비게이션/홈 | 2-3일 | 필수 |
| 4 | 게임 공통 시스템 | 2-3일 | 필수 |
| 5 | 똥 피하기 게임 | 5-7일 | 필수 |
| 6 | 리더보드/프로필 | 2-3일 | 높음 |
| 7 | 테스트/최적화 | 2-3일 | 높음 |
| 8 | 배포 준비 | 1-2일 | 중간 |
| **총계** | | **20-30일** | |

---

## 🚀 MVP (Minimum Viable Product) 범위

### 첫 버전에 포함할 기능
✅ **필수 기능**
- [ ] 이메일 로그인/회원가입
- [ ] 똥 피하기 게임 1개
- [ ] 점수 저장
- [ ] 간단한 리더보드 (전체 순위)
- [ ] 기본 프로필 화면

### 이후 버전에 추가할 기능
🔜 **Phase 2 기능**
- [ ] 소셜 로그인 (Google, Apple)
- [ ] 친구 시스템
- [ ] 업적 시스템
- [ ] 일일 챌린지
- [ ] 게임 2, 3 추가

🔮 **향후 기능**
- [ ] 아이템 시스템 (스킨, 파워업)
- [ ] 시즌/이벤트
- [ ] PvP 대전
- [ ] 리플레이 시스템
- [ ] 공유 기능 (스크린샷, 점수 공유)

---

## 💡 개발 팁 및 주의사항

### 1. 확장성 고려
```dart
// 나쁜 예
if (gameId == 'ddong_dodge') {
  // 게임별 로직 하드코딩
}

// 좋은 예
abstract class BaseGame {
  void initialize();
  void play();
}

class GameRegistry {
  Map<String, BaseGame Function()> games = {
    'ddong_dodge': () => DdongDodgeGame(),
    'game_2': () => Game2(),
  };
}
```

### 2. 성능 최적화
- Flame의 `onGameResize` 주의 (불필요한 재생성 방지)
- 오브젝트 풀링 사용 (똥 재사용)
- `removeFromParent()` 확실히 호출

### 3. 상태 관리
- 게임 상태는 Flame 내부에서 관리
- UI 상태는 Riverpod/Bloc으로 관리
- 명확한 경계 유지

### 4. 데이터 동기화
- 낙관적 업데이트 (Optimistic Update)
- 로컬 캐시 활용
- 오프라인 모드 고려

### 5. 보안
- 점수 검증 (서버 사이드)
- 치트 방지 (난독화, 서버 검증)
- API 키 보안 (환경변수)

---

## 📚 참고 자료

### 공식 문서
- [Flame 공식 문서](https://docs.flame-engine.org/)
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Firebase 문서](https://firebase.google.com/docs)

### 튜토리얼
- Flame 게임 예제: https://github.com/flame-engine/flame/tree/main/examples
- Flutter 게임 튜토리얼: https://docs.flutter.dev/cookbook/games

### 커뮤니티
- Flame Discord: https://discord.gg/pxrBmy4
- Flutter 한국 커뮤니티: https://flutter-ko.dev

---

## 🎯 다음 단계

1. **이 계획서 검토 및 조정**
   - 일정 조정
   - 우선순위 재설정
   - 기술 스택 최종 확정

2. **개발 환경 셋업**
   - Flutter/Flame 설치 확인
   - IDE 플러그인 설치
   - Firebase 프로젝트 생성

3. **폴더 구조 생성**
   ```bash
   mkdir -p lib/{core,features,shared}
   mkdir -p lib/core/{constants,theme,utils,network}
   mkdir -p lib/features/{auth,home,leaderboard,profile,games}
   ```

4. **첫 번째 기능 개발 시작**
   - Phase 1: 프로젝트 셋업부터 시작

**이제 시작할 준비가 되었습니다! 🚀**

어느 단계부터 시작하시겠습니까?

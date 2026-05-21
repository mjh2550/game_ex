# Mini Game Heaven

Flutter와 Flame으로 만드는 미니게임 허브 앱입니다. 현재 첫 번째 플레이 가능 게임은 `Ddong Dodge`이며, 위에서 떨어지는 장애물을 피하면서 생존 시간과 근접 회피 보너스로 점수를 얻는 방식입니다.

## Tech Stack

- Flutter
- Flame
- Riverpod
- go_router
- shared_preferences

## Run

```bash
flutter pub get
flutter run
```

정적 분석:

```bash
flutter analyze
```

## Current Structure

```text
lib/
├── core/                  # 라우터, 테마, 상수, 공통 유틸
├── features/
│   ├── games/
│   │   └── ddong_dodge/   # 똥피하기 게임 구현
│   ├── home/
│   └── profile/
├── shared/                # 게임 화면, 결과 화면, 게임 등록/생성 공통 코드
└── main.dart
```

## Ddong Dodge

- 좌우 버튼, 드래그, 키보드 A/D 또는 방향키로 이동
- 장애물에 닿으면 게임 오버
- 생존 시간으로 기본 점수 획득
- 가까스로 피하면 근접 회피 보너스와 콤보 획득
- 시간이 지날수록 스폰 개수와 속도 증가

## Assets

게임 스프라이트는 OpenMoji PNG를 사용합니다. 자세한 출처와 라이선스는 [assets/images/ATTRIBUTION.md](assets/images/ATTRIBUTION.md)를 확인하세요.

## Planning Docs

- [project_plan.md](project_plan.md): 전체 프로젝트 계획과 현재 보완 계획
- [flame_architecture.md](flame_architecture.md): Flame 구조 정리
- [flutter_flame_integration.md](flutter_flame_integration.md): Flutter/Riverpod/Flame 통합 가이드


## 웹 도커 빌드
```
flutter build web --release
docker build -t mini-game-hub-web:local .
docker run --rm -p 8081:8081 -v mini-game-hub-scores:/data mini-game-hub-web:local
```
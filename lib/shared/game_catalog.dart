import 'package:game_ex/shared/game_info.dart';

class GameIds {
  const GameIds._();

  static const ddongDodge = 'g001';
  static const kioskPanic = 'g002';
  static const rocketDelivery = 'g003';
  static const groupQuiz = 'g004';
}

class GameCatalog {
  const GameCatalog._();

  static final List<GameInfo> games = [
    GameInfo(
      id: GameIds.ddongDodge,
      name: '똥 피하기',
      description: '방향키로 좌우 이동하며 떨어지는 장애물을 피하세요.',
      routeName: '/ddong_dodge',
      isUnlocked: false,
      thumbnailUrl: 'assets/images/openmoji_poop.png',
    ),
    GameInfo(
      id: GameIds.kioskPanic,
      name: '키오스크 눈치게임',
      description: '뒤 손님의 압박 속에서 주문을 빠르게 완성하세요.',
      routeName: '/kiosk_panic',
      isUnlocked: true,
    ),
    GameInfo(
      id: GameIds.rocketDelivery,
      name: '쿠팡 로켓배송',
      description: '컨베이어의 택배를 목적지 구역으로 빠르게 분류하세요.',
      routeName: '/rocket_delivery',
      isUnlocked: true,
    ),
    GameInfo(
      id: GameIds.groupQuiz,
      name: '눈치 퀴즈 대작전',
      description: '한 화면을 같이 보며 제한 시간 안에 정답을 입력하세요.',
      routeName: '/group_quiz',
      isUnlocked: true,
    ),
  ];

  static GameInfo? findById(String gameId) {
    for (final game in games) {
      if (game.id == gameId) {
        return game;
      }
    }
    return null;
  }

  static bool isUnlocked(String gameId) {
    return findById(gameId)?.isUnlocked ?? false;
  }
}

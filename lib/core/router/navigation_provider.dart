// import 'package:go_router/go_router.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/core/router/navigation_state.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/leader_board.dart';
import 'package:game_ex/features/home/presentation/home_screen.dart';
import 'package:game_ex/features/profile/presentation/profile_screen.dart';
import 'package:game_ex/shared/game_result_screen.dart';
import 'package:game_ex/shared/game_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/', // 메인 경로로 변경
    routes: [
      // 메인 화면 = 게임 (Flame Game)
      GoRoute(
        path: '/',
        builder: (context, state) => const GameScreen(gameId: 'g001'),
      ),

      // 홈 화면 (Flutter UI)
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

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
          return GameResultScreen(gameId: extra['gameId'], score: extra['score'], stats: extra['stats']);
        },
      ),

      // 리더보드
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => LeaderboardScreen(),
      ),

      // 프로필
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(),
      ),
    ],
  );
});

/// NavigationNotifier를 관리하는 NotifierProvider 정의
final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState?>(NavigationNotifier.new);

/// 라우트 히스토리를 관리하는 Notifier 클래스
class NavigationNotifier extends Notifier<NavigationState?> {
  @override
  NavigationState? build() {
    // 초기 상태 설정
    return null;
  }

  /// 라우트 상태를 업데이트하는 메서드
  void updateRoute(NavigationState? route) {
    state = route;
  }

  /// 라우트 상태를 초기화하는 메서드
  void clear() {
    state = null;
  }

  /// 리다이렉트 로직
  // FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {

  //   final nonAuthorizedPage = [Location.signIn, Location.bio, Location.pattern, Location.pin];

  //   final fullPath = state.fullPath;

  //   if (fullPath == null) return state.fullPath;

  //   final location = Location.parse(fullPath);

  //   if (location.resentMenu) {
  //     ref.read(homeRecentMenusWidgetProvider.notifier).addMenu(MenuItemExtension.fromLocation(location));
  //   }

  //   if (state.extra is NavigationExtra && (state.extra as NavigationExtra).isForcedRoute) {
  //     await ref.read(sessionProvider.notifier).logout();
  //   }

  //   if (ref.read(sessionProvider)) {
  //     if (nonAuthorizedPage.contains(location)) return Location.home.fullPath;
  //     return state.fullPath;
  //   } else {
  //     if (nonAuthorizedPage.contains(location)) return state.fullPath;
  //     return Location.signIn.fullPath;
  //   }
  // }

  Map<String, dynamic>? getNavigationMap(GoRouterState state) {
    if (state.extra is Map<String, dynamic>) {
      return state.extra as Map<String, dynamic>;
    }
    return null;
  }

  // Widget navigateWithMap({
  //   required BuildContext context,
  //   required GoRouterState state,
  //   required Map<String, dynamic>? Function(GoRouterState) extractData,
  //   required Widget Function(Map<String, dynamic> data) onSuccess,
  //   Widget Function()? onError,
  // }) {
  //   final data = extractData(state);

  //   final logger = GetIt.instance<Logger>();

  //   if (data == null) {
  //     if (kDebugMode) return onSuccess({'debug': true});

  //     while (context.canPop()) {
  //       context.popLocation();
  //     }
  //     logger.warning('잘못된 라우팅 데이터 입니다.');
  //     return onError?.call() ?? const HomePage();
  //   }

  //   return onSuccess(data);
  // }
}

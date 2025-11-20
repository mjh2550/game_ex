import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_ex/core/router/router_action.dart';
import 'package:go_router/go_router.dart';

part 'navigation_state.freezed.dart';
part 'navigation_state.g.dart';

/// NavigationState 정의
@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    final RouteAction? routeAction,
    final String? lastCurrentRoute,
    final String? lastDestinationRoute,
    final Object? lastExtra,
  }) = _NavigationState;

  factory NavigationState.fromJson(Map<String, dynamic> json) => _$NavigationStateFromJson(json);
}


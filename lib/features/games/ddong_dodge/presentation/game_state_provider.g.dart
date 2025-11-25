// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 게임 상태 관리 Provider

@ProviderFor(GameStateNotifier)
const gameStateProvider = GameStateNotifierProvider._();

/// 게임 상태 관리 Provider
final class GameStateNotifierProvider
    extends $NotifierProvider<GameStateNotifier, GameState> {
  /// 게임 상태 관리 Provider
  const GameStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameStateNotifierHash();

  @$internal
  @override
  GameStateNotifier create() => GameStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameState>(value),
    );
  }
}

String _$gameStateNotifierHash() => r'8a9a3ec30a01f138e7f01761fce3993fa270787d';

/// 게임 상태 관리 Provider

abstract class _$GameStateNotifier extends $Notifier<GameState> {
  GameState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GameState, GameState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GameState, GameState>,
              GameState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

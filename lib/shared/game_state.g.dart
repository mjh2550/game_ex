// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameState _$GameStateFromJson(Map<String, dynamic> json) => _GameState(
  gameList: (json['gameList'] as List<dynamic>)
      .map((e) => GameInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{'gameList': instance.gameList};

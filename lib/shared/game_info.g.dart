// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameInfo _$GameInfoFromJson(Map<String, dynamic> json) => GameInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  routeName: json['routeName'] as String,
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GameInfoToJson(GameInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'routeName': instance.routeName,
  'isUnlocked': instance.isUnlocked,
  'thumbnailUrl': instance.thumbnailUrl,
  'bestScore': instance.bestScore,
};

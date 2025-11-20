import 'package:json_annotation/json_annotation.dart';

part 'game_info.g.dart';

@JsonSerializable()
class GameInfo {
  final String id;
  final String name;
  final String description;
  final String routeName;
  final bool isUnlocked;
  final String? thumbnailUrl;
  final int bestScore;

  GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.routeName,
    this.isUnlocked = false,
    this.thumbnailUrl,
    this.bestScore = 0,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) => _$GameInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GameInfoToJson(this);

  factory GameInfo.empty() {
    return GameInfo(
      id: '',
      name: 'Unknown Game',
      description: 'No description available.',
      routeName: '',
      isUnlocked: false,
      thumbnailUrl: null,
      bestScore: 0,
    );
  }

}
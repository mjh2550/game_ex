// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NavigationState _$NavigationStateFromJson(Map<String, dynamic> json) =>
    _NavigationState(
      routeAction: $enumDecodeNullable(
        _$RouteActionEnumMap,
        json['routeAction'],
      ),
      lastCurrentRoute: json['lastCurrentRoute'] as String?,
      lastDestinationRoute: json['lastDestinationRoute'] as String?,
      lastExtra: json['lastExtra'],
    );

Map<String, dynamic> _$NavigationStateToJson(_NavigationState instance) =>
    <String, dynamic>{
      'routeAction': _$RouteActionEnumMap[instance.routeAction],
      'lastCurrentRoute': instance.lastCurrentRoute,
      'lastDestinationRoute': instance.lastDestinationRoute,
      'lastExtra': instance.lastExtra,
    };

const _$RouteActionEnumMap = {
  RouteAction.push: 'push',
  RouteAction.pushReplacement: 'pushReplacement',
  RouteAction.pop: 'pop',
  RouteAction.go: 'go',
};

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalScoreRepository {
  static const _recordsKey = 'score_records_v1';
  static const _lastPlayerNameKey = 'last_player_name_v1';
  static const _maxStoredRecords = 100;

  final SharedPreferences _prefs;
  final http.Client _client;

  LocalScoreRepository(this._prefs, {http.Client? client})
    : _client = client ?? http.Client();

  Future<List<ScoreRecord>> getRecords({String? gameId, int? limit}) async {
    if (_useRemoteScores) {
      final remoteRecords = await _getRemoteRecords(
        gameId: gameId,
        limit: limit,
      );
      if (remoteRecords != null) {
        return remoteRecords;
      }
    }

    final records =
        _loadRecords()
            .where((record) => gameId == null || record.gameId == gameId)
            .toList()
          ..sort(_sortForLeaderboard);

    if (limit == null || records.length <= limit) {
      return records;
    }

    return records.take(limit).toList();
  }

  Future<int> getBestScore(String gameId) async {
    final records = await getRecords(gameId: gameId);
    if (records.isEmpty) {
      return 0;
    }

    return records.first.score;
  }

  String getLastPlayerName() {
    final name = _prefs.getString(_lastPlayerNameKey)?.trim();
    if (name == null || name.isEmpty) {
      return '';
    }

    return name;
  }

  Future<void> saveLastPlayerName(String playerName) async {
    final normalized = playerName.trim();
    if (normalized.isEmpty || normalized == '익명') {
      return;
    }

    await _prefs.setString(_lastPlayerNameKey, normalized);
  }

  Future<ScoreSaveResult> saveRecord(ScoreRecord record) async {
    await saveLastPlayerName(record.playerName);

    if (_useRemoteScores) {
      final remoteResult = await _saveRemoteRecord(record);
      if (remoteResult != null) {
        return remoteResult;
      }
    }

    final records = _loadRecords();
    final previousBest = records
        .where((item) => item.gameId == record.gameId)
        .fold<int>(0, (best, item) => item.score > best ? item.score : best);

    records.add(record);
    records.sort(_sortForLeaderboard);
    final gameRecords =
        records.where((item) => item.gameId == record.gameId).toList()
          ..sort(_sortForLeaderboard);
    final rank = gameRecords.indexWhere((item) => item.id == record.id) + 1;

    final cappedRecords = records.take(_maxStoredRecords).toList();
    await _prefs.setString(
      _recordsKey,
      jsonEncode(cappedRecords.map((record) => record.toJson()).toList()),
    );

    return ScoreSaveResult(
      record: record,
      bestScore: record.score > previousBest ? record.score : previousBest,
      isNewBest: record.score > previousBest,
      rank: rank,
    );
  }

  Future<void> clearRecords({String? gameId}) async {
    if (_useRemoteScores) {
      final cleared = await _clearRemoteRecords(gameId: gameId);
      if (cleared) {
        return;
      }
    }

    if (gameId == null) {
      await _prefs.remove(_recordsKey);
      return;
    }

    final records = _loadRecords()
        .where((record) => record.gameId != gameId)
        .toList();
    await _prefs.setString(
      _recordsKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }

  List<ScoreRecord> _loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ScoreRecord.fromJson)
        .toList();
  }

  int _sortForLeaderboard(ScoreRecord a, ScoreRecord b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    return a.playedAt.compareTo(b.playedAt);
  }

  bool get _useRemoteScores => kIsWeb;

  Uri _scoresApiUri({String? gameId, int? limit}) {
    final params = <String, String>{};
    if (gameId != null && gameId.isNotEmpty) {
      params['gameId'] = gameId;
    }
    if (limit != null) {
      params['limit'] = '$limit';
    }

    return Uri.base.replace(
      path: '/api/scores',
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Future<List<ScoreRecord>?> _getRemoteRecords({
    String? gameId,
    int? limit,
  }) async {
    try {
      final response = await _client.get(
        _scoresApiUri(gameId: gameId, limit: limit),
      );
      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      final rawRecords = decoded is Map<String, dynamic>
          ? decoded['records']
          : decoded;
      if (rawRecords is! List) {
        return null;
      }

      return rawRecords
          .whereType<Map>()
          .map((item) => ScoreRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<ScoreSaveResult?> _saveRemoteRecord(ScoreRecord record) async {
    try {
      final response = await _client.post(
        _scoresApiUri(),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(record.toJson()),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return ScoreSaveResult(
        record: ScoreRecord.fromJson(
          Map<String, dynamic>.from(decoded['record'] as Map),
        ),
        bestScore: decoded['bestScore'] as int? ?? record.score,
        isNewBest: decoded['isNewBest'] as bool? ?? false,
        rank: decoded['rank'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _clearRemoteRecords({String? gameId}) async {
    try {
      final response = await _client.delete(_scoresApiUri(gameId: gameId));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}

import 'dart:convert';

import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalScoreRepository {
  static const _recordsKey = 'score_records_v1';
  static const _lastPlayerNameKey = 'last_player_name_v1';
  static const _maxStoredRecords = 100;

  final SharedPreferences _prefs;

  const LocalScoreRepository(this._prefs);

  List<ScoreRecord> getRecords({String? gameId, int? limit}) {
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

  int getBestScore(String gameId) {
    final records = getRecords(gameId: gameId);
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
}

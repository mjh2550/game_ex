import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/game_info.dart';
import 'package:game_ex/shared/game_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key, this.initialGameId = 'g001'});

  final String initialGameId;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late String _selectedGameId;

  @override
  void initState() {
    super.initState();
    _selectedGameId = widget.initialGameId;
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(gameListProvider);
    if (!games.any((game) => game.id == _selectedGameId) && games.isNotEmpty) {
      _selectedGameId = games.first.id;
    }

    final selectedGame = games.firstWhere(
      (game) => game.id == _selectedGameId,
      orElse: GameInfo.empty,
    );
    final records = ref.watch(leaderboardRecordsProvider(_selectedGameId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF18212F),
        title: const Text('순위표', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: '기록 초기화',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmClearRecords(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GameSelector(
                games: games,
                selectedGameId: _selectedGameId,
                onSelected: (gameId) {
                  setState(() {
                    _selectedGameId = gameId;
                  });
                },
              ),
              const SizedBox(height: 14),
              _LeaderboardHeader(game: selectedGame),
              const SizedBox(height: 18),
              Expanded(
                child: records.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const _EmptyLeaderboard();
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _ScoreRow(rank: index + 1, record: items[index]);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('기록을 불러오지 못했습니다: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearRecords(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기록 초기화'),
          content: const Text('현재 기기에 저장된 이 게임 기록을 모두 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final repository = await ref.read(localScoreRepositoryProvider.future);
    await repository.clearRecords(gameId: _selectedGameId);
    ref.invalidate(leaderboardRecordsProvider(_selectedGameId));
    ref.invalidate(bestScoreProvider(_selectedGameId));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로컬 기록을 삭제했습니다.')));
    }
  }
}

class _GameSelector extends StatelessWidget {
  const _GameSelector({
    required this.games,
    required this.selectedGameId,
    required this.onSelected,
  });

  final List<GameInfo> games;
  final String selectedGameId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final game in games)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: game.id == selectedGameId,
                label: Text(game.name),
                avatar: Icon(
                  game.id == 'g002'
                      ? Icons.touch_app_rounded
                      : Icons.keyboard_arrow_left_rounded,
                  size: 18,
                ),
                onSelected: (_) => onSelected(game.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({required this.game});

  final GameInfo game;

  @override
  Widget build(BuildContext context) {
    final isKiosk = game.id == 'g002';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F18212F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            if (isKiosk)
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFFFFD166),
                size: 58,
              )
            else
              Image.asset(
                game.thumbnailUrl ?? 'assets/images/openmoji_poop.png',
                width: 58,
                height: 58,
                filterQuality: FilterQuality.none,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.name} Top 10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '현재 기기에 저장된 로컬 기록입니다.',
                    style: TextStyle(
                      color: Color(0xFFD4DEE8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.rank, required this.record});

  final int rank;
  final ScoreRecord record;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => const Color(0xFFFFD166),
      2 => const Color(0xFFCAD4E1),
      3 => const Color(0xFFE8A15A),
      _ => const Color(0xFFEAF7FF),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: medalColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.score}점',
                    style: const TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.playerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.playTime.toStringAsFixed(1)}초 · 기록 ${record.nearMissCount} · 콤보 x${record.maxCombo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatDate(record.playedAt),
              style: const TextStyle(
                color: Color(0xFF8A98A8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.month}/${local.day}';
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E7EF)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Color(0xFF60707F),
                size: 44,
              ),
              SizedBox(height: 12),
              Text(
                '아직 기록이 없습니다.',
                style: TextStyle(
                  color: Color(0xFF18212F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '한 판 플레이하면 여기에 점수가 저장됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF60707F),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/shared/game_card.dart';
import 'package:game_ex/shared/game_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(currentUserProvider);
    final games = ref.watch(gameListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 사용자 정보 카드
          // UserInfoCard(user: user),
          
          // 게임 목록
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(
                  game: game,
                  onTap: () {
                    // 🎮 게임 화면으로 이동!
                    context.push('/game/${game.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


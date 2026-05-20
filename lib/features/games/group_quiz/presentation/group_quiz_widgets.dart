import 'package:flutter/material.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_config.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_session.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_team.dart';

class GroupQuizSetupView extends StatelessWidget {
  const GroupQuizSetupView({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.onStart,
  });

  final GroupQuizConfig config;
  final ValueChanged<GroupQuizConfig> onConfigChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E7EF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F18212F),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.groups_2_rounded,
                    size: 72,
                    color: Color(0xFF18212F),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '한 화면을 같이 보고 정답을 외치세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SetupSegment<int>(
                    label: '팀 수',
                    value: config.teamCount,
                    options: const [2, 3, 4],
                    labelBuilder: (value) => '$value팀',
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(teamCount: value)),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '라운드',
                    value: config.roundLimit,
                    options: const [5, 10, 15],
                    labelBuilder: (value) => '$value문제',
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(roundLimit: value)),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '제한 시간',
                    value: config.secondsPerRound,
                    options: const [5, 8, 12],
                    labelBuilder: (value) => '$value초',
                    onChanged: (value) => onConfigChanged(
                      config.copyWith(secondsPerRound: value),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('시작'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB673),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupQuizPlayView extends StatelessWidget {
  const GroupQuizPlayView({
    super.key,
    required this.session,
    required this.onRevealAnswer,
    required this.onAwardTeam,
    required this.onPassQuestion,
  });

  final GroupQuizSession session;
  final VoidCallback onRevealAnswer;
  final ValueChanged<QuizTeam> onAwardTeam;
  final VoidCallback onPassQuestion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuizStatusPanel(
                round: session.round,
                roundLimit: session.config.roundLimit,
                remainingSeconds: session.remainingSeconds,
                secondsPerRound: session.config.secondsPerRound,
                danger: session.isTimerDanger,
              ),
              const SizedBox(height: 14),
              _QuestionPanel(
                question: session.currentQuestion,
                answerVisible: session.answerVisible,
              ),
              const SizedBox(height: 14),
              if (session.answerVisible)
                _AwardPanel(teams: session.teams, onAward: onAwardTeam)
              else
                FilledButton.icon(
                  onPressed: onRevealAnswer,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('정답 보기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF18212F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onPassQuestion,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('패스'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF18212F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ScoreBoard(teams: session.teams),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupSegment<T> extends StatelessWidget {
  const _SetupSegment({
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF60707F),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<T>(
          segments: [
            for (final option in options)
              ButtonSegment<T>(
                value: option,
                label: Text(labelBuilder(option)),
              ),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}

class _QuizStatusPanel extends StatelessWidget {
  const _QuizStatusPanel({
    required this.round,
    required this.roundLimit,
    required this.remainingSeconds,
    required this.secondsPerRound,
    required this.danger,
  });

  final int round;
  final int roundLimit;
  final int remainingSeconds;
  final int secondsPerRound;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _StatusValue(label: 'Round', value: '$round/$roundLimit'),
                _StatusValue(label: 'Time', value: '${remainingSeconds}s'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value:
                    remainingSeconds.clamp(0, secondsPerRound) /
                    secondsPerRound,
                backgroundColor: const Color(0xFF3B4657),
                valueColor: AlwaysStoppedAnimation<Color>(
                  danger ? const Color(0xFFE53935) : const Color(0xFF54C6EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusValue extends StatelessWidget {
  const _StatusValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4DEE8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.question, required this.answerVisible});

  final QuizQuestion question;
  final bool answerVisible;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F18212F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB9E2F4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    color: Color(0xFF18212F),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF18212F),
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1.18,
              ),
            ),
            if (question.hint != null) ...[
              const SizedBox(height: 12),
              Text(
                '힌트: ${question.hint}',
                style: const TextStyle(
                  color: Color(0xFF60707F),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: answerVisible
                  ? Text(
                      question.answer,
                      key: ValueKey(question.id),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE56B1F),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Text(
                      '정답 대기 중',
                      style: TextStyle(
                        color: Color(0xFF8A98A8),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AwardPanel extends StatelessWidget {
  const _AwardPanel({required this.teams, required this.onAward});

  final List<QuizTeam> teams;
  final ValueChanged<QuizTeam> onAward;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0C2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final team in teams)
              FilledButton(
                onPressed: () => onAward(team),
                style: FilledButton.styleFrom(
                  backgroundColor: team.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('${team.name} 정답'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({required this.teams});

  final List<QuizTeam> teams;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teams.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final team = teams[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: team.color, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    color: team.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      '${team.score}',
                      style: const TextStyle(
                        color: Color(0xFF18212F),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'x${team.combo}',
                      style: const TextStyle(
                        color: Color(0xFFE56B1F),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

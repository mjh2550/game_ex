import 'package:flutter/material.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_config.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_session.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_team.dart';

class GroupQuizSetupView extends StatelessWidget {
  const GroupQuizSetupView({
    super.key,
    required this.config,
    required this.categories,
    required this.onConfigChanged,
    required this.onStart,
    required this.starting,
  });

  final GroupQuizConfig config;
  final List<String> categories;
  final ValueChanged<GroupQuizConfig> onConfigChanged;
  final VoidCallback onStart;
  final bool starting;

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
                    '카테고리를 고르고 객관식 정답을 맞히세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SetupSegment<String>(
                    label: '카테고리',
                    value: config.category,
                    options: categories,
                    labelBuilder: (value) => value,
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(category: value)),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '팀 수',
                    value: config.teamCount,
                    options: const [1, 2, 3, 4],
                    labelBuilder: (value) => value == 1 ? '1팀' : '$value팀',
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(teamCount: value)),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '라운드',
                    value: config.roundLimit,
                    options: const [5, 10, 15, 30, 60, 100],
                    labelBuilder: (value) => '$value문제',
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(roundLimit: value)),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '제한 시간',
                    value: config.secondsPerRound,
                    options: const [0, 5, 8, 12],
                    labelBuilder: (value) => value == 0 ? '무제한' : '$value초',
                    onChanged: (value) => onConfigChanged(
                      config.copyWith(secondsPerRound: value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupSegment<int>(
                    label: '목숨',
                    value: config.attemptLimit,
                    options: const [
                      GroupQuizConfig.adaptiveAttempts,
                      GroupQuizConfig.unlimitedAttempts,
                      1,
                      3,
                      5,
                      10,
                    ],
                    labelBuilder: _attemptLimitLabel,
                    onChanged: (value) =>
                        onConfigChanged(config.copyWith(attemptLimit: value)),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: starting ? null : onStart,
                    icon: starting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(starting ? '문제 불러오는 중' : '시작'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB673),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF8EA0AD),
                      disabledForegroundColor: Colors.white,
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
    required this.selectedTeamId,
    required this.answerFeedback,
    required this.onAnswerTeamSelected,
    required this.onAnswerSubmitted,
    required this.onRevealAnswer,
    required this.onPassQuestion,
  });

  final GroupQuizSession session;
  final int selectedTeamId;
  final String? answerFeedback;
  final ValueChanged<QuizTeam> onAnswerTeamSelected;
  final ValueChanged<int> onAnswerSubmitted;
  final VoidCallback onRevealAnswer;
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
                attemptsRemaining: session.attemptsRemaining,
                attemptLimit: session.attemptLimit,
                hasTimeLimit: session.config.hasTimeLimit,
                hasAttemptLimit: session.hasAttemptLimit,
                danger: session.isTimerDanger,
              ),
              const SizedBox(height: 14),
              _QuestionPanel(
                question: session.currentQuestion,
                answerVisible: session.answerVisible,
              ),
              const SizedBox(height: 14),
              if (!session.answerVisible) ...[
                _MultipleChoicePanel(
                  question: session.currentQuestion,
                  teams: session.teams,
                  selectedTeamId: selectedTeamId,
                  attemptsRemaining: session.attemptsRemaining,
                  hasAttemptLimit: session.hasAttemptLimit,
                  feedback: answerFeedback,
                  onTeamSelected: onAnswerTeamSelected,
                  onSubmitted: onAnswerSubmitted,
                ),
                const SizedBox(height: 14),
              ],
              if (session.answerVisible)
                _AnswerResultPanel(question: session.currentQuestion)
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

String _attemptLimitLabel(int value) {
  return switch (value) {
    GroupQuizConfig.adaptiveAttempts => '난이도별',
    GroupQuizConfig.unlimitedAttempts => '무제한',
    _ => '$value개',
  };
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<T>(
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
    required this.attemptsRemaining,
    required this.attemptLimit,
    required this.hasTimeLimit,
    required this.hasAttemptLimit,
    required this.danger,
  });

  final int round;
  final int roundLimit;
  final int remainingSeconds;
  final int secondsPerRound;
  final int attemptsRemaining;
  final int attemptLimit;
  final bool hasTimeLimit;
  final bool hasAttemptLimit;
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
                _StatusValue(
                  label: 'Time',
                  value: hasTimeLimit ? '${remainingSeconds}s' : '∞',
                ),
                _StatusValue(
                  label: 'Try',
                  value: hasAttemptLimit
                      ? '$attemptsRemaining/$attemptLimit'
                      : '∞',
                ),
              ],
            ),
            if (hasTimeLimit) ...[
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
            ] else ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF263246),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3B4657)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '시간 제한 없음',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD4DEE8),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
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

class _MultipleChoicePanel extends StatelessWidget {
  const _MultipleChoicePanel({
    required this.question,
    required this.teams,
    required this.selectedTeamId,
    required this.attemptsRemaining,
    required this.hasAttemptLimit,
    required this.feedback,
    required this.onTeamSelected,
    required this.onSubmitted,
  });

  final QuizQuestion question;
  final List<QuizTeam> teams;
  final int selectedTeamId;
  final int attemptsRemaining;
  final bool hasAttemptLimit;
  final String? feedback;
  final ValueChanged<QuizTeam> onTeamSelected;
  final ValueChanged<int> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB9E2F4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final team in teams)
                  ChoiceChip(
                    selected: team.id == selectedTeamId,
                    label: Text(team.name),
                    avatar: Icon(
                      Icons.groups_rounded,
                      color: team.id == selectedTeamId
                          ? Colors.white
                          : team.color,
                      size: 17,
                    ),
                    selectedColor: team.color,
                    labelStyle: TextStyle(
                      color: team.id == selectedTeamId
                          ? Colors.white
                          : const Color(0xFF18212F),
                      fontWeight: FontWeight.w900,
                    ),
                    onSelected: (_) => onTeamSelected(team),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < question.options.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == question.options.length - 1 ? 0 : 8,
                    ),
                    child: OutlinedButton(
                      onPressed: !hasAttemptLimit || attemptsRemaining > 0
                          ? () => onSubmitted(index)
                          : null,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF18212F),
                        disabledForegroundColor: const Color(0xFF8EA0AD),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: const BorderSide(color: Color(0xFFD4DEE8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          _OptionNumber(index: index),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  !hasAttemptLimit || attemptsRemaining > 1
                      ? Icons.favorite_rounded
                      : Icons.warning_amber_rounded,
                  color: !hasAttemptLimit || attemptsRemaining > 1
                      ? const Color(0xFF2BB673)
                      : const Color(0xFFE56B1F),
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feedback ??
                        (hasAttemptLimit
                            ? '문제당 입력 기회 $attemptsRemaining번'
                            : '문제당 입력 기회 무제한'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionNumber extends StatelessWidget {
  const _OptionNumber({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    const labels = ['①', '②', '③', '④'];
    return SizedBox.square(
      dimension: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF18212F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            labels[index],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
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
    final difficulty = _QuestionDifficultyStyle.fromValue(question.difficulty);

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
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuestionBadge(
                  label: question.category,
                  backgroundColor: const Color(0xFFEAF7FF),
                  borderColor: const Color(0xFFB9E2F4),
                  foregroundColor: const Color(0xFF18212F),
                ),
                _QuestionBadge(
                  label: '난이도 ${difficulty.label}',
                  backgroundColor: difficulty.backgroundColor,
                  borderColor: difficulty.borderColor,
                  foregroundColor: difficulty.foregroundColor,
                ),
              ],
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
                      '${question.answer} ${question.correctOption}',
                      key: ValueKey(question.id),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE56B1F),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Text(
                      '보기를 선택하세요',
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

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _QuestionDifficultyStyle {
  const _QuestionDifficultyStyle({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  static _QuestionDifficultyStyle fromValue(int value) {
    return switch (value) {
      3 => const _QuestionDifficultyStyle(
        label: '상',
        backgroundColor: Color(0xFFFFE8E4),
        borderColor: Color(0xFFFFA08D),
        foregroundColor: Color(0xFFB3261E),
      ),
      2 => const _QuestionDifficultyStyle(
        label: '중',
        backgroundColor: Color(0xFFFFF1D6),
        borderColor: Color(0xFFFFC36A),
        foregroundColor: Color(0xFF9A4F00),
      ),
      _ => const _QuestionDifficultyStyle(
        label: '하',
        backgroundColor: Color(0xFFE8F8EF),
        borderColor: Color(0xFF9ED8B8),
        foregroundColor: Color(0xFF147A45),
      ),
    };
  }
}

class _AnswerResultPanel extends StatelessWidget {
  const _AnswerResultPanel({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0C2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF147A45)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '정답: ${question.answer} ${question.correctOption}',
                style: const TextStyle(
                  color: Color(0xFF18212F),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
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

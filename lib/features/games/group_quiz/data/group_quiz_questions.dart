import 'dart:math';

import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';

const groupQuizQuestions = [
  QuizQuestion(
    id: 'q001',
    type: QuizQuestionType.initial,
    category: '초성',
    question: 'ㅋㅍ ㄹㅋㅂㅅ',
    answer: '쿠팡 로켓배송',
    hint: '미니게임 이름',
  ),
  QuizQuestion(
    id: 'q002',
    type: QuizQuestionType.initial,
    category: '초성',
    question: 'ㅋㅇㅅㅋ ㄴㅊㄱㅇ',
    answer: '키오스크 눈치게임',
    hint: '미니게임 이름',
  ),
  QuizQuestion(
    id: 'q003',
    type: QuizQuestionType.complete,
    category: '이어 말하기',
    question: '가는 말이 고와야',
    answer: '오는 말이 곱다',
  ),
  QuizQuestion(
    id: 'q004',
    type: QuizQuestionType.complete,
    category: '이어 말하기',
    question: '꿩 대신',
    answer: '닭',
  ),
  QuizQuestion(
    id: 'q005',
    type: QuizQuestionType.commonSense,
    category: '상식',
    question: '지구에서 가장 큰 바다는?',
    answer: '태평양',
  ),
  QuizQuestion(
    id: 'q006',
    type: QuizQuestionType.commonSense,
    category: '상식',
    question: '한글을 창제한 왕은?',
    answer: '세종대왕',
  ),
  QuizQuestion(
    id: 'q007',
    type: QuizQuestionType.initial,
    category: '초성',
    question: 'ㅁㄴㄱㅇㅊㄱ',
    answer: '미니게임천국',
    hint: '앱 이름',
  ),
  QuizQuestion(
    id: 'q008',
    type: QuizQuestionType.complete,
    category: '이어 말하기',
    question: '아는 것이',
    answer: '힘이다',
  ),
  QuizQuestion(
    id: 'q009',
    type: QuizQuestionType.commonSense,
    category: '상식',
    question: '대한민국의 수도는?',
    answer: '서울',
  ),
  QuizQuestion(
    id: 'q010',
    type: QuizQuestionType.commonSense,
    category: '넌센스',
    question: '세상에서 가장 빠른 닭은?',
    answer: '후다닭',
  ),
  QuizQuestion(
    id: 'q011',
    type: QuizQuestionType.initial,
    category: '초성',
    question: 'ㅇㅇㅅ ㅁㅅㄷ',
    answer: '아이스 아메리카노',
    hint: '카페 주문 단골',
  ),
  QuizQuestion(
    id: 'q012',
    type: QuizQuestionType.complete,
    category: '이어 말하기',
    question: '티끌 모아',
    answer: '태산',
  ),
];

List<QuizQuestion> buildGroupQuizQuestionDeck({
  required int roundLimit,
  Random? random,
}) {
  final source = random ?? Random();
  final deck = [...groupQuizQuestions]..shuffle(source);
  while (deck.length < roundLimit) {
    deck.addAll([...groupQuizQuestions]..shuffle(source));
  }

  return deck.take(roundLimit).toList();
}

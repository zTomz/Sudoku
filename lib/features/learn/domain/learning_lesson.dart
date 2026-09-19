import '../../../l10n/generated/app_localizations.dart';
import 'learning_progress.dart';

final class const LearningBoard({
  required final List<int> values,
  final Map<int, Set<int>> candidates = const {},
  final Set<int> focusCells = const {},
  final Map<int, Set<int>> removedCandidates = const {},
  final int? selectedCell,
}) {}

final class const LearningQuestion({
  required final String prompt,
  required final List<String> answers,
  required final int correctAnswer,
  required final String rationale,
  required final LearningBoard board,
}) {}

final class const LearningTutorial({
  required final String title,
  required final String creator,
  required final Uri uri,
}) {}

final class const LearningLesson({
  required final LearningSkill skill,
  required final String title,
  required final String summary,
  required final String explanation,
  required final List<LearningQuestion> questions,
  required final List<LearningTutorial> tutorials,
}) {}

LearningBoard _board({
  Map<int, int> values = const {},
  Map<int, Set<int>> candidates = const {},
  Set<int> focusCells = const {},
  Map<int, Set<int>> removedCandidates = const {},
  int? selectedCell,
}) => LearningBoard(
  values: List.generate(81, (cell) => values[cell] ?? 0),
  candidates: candidates,
  focusCells: focusCells,
  removedCandidates: removedCandidates,
  selectedCell: selectedCell,
);

LearningTutorial _tutorial(String title, String creator, String url) =>
    LearningTutorial(title: title, creator: creator, uri: Uri.parse(url));

List<LearningLesson> learningLessons(AppLocalizations l) => [
  LearningLesson(
    skill: .rules,
    title: l.learnLessonRulesTitle,
    summary: l.learnLessonRulesSummary,
    explanation: l.learnLessonRulesBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonRulesQuestion,
        answers: [
          l.learnLessonRulesA,
          l.learnLessonRulesB,
          l.learnLessonRulesC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonRulesBody,
        board: _board(
          values: {0: 7, 10: 4, 20: 2},
          focusCells: {0, 1, 2, 3, 4, 5, 6, 7, 8},
          selectedCell: 4,
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonRulesQ2,
        answers: [
          l.learnLessonRulesQ2A,
          l.learnLessonRulesQ2B,
          l.learnLessonRulesQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonRulesQ2Why,
        board: _board(
          values: {0: 1, 1: 2, 2: 3, 9: 4, 10: 5, 11: 6, 18: 7, 19: 8},
          focusCells: {0, 1, 2, 9, 10, 11, 18, 19, 20},
          selectedCell: 20,
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.learnLessonRulesTitle,
        'Smart Hobbies',
        'https://www.youtube.com/watch?v=IHGNMobRnJE',
      ),
    ],
  ),
  LearningLesson(
    skill: .candidates,
    title: l.learnLessonCandidatesTitle,
    summary: l.learnLessonCandidatesSummary,
    explanation: l.learnLessonCandidatesBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonCandidatesQuestion,
        answers: [
          l.learnLessonCandidatesA,
          l.learnLessonCandidatesB,
          l.learnLessonCandidatesC,
        ],
        correctAnswer: 1,
        rationale: l.learnLessonCandidatesBody,
        board: _board(
          values: {1: 1, 2: 2, 9: 3, 18: 4, 10: 5, 11: 6},
          candidates: {
            0: {7, 8, 9},
          },
          focusCells: {0, 1, 2, 9, 10, 11, 18},
          selectedCell: 0,
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonCandidatesQ2,
        answers: [
          l.learnLessonCandidatesQ2A,
          l.learnLessonCandidatesQ2B,
          l.learnLessonCandidatesQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonCandidatesQ2Why,
        board: _board(
          values: {1: 1, 2: 2, 9: 3, 18: 4, 10: 5, 11: 6},
          candidates: {
            0: {7, 8, 9},
          },
          focusCells: {0, 1, 2, 9, 10, 11, 18},
          selectedCell: 0,
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.learnLessonCandidatesTitle,
        'Smart Hobbies',
        'https://www.youtube.com/watch?v=IHGNMobRnJE',
      ),
    ],
  ),
  LearningLesson(
    skill: .nakedSingle,
    title: l.techniqueNakedSingle,
    summary: l.learnLessonNakedSingleSummary,
    explanation: l.learnLessonNakedSingleBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonNakedSingleQuestion,
        answers: [
          l.learnLessonNakedSingleA,
          l.learnLessonNakedSingleB,
          l.learnLessonNakedSingleC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonNakedSingleBody,
        board: _board(
          candidates: {
            40: {4},
          },
          focusCells: {40},
          selectedCell: 40,
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonNakedSingleQ2,
        answers: [
          l.learnLessonNakedSingleQ2A,
          l.learnLessonNakedSingleQ2B,
          l.learnLessonNakedSingleQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonNakedSingleQ2Why,
        board: _board(
          candidates: {
            40: {3, 8},
          },
          focusCells: {40},
          selectedCell: 40,
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.techniqueNakedSingle,
        'Smart Hobbies',
        'https://www.youtube.com/watch?v=IHGNMobRnJE',
      ),
    ],
  ),
  LearningLesson(
    skill: .hiddenSingle,
    title: l.techniqueHiddenSingle,
    summary: l.learnLessonHiddenSingleSummary,
    explanation: l.learnLessonHiddenSingleBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonHiddenSingleQuestion,
        answers: [
          l.learnLessonHiddenSingleA,
          l.learnLessonHiddenSingleB,
          l.learnLessonHiddenSingleC,
        ],
        correctAnswer: 1,
        rationale: l.learnLessonHiddenSingleBody,
        board: _board(
          candidates: {
            27: {1, 3},
            28: {3, 5},
            29: {1, 4},
            30: {4, 7},
            31: {2, 6},
            32: {1, 9},
            33: {2, 8},
            34: {3, 7},
            35: {4, 8},
          },
          focusCells: {27, 28, 29, 30, 31, 32, 33, 34, 35},
          selectedCell: 31,
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonHiddenSingleQ2,
        answers: [
          l.learnLessonHiddenSingleQ2A,
          l.learnLessonHiddenSingleQ2B,
          l.learnLessonHiddenSingleQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonHiddenSingleQ2Why,
        board: _board(
          candidates: {
            27: {1, 3},
            28: {3, 5},
            29: {1, 4},
            30: {4, 7},
            31: {2, 6},
            32: {1, 9},
            33: {2, 8},
            34: {3, 7},
            35: {4, 8},
          },
          focusCells: {27, 28, 29, 30, 31, 32, 33, 34, 35},
          selectedCell: 31,
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.techniqueHiddenSingle,
        'Smart Hobbies',
        'https://www.youtube.com/watch?v=IHGNMobRnJE',
      ),
    ],
  ),
  LearningLesson(
    skill: .lockedCandidates,
    title: l.techniqueLocked,
    summary: l.learnLessonLockedSummary,
    explanation: l.learnLessonLockedBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonLockedQuestion,
        answers: [
          l.learnLessonLockedA,
          l.learnLessonLockedB,
          l.learnLessonLockedC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonLockedBody,
        board: _board(
          candidates: {
            18: {2, 5},
            20: {5, 8},
            22: {1, 5},
            25: {5, 9},
          },
          focusCells: {18, 20},
          removedCandidates: {
            22: {5},
            25: {5},
          },
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonLockedQ2,
        answers: [
          l.learnLessonLockedQ2A,
          l.learnLessonLockedQ2B,
          l.learnLessonLockedQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonLockedQ2Why,
        board: _board(
          candidates: {
            39: {1, 4},
            41: {4, 8},
            30: {2, 4},
            32: {4, 6},
            48: {3, 4},
            50: {4, 9},
          },
          focusCells: {39, 41},
          removedCandidates: {
            30: {4},
            32: {4},
            48: {4},
            50: {4},
          },
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.techniqueLocked,
        'Sudoku Swami',
        'https://www.youtube.com/watch?v=_VVtYlCI2u0',
      ),
    ],
  ),
  LearningLesson(
    skill: .pairs,
    title: l.learnLessonPairsTitle,
    summary: l.learnLessonPairsSummary,
    explanation: l.learnLessonPairsBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonPairsQuestion,
        answers: [
          l.learnLessonPairsA,
          l.learnLessonPairsB,
          l.learnLessonPairsC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonPairsBody,
        board: _board(
          candidates: {
            28: {2, 8},
            33: {2, 8},
            30: {1, 2, 4},
            35: {5, 8},
          },
          focusCells: {28, 33},
          removedCandidates: {
            30: {2},
            35: {8},
          },
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonPairsQ2,
        answers: [
          l.learnLessonPairsQ2A,
          l.learnLessonPairsQ2B,
          l.learnLessonPairsQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonPairsQ2Why,
        board: _board(
          candidates: {
            11: {1, 4, 7},
            56: {4, 7, 9},
            29: {1, 3},
            74: {2, 8},
          },
          focusCells: {11, 56},
          removedCandidates: {
            11: {1},
            56: {9},
          },
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.learnLessonPairsTitle,
        'Sudoku Swami',
        'https://www.youtube.com/watch?v=NBi6ivpq6_8',
      ),
    ],
  ),
  LearningLesson(
    skill: .triples,
    title: l.learnLessonTriplesTitle,
    summary: l.learnLessonTriplesSummary,
    explanation: l.learnLessonTriplesBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonTriplesQuestion,
        answers: [
          l.learnLessonTriplesA,
          l.learnLessonTriplesB,
          l.learnLessonTriplesC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonTriplesBody,
        board: _board(
          candidates: {
            55: {1, 4},
            58: {4, 9},
            61: {1, 9},
            54: {1, 2, 5},
            62: {3, 4, 8},
          },
          focusCells: {55, 58, 61},
          removedCandidates: {
            54: {1},
            62: {4},
          },
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonTriplesQ2,
        answers: [
          l.learnLessonTriplesQ2A,
          l.learnLessonTriplesQ2B,
          l.learnLessonTriplesQ2C,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonTriplesQ2Why,
        board: _board(
          candidates: {
            60: {1, 2, 5},
            70: {2, 5, 6, 8},
            80: {4, 5, 6},
          },
          focusCells: {60, 70, 80},
          removedCandidates: {
            60: {1},
            70: {8},
            80: {4},
          },
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.learnLessonTriplesTitle,
        'Sudoku Swami',
        'https://www.youtube.com/watch?v=ReU0vvMJtwg',
      ),
    ],
  ),
  LearningLesson(
    skill: .wings,
    title: l.learnLessonWingsTitle,
    summary: l.learnLessonWingsSummary,
    explanation: l.learnLessonWingsBody,
    questions: [
      LearningQuestion(
        prompt: l.learnLessonWingsQuestion,
        answers: [
          l.learnLessonWingsA,
          l.learnLessonWingsB,
          l.learnLessonWingsC,
        ],
        correctAnswer: 0,
        rationale: l.learnLessonWingsBody,
        board: _board(
          candidates: {
            10: {2, 5},
            15: {5, 8},
            55: {1, 5},
            60: {5, 9},
            37: {3, 5},
            78: {4, 5},
          },
          focusCells: {10, 15, 55, 60},
          removedCandidates: {
            37: {5},
            78: {5},
          },
        ),
      ),
      LearningQuestion(
        prompt: l.learnLessonWingsQ2,
        answers: [
          l.learnLessonWingsQ2A,
          l.learnLessonWingsQ2B,
          l.learnLessonWingsQ2C,
        ],
        correctAnswer: 2,
        rationale: l.learnLessonWingsQ2Why,
        board: _board(
          candidates: {
            40: {2, 3},
            37: {2, 7},
            13: {3, 7},
            10: {1, 7, 9},
          },
          focusCells: {40, 37, 13},
          removedCandidates: {
            10: {7},
          },
          selectedCell: 40,
        ),
      ),
    ],
    tutorials: [
      _tutorial(
        l.techniqueXWing,
        'Sudoku Swami',
        'https://www.youtube.com/watch?v=2ZrOBIyb5e4',
      ),
      _tutorial(
        l.techniqueXYWing,
        'Sudoku Swami',
        'https://www.youtube.com/watch?v=3-fcyXnn_uA',
      ),
    ],
  ),
];

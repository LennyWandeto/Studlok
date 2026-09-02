/// Hardcoded question content. `QuizQuestion` is the shared shape used both
/// here and for a Pro user's own AI-generated quizzes (see
/// course_material_repository.dart). `QuestionPack` groups questions into
/// named, user-facing sets — Test Prep and CS & Coding are curated content
/// (Phase: content packs); General Knowledge is the original Phase 9
/// placeholder bank, kept as-is and now serving as the fallback pool for
/// anyone whose subject doesn't cleanly match a curated pack.
class QuizQuestion {
  const QuizQuestion({
    required this.subject,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String subject;
  final String question;
  final List<String> options;
  final int correctIndex;
}

class QuestionPack {
  const QuestionPack({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
  });

  final String id;
  final String name;
  final String description;
  final List<QuizQuestion> questions;
}

// --- Test Prep ---------------------------------------------------------
// SAT/AP-register questions, one subject per content batch. Batch 1 of 5
// (Math) below; English/History/Biology/Chemistry land in later batches.

const List<QuizQuestion> _testPrepMath = [
  QuizQuestion(
    subject: 'Math',
    question: 'Simplify: (3x²)(4x³)',
    options: ['12x⁵', '7x⁵', '12x⁶', '7x⁶'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'If f(x) = 2x − 5, what is f(4)?',
    options: ['13', '8', '3', '-3'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is the slope of the line 2x + 3y = 12?',
    options: ['3/2', '-2/3', '2/3', '-3/2'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'Solve for x: 3(x − 2) = 2x + 4',
    options: ['6', '8', '2', '10'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'Which of the following is a factor of x² − 9?',
    options: ['x − 9', 'x + 9', 'x − 3', 'x − 1'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is 15% of 240?',
    options: ['24', '30', '42', '36'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'The average (arithmetic mean) of 4, 8, and x is 10. What is x?',
    options: ['12', '14', '18', '22'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'If 2ˣ = 32, what is x?',
    options: ['4', '6', '16', '5'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is the area of a circle with radius 4? (in terms of π)',
    options: ['8π', '16π', '32π', '4π'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'A right triangle has legs of length 6 and 8. What is the length of the hypotenuse?',
    options: ['12', '9', '10', '14'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is the sum of the interior angles of a hexagon?',
    options: ['720°', '540°', '900°', '360°'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'Solve for x: x/4 + 3 = 7',
    options: ['12', '16', '20', '4'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'Which of the following is a possible value of x if |x − 5| = 3?',
    options: ['4', '6', '1', '8'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is (2³)(2²)?',
    options: ['16', '64', '32', '8'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'A line with a slope of 0 is:',
    options: ['Vertical', 'Horizontal', 'Diagonal', 'Undefined'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'What is the median of the data set: 3, 7, 9, 12, 15, 20, 22?',
    options: ['9', '13', '12', '15'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'Simplify: (x + 3)(x − 3)',
    options: ['x² + 9', 'x² − 6x − 9', 'x² − 9', 'x² + 6x − 9'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Math',
    question: 'A rectangle has length 9 and width 5. What is its perimeter?',
    options: ['24', '45', '14', '28'],
    correctIndex: 3,
  ),
];

const testPrepPack = QuestionPack(
  id: 'test_prep',
  name: 'Test Prep',
  description: 'SAT & AP-style questions across math, English, history, biology, and chemistry.',
  questions: [
    ..._testPrepMath,
    // English, History, Biology, Chemistry batches land here next.
  ],
);

// --- CS & Coding ---------------------------------------------------------
// Concept questions only — data structures, algorithms/complexity, and
// output prediction on short snippets. No code execution, sandbox, or
// external judge; batches 6-8 land here.

const csCodingPack = QuestionPack(
  id: 'cs_coding',
  name: 'CS & Coding',
  description: 'Data structure, algorithm, and output-prediction concept questions.',
  questions: [],
);

// --- General Knowledge ---------------------------------------------------
// The original Phase 9 placeholder bank — unchanged. Now doubles as the
// fallback pool for anyone whose subject doesn't cleanly match a curated
// pack above.

const List<QuizQuestion> studlokQuizBank = [
  // Science
  QuizQuestion(
    subject: 'Science',
    question: 'What is the chemical symbol for gold?',
    options: ['Au', 'Ag', 'Gd', 'Go'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What planet is known as the Red Planet?',
    options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What gas do plants absorb from the atmosphere for photosynthesis?',
    options: ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'How many bones are in the adult human body?',
    options: ['186', '206', '226', '246'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What is the powerhouse of the cell?',
    options: ['Nucleus', 'Ribosome', 'Mitochondrion', 'Golgi apparatus'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What is the hardest natural substance on Earth?',
    options: ['Quartz', 'Diamond', 'Titanium', 'Obsidian'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What force keeps planets in orbit around the sun?',
    options: ['Magnetism', 'Friction', 'Gravity', 'Inertia'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What is the chemical formula for water?',
    options: ['CO2', 'H2O', 'NaCl', 'O2'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'Which blood type is known as the universal donor?',
    options: ['A', 'B', 'AB', 'O negative'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Science',
    question: 'What part of the atom carries a negative charge?',
    options: ['Proton', 'Neutron', 'Electron', 'Nucleus'],
    correctIndex: 2,
  ),

  // Geography
  QuizQuestion(
    subject: 'Geography',
    question: 'Which is the longest river in the world?',
    options: ['Amazon', 'Nile', 'Yangtze', 'Mississippi'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'What is the largest desert in the world?',
    options: ['Sahara', 'Gobi', 'Antarctic', 'Arabian'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'Which country has the largest population?',
    options: ['United States', 'India', 'China', 'Indonesia'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'What is the smallest country in the world by area?',
    options: ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'Which mountain range separates Europe from Asia?',
    options: ['Alps', 'Andes', 'Ural Mountains', 'Himalayas'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'What is the capital of Australia?',
    options: ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'Which ocean is the largest by surface area?',
    options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'Mount Kilimanjaro is located on which continent?',
    options: ['Asia', 'Africa', 'South America', 'Europe'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'Which country is both in Europe and Asia?',
    options: ['Turkey', 'Egypt', 'Morocco', 'Greece'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Geography',
    question: 'What is the driest continent on Earth (excluding Antarctica)?',
    options: ['Africa', 'Australia', 'Asia', 'South America'],
    correctIndex: 1,
  ),
];

const generalKnowledgePack = QuestionPack(
  id: 'general',
  name: 'General Knowledge',
  description: 'A quick mixed-subject set — always available.',
  questions: studlokQuizBank,
);

/// All packs, in the order they should be offered — curated content first,
/// General Knowledge last as the catch-all. Not yet wired into any
/// selection UI (that's later work); this batch only establishes the data.
const List<QuestionPack> studlokQuestionPacks = [testPrepPack, csCodingPack, generalKnowledgePack];

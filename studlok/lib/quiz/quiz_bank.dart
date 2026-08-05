/// Hardcoded placeholder question bank (Phase 9) — real content curation
/// and per-user subject selection come later. Not AI-generated; every
/// question here is a plain, verifiable fact.
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

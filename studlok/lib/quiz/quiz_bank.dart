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

  /// A stable identifier derived from content, not position — so per-question
  /// attempt history (spaced repetition, mastery tracking) survives batches
  /// being appended or reordered, as long as a question's own text doesn't
  /// change. Deliberately not Dart's built-in `hashCode`, which the language
  /// does not guarantee is stable across app versions/runs — this is a fixed,
  /// simple string hash (djb2) so the same text always yields the same id.
  String get id => _djb2Hash('$subject|$question');
}

String _djb2Hash(String input) {
  var hash = 5381;
  for (final unit in input.codeUnits) {
    hash = ((hash << 5) + hash + unit) & 0x7fffffff;
  }
  return hash.toRadixString(36);
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

const List<QuizQuestion> _testPrepEnglish = [
  QuizQuestion(
    subject: 'English',
    question: 'Neither the students nor the teacher ___ ready for the exam.',
    options: ['are', 'were', 'is', 'be'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence uses the semicolon correctly?',
    options: [
      'She studied all night; because she wanted to ace the test.',
      'She studied all night; and she wanted to ace the test.',
      'She studied all night, she wanted to ace the test.',
      'She studied all night; she wanted to ace the test.',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'English',
    question: "Despite her ___ efforts, the project failed to meet the deadline.",
    options: ['careless', 'lazy', 'reluctant', 'diligent'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which word means the opposite of "ephemeral"?',
    options: ['permanent', 'fleeting', 'transient', 'momentary'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence has correct subject-verb agreement?',
    options: [
      'The list of items is on the table.',
      'The list of items are on the table.',
      'The lists of items is on the table.',
      'The list of item is on the table.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence uses parallel structure correctly?',
    options: [
      'She enjoys reading, writing, and to swim.',
      'She enjoy reading, writing, and swimming.',
      'She enjoys reading, writing, and swimming.',
      'She enjoys to read, writing, and swimming.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence contains a misplaced (dangling) modifier?',
    options: [
      'John missed the bus while running down the street.',
      'Running down the street, the bus was missed by John.',
      'While running down the street, John missed the bus.',
      'John, running down the street, missed the bus.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Choose the best synonym for "ubiquitous."',
    options: ['rare', 'unique', 'occasional', 'omnipresent'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'She studied for weeks; ___, she felt unprepared for the exam.',
    options: ['therefore', 'nevertheless', 'moreover', 'furthermore'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which is the correctly formed possessive? "The ___ books were scattered across the table."',
    options: ["childrens'", "childrens's", "children's", "childs'"],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence is grammatically correct?',
    options: [
      'I finished my homework; I went to bed.',
      'I finished my homework, I went to bed.',
      'I finished my homework I went to bed.',
      'I finished my homework and, I went to bed.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'English',
    question: "Which word means 'to confirm or support with evidence'?",
    options: ['refute', 'undermine', 'dismiss', 'corroborate'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence uses "affect" and "effect" correctly?',
    options: [
      'The medicine had a positive affect on her health.',
      'The medicine will effect her mood significantly.',
      'The medicine had a positive effect on her health.',
      'The medicine will infect her mood significantly.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'What is the primary function of a thesis statement in an essay?',
    options: [
      "To state the essay's main argument or claim",
      'To summarize the conclusion',
      'To list all supporting evidence',
      "To introduce the author's biography",
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which sentence is correctly formed?',
    options: [
      'She is more taller than her sister.',
      'She is tallest than her sister.',
      'She is as taller as her sister.',
      'She is taller than her sister.',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'English',
    question: 'Which word means "to make less severe or intense"?',
    options: ['mitigate', 'exacerbate', 'intensify', 'aggravate'],
    correctIndex: 0,
  ),
];

const List<QuizQuestion> _testPrepHistory = [
  QuizQuestion(
    subject: 'History',
    question: "Which document, adopted in 1776, formally announced the American colonies' separation from Great Britain?",
    options: ['The Declaration of Independence', 'The Constitution', 'The Articles of Confederation', 'The Federalist Papers'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'In what year was the U.S. Constitution drafted at the Constitutional Convention?',
    options: ['1776', '1787', '1788', '1791'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which battle is considered the turning point of the American Civil War in the Eastern theater?',
    options: ['Antietam', 'Bull Run', 'Gettysburg', 'Appomattox'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The Emancipation Proclamation, issued in 1863, declared freedom for slaves in:',
    options: ['All states in the Union', 'Border states only', 'Northern states only', 'Confederate states in rebellion'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which amendment to the U.S. Constitution abolished slavery?',
    options: ['13th Amendment', '14th Amendment', '15th Amendment', '19th Amendment'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The Louisiana Purchase (1803) was made under which U.S. president?',
    options: ['George Washington', 'Thomas Jefferson', 'James Madison', 'John Adams'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which event directly triggered the start of World War I in 1914?',
    options: ['The sinking of the Lusitania', 'The invasion of Poland', 'The assassination of Archduke Franz Ferdinand', 'The Treaty of Versailles'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The Treaty of Versailles (1919) formally ended World War I and imposed heavy reparations on:',
    options: ['France', 'Austria-Hungary', 'Russia', 'Germany'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which event marked the start of the Great Depression in the United States?',
    options: ['The stock market crash of 1929', 'The Dust Bowl', 'World War I', 'The New Deal'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which U.S. president introduced the New Deal in response to the Great Depression?',
    options: ['Herbert Hoover', 'Franklin D. Roosevelt', 'Woodrow Wilson', 'Calvin Coolidge'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The attack on Pearl Harbor, which brought the U.S. into World War II, occurred in which year?',
    options: ['1939', '1940', '1941', '1942'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which country was NOT part of the Axis Powers during World War II?',
    options: ['Germany', 'Italy', 'Japan', 'Soviet Union'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The Cold War was primarily a geopolitical rivalry between the United States and which nation?',
    options: ['Soviet Union', 'China', 'Cuba', 'North Korea'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which U.S. Supreme Court case in 1954 declared racial segregation in public schools unconstitutional?',
    options: ['Plessy v. Ferguson', 'Brown v. Board of Education', 'Marbury v. Madison', 'Roe v. Wade'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Martin Luther King Jr. delivered his famous "I Have a Dream" speech during which event?',
    options: ['The Selma to Montgomery march', 'The Montgomery Bus Boycott', 'The March on Washington', 'The Freedom Rides'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which event is widely considered the symbolic start of the collapse of the Iron Curtain in Europe?',
    options: ['The Cuban Missile Crisis', 'The formation of NATO', 'The Korean War', 'The fall of the Berlin Wall'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'The French Revolution began in which year?',
    options: ['1789', '1776', '1799', '1804'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'History',
    question: 'Which empire, centered in modern-day Turkey, controlled much of Southeast Europe, the Middle East, and North Africa for centuries?',
    options: ['Byzantine Empire', 'Ottoman Empire', 'Persian Empire', 'Roman Empire'],
    correctIndex: 1,
  ),
];

const List<QuizQuestion> _testPrepBiology = [
  QuizQuestion(
    subject: 'Biology',
    question: 'Which organelle is responsible for producing ATP through cellular respiration?',
    options: ['Mitochondrion', 'Ribosome', 'Golgi apparatus', 'Nucleus'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What is the primary function of the cell membrane?',
    options: [
      'To produce energy for the cell',
      'To regulate what substances enter and exit the cell',
      'To store genetic information',
      'To synthesize proteins',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: "Which structure controls a cell's genetic material?",
    options: ['Mitochondrion', 'Ribosome', 'Nucleus', 'Cytoplasm'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Which process do plant cells use to convert light energy into chemical energy?',
    options: ['Cellular respiration', 'Fermentation', 'Osmosis', 'Photosynthesis'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What is the basic structural and functional unit of all living organisms?',
    options: ['The cell', 'The atom', 'The organ', 'The tissue'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'A cross between two heterozygous individuals (Aa × Aa) is expected to produce offspring with a phenotype ratio of:',
    options: ['1:1', '3:1', '1:2:1', '9:3:3:1'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: "What term describes an organism's observable physical traits?",
    options: ['Genotype', 'Karyotype', 'Phenotype', 'Genome'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: "DNA replication is described as 'semi-conservative' because each new molecule contains:",
    options: ['Two original strands', 'Two newly synthesized strands', 'No original strands', 'One original strand and one newly synthesized strand'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Which nitrogenous base pairs with adenine in DNA?',
    options: ['Thymine', 'Cytosine', 'Guanine', 'Uracil'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What is a mutation?',
    options: [
      'The process of cell division',
      "A change in an organism's DNA sequence",
      'The copying of RNA from DNA',
      'The folding of a protein',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Natural selection acts primarily on:',
    options: ['The environment directly', 'Non-heritable traits only', 'Heritable variation within a population', 'Genetic material of a single individual'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Which scientist is credited with the theory of evolution by natural selection?',
    options: ['Gregor Mendel', 'Louis Pasteur', 'Isaac Newton', 'Charles Darwin'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What is genetic drift?',
    options: [
      'Random changes in allele frequencies within a population',
      'The movement of genes between species',
      'The deliberate breeding of organisms',
      'The mutation rate of a gene',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Structures that are similar in different species due to shared common ancestry are called:',
    options: ['Analogous structures', 'Homologous structures', 'Vestigial structures', 'Convergent structures'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What is the primary source of energy for most ecosystems on Earth?',
    options: ['Geothermal heat', 'Wind', 'The sun', 'Water'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'In a food chain, organisms that produce their own food are called:',
    options: ['Consumers', 'Decomposers', 'Predators', 'Producers'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'What term describes the variety of species within a given ecosystem?',
    options: ['Biodiversity', 'Population density', 'Succession', 'Symbiosis'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Biology',
    question: 'Which type of symbiotic relationship benefits one organism while harming the other?',
    options: ['Mutualism', 'Parasitism', 'Commensalism', 'Competition'],
    correctIndex: 1,
  ),
];

const List<QuizQuestion> _testPrepChemistry = [
  QuizQuestion(
    subject: 'Chemistry',
    question: "What does an element's atomic number represent?",
    options: ['The number of protons in the nucleus', 'The number of neutrons in the nucleus', 'The total number of protons and neutrons', 'The number of valence electrons'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'Which subatomic particle has a negative charge?',
    options: ['Proton', 'Electron', 'Neutron', 'Positron'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'Moving from left to right across a period on the periodic table, atomic radius generally:',
    options: ['Increases', 'Stays the same', 'Decreases', 'Increases then decreases'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'Which element has the highest electronegativity?',
    options: ['Oxygen', 'Chlorine', 'Nitrogen', 'Fluorine'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What type of bond forms when electrons are transferred from one atom to another?',
    options: ['Ionic bond', 'Covalent bond', 'Metallic bond', 'Hydrogen bond'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What type of bond involves the sharing of electron pairs between atoms?',
    options: ['Ionic bond', 'Covalent bond', 'Metallic bond', 'Van der Waals interaction'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'In the balanced equation CH₄ + 2O₂ → CO₂ + 2H₂O, what is the coefficient of O₂?',
    options: ['1', '4', '2', '3'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What is the approximate molar mass of water (H₂O)?',
    options: ['16 g/mol', '20 g/mol', '34 g/mol', '18 g/mol'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: "Avogadro's number (approximately 6.022 × 10²³) represents the number of particles in:",
    options: ['One mole of a substance', 'One gram of a substance', 'One liter of gas at STP', 'One atomic mass unit'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What is the pH of a neutral solution at 25°C?',
    options: ['0', '7', '14', '1'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What type of reaction is represented by 2H₂ + O₂ → 2H₂O?',
    options: ['Decomposition', 'Single displacement', 'Synthesis (combination)', 'Double displacement'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'In a redox reaction, oxidation refers to:',
    options: ['Gain of electrons', 'Gain of protons', 'Loss of neutrons', 'Loss of electrons'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What is the limiting reactant in a chemical reaction?',
    options: [
      'The reactant that is completely consumed first, limiting the amount of product formed',
      'The reactant present in excess',
      'The reactant with the highest molar mass',
      'The catalyst used in the reaction',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'According to the ideal gas law, if temperature and moles are held constant, increasing the volume of a gas will:',
    options: ['Increase pressure', 'Decrease pressure', 'Have no effect on pressure', 'Increase temperature'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'Which of the following is an example of a physical change?',
    options: ['Rusting of iron', 'Burning of wood', 'Melting of ice', 'Digestion of food'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'What is the molarity of a solution containing 2 moles of solute dissolved in 4 liters of solution?',
    options: ['2 M', '8 M', '0.25 M', '0.5 M'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: "Which subatomic particle contributes to an atom's mass but has no electric charge?",
    options: ['Neutron', 'Proton', 'Electron', 'Ion'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Chemistry',
    question: 'An exothermic reaction is one that:',
    options: ['Absorbs energy from the surroundings', 'Releases energy to the surroundings', 'Has no energy change', 'Only occurs at high temperatures'],
    correctIndex: 1,
  ),
];

const testPrepPack = QuestionPack(
  id: 'test_prep',
  name: 'Test Prep',
  description: 'SAT & AP-style questions across math, English, history, biology, and chemistry.',
  questions: [
    ..._testPrepMath,
    ..._testPrepEnglish,
    ..._testPrepHistory,
    ..._testPrepBiology,
    ..._testPrepChemistry,
  ],
);

// --- CS & Coding ---------------------------------------------------------
// Concept questions only — data structures, algorithms/complexity, and
// output prediction on short snippets. No code execution, sandbox, or
// external judge; batches 6-8 land here.

const List<QuizQuestion> _csCodingDataStructures = [
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of accessing an element in an array by index?',
    options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which of the following correctly compares arrays and linked lists?',
    options: [
      'Arrays allow O(1) insertion at the beginning, while linked lists require O(n).',
      'Arrays offer O(1) random access, while linked lists require O(n) traversal to reach an element.',
      'Linked lists offer O(1) random access, while arrays do not.',
      'Both offer O(1) random access and O(1) insertion at the beginning.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of inserting an element at the beginning of an array (shifting all existing elements)?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'In a singly linked list, what is the time complexity of inserting a new node at the head?',
    options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of searching for a specific value in an unsorted singly linked list?',
    options: ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the main structural difference between a singly linked list and a doubly linked list?',
    options: [
      'A singly linked list allows traversal in both directions.',
      'A doubly linked list has nodes with pointers to both the next and previous nodes, while a singly linked list only points to the next node.',
      'A doubly linked list stores two values per node.',
      'A doubly linked list cannot be traversed backward.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which principle describes how a stack data structure operates?',
    options: ['FIFO (First In, First Out)', 'Random access', 'LIFO (Last In, First Out)', 'Priority-based access'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of the push and pop operations on a stack?',
    options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which of the following is a common real-world use case for a stack?',
    options: [
      'Tracking function calls (the call stack) and enabling undo operations.',
      'Scheduling print jobs in the order they were submitted.',
      'Finding the shortest path between two nodes in a graph.',
      'Storing key-value pairs for fast lookup.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which principle describes how a queue data structure operates?',
    options: ['LIFO (Last In, First Out)', 'FIFO (First In, First Out)', 'Random access', 'Priority-based access'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is a common real-world use case for a queue?',
    options: [
      'Undoing the most recent action in a text editor.',
      'Storing a fixed-size collection of unique keys.',
      'Managing tasks in the order they arrive, such as a print job queue.',
      'Representing hierarchical data such as a file system.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of enqueue and dequeue operations on a properly implemented queue?',
    options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'In a binary search tree (BST), where are values smaller than a given node typically stored?',
    options: ['In the left subtree', 'In the right subtree', 'At the root', 'In a separate array'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the average time complexity of searching for a value in a balanced binary search tree?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the worst-case time complexity of searching in an unbalanced binary search tree that has degenerated into a linked-list shape?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which tree traversal visits the left subtree, then the current node, then the right subtree?',
    options: ['Pre-order traversal', 'Post-order traversal', 'Level-order traversal', 'In-order traversal'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: "What defines a 'balanced' binary tree?",
    options: [
      'The height difference between the left and right subtrees of any node is small (typically at most 1).',
      'Every node has exactly two children.',
      'All leaf nodes are at the same depth.',
      'The tree contains an equal number of left and right nodes.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the average time complexity of a lookup operation in a well-implemented hash table?',
    options: ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: "What is a 'collision' in the context of a hash table?",
    options: [
      'When a key is inserted twice with the same value.',
      'When the hash table runs out of memory.',
      'When two different keys hash to the same index.',
      'When two threads modify the table simultaneously.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which of the following is a common technique for resolving hash collisions?',
    options: [
      'Sorting the entire table after each insertion.',
      "Doubling the key's value.",
      'Rehashing every element to a new random index.',
      'Chaining (storing multiple entries in a linked list at the same bucket).',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the purpose of a hash function in a hash table?',
    options: [
      'To convert a key into an index within the underlying array.',
      'To sort the keys in ascending order.',
      'To encrypt the stored values for security.',
      'To compress the data before storage.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What property must a min-heap satisfy?',
    options: [
      "Every parent node's value is greater than or equal to its children's values.",
      "Every parent node's value is less than or equal to its children's values.",
      'All leaf nodes are smaller than the root.',
      'The heap must be a perfect binary search tree.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'What is the time complexity of inserting a new element into a binary heap?',
    options: ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Data Structures',
    question: 'Which data structure is most commonly used to implement a priority queue efficiently?',
    options: ['Unsorted array', 'Linked list', 'Hash table', 'Heap'],
    correctIndex: 3,
  ),
];

const List<QuizQuestion> _csCodingOutputPrediction = [
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nx = 5\ndef foo():\n    x = 10\n    return x\nprint(foo(), x)',
    options: ['10 5', '5 5', '10 10', '5 10'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint(3 + 4 * 2)',
    options: ['14', '11', '10', '24'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint("5" + "5")',
    options: ['10', 'Error', '55', '5 5'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this log?\n\nconsole.log(5 + "5")',
    options: ['10', 'NaN', 'TypeError', '55'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nlst = [1, 2, 3]\nlst.append(4)\nprint(lst)',
    options: ['[1, 2, 3, 4]', '[4, 1, 2, 3]', '[1, 2, 3]', 'Error'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ndef add(a, b=5):\n    return a + b\nprint(add(3))',
    options: ['3', '8', 'Error', '5'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print, in order?\n\nfor i in range(3):\n    print(i)',
    options: ['1 2 3', '0 1 2 3', '0 1 2', '3 2 1'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint(10 // 3)',
    options: ['3.33', '1', '4', '3'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint(10 % 3)',
    options: ['1', '3', '0', '3.33'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this log?\n\nlet x = 10;\nif (x) {\n  console.log("truthy");\n} else {\n  console.log("falsy");\n}',
    options: ['falsy', 'truthy', '10', 'undefined'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this log?\n\nconsole.log(typeof "hello")',
    options: ['String', 'text', 'string', 'object'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nx = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)',
    options: ['[1, 2, 3]', 'Error', '[4]', '[1, 2, 3, 4]'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ndef outer():\n    count = 0\n    def inner():\n        nonlocal count\n        count += 1\n        return count\n    return inner()\nprint(outer())',
    options: ['1', '0', 'Error', 'None'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint(bool(0))\nprint(bool(""))\nprint(bool([]))',
    options: ['True, True, True', 'False, False, False', 'False, True, False', 'True, False, True'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this log?\n\nconsole.log([1, 2, 3].length)',
    options: ['2', '4', '3', 'undefined'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ns = "hello"\nprint(s[1])',
    options: ['h', 'l', 'o', 'e'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ns = "hello"\nprint(s[-1])',
    options: ['o', 'h', 'l', 'Error'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint([1, 2, 3][1:3])',
    options: ['[1, 2]', '[2, 3]', '[1, 2, 3]', '[3]'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ndef factorial(n):\n    if n == 0:\n        return 1\n    return n * factorial(n - 1)\nprint(factorial(4))',
    options: ['12', '16', '24', '4'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this log?\n\nconsole.log(2 === "2")',
    options: ['true', '"2"', 'NaN', 'false'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nprint(2 ** 3)',
    options: ['8', '6', '9', '5'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\nx = 1\nx += 1\nx *= 3\nprint(x)',
    options: ['4', '6', '9', '3'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print?\n\ndef greet(name="World"):\n    print(f"Hello, {name}!")\ngreet()',
    options: ['Hello, name!', 'Hello, !', 'Hello, World!', 'Error'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Output Prediction',
    question: 'What does this print, in order?\n\nfor i in range(5):\n    if i == 3:\n        break\n    print(i)',
    options: ['0 1 2 3', '0 1 2 3 4', '1 2 3', '0 1 2'],
    correctIndex: 3,
  ),
];

const List<QuizQuestion> _csCodingAlgorithms = [
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the average-case time complexity of binary search on a sorted array of n elements?',
    options: ['O(log n)', 'O(n)', 'O(1)', 'O(n log n)'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is a precondition for binary search to work correctly?',
    options: ['The array must contain only unique elements', 'The array must be sorted', 'The array must have an odd length', 'The array must be stored as a linked list'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the worst-case time complexity of linear search on an array of n elements?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the average-case time complexity of bubble sort?',
    options: ['O(n log n)', 'O(n)', 'O(log n)', 'O(n²)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the best-case time complexity of an optimized bubble sort (with an early-exit check) on an already-sorted array?',
    options: ['O(n)', 'O(1)', 'O(n²)', 'O(log n)'],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: "What is the time complexity of merge sort, regardless of the input's initial order?",
    options: ['O(n²)', 'O(n log n)', 'O(n)', 'O(log n)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'Which sorting algorithm works by repeatedly dividing the array in half, sorting each half, and merging the results?',
    options: ['Bubble sort', 'Insertion sort', 'Merge sort', 'Selection sort'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the worst-case time complexity of quicksort (e.g., with a poor pivot choice on already-sorted data)?',
    options: ['O(n log n)', 'O(n)', 'O(log n)', 'O(n²)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: "Which property describes a 'stable' sorting algorithm?",
    options: [
      'It preserves the relative order of elements with equal keys.',
      'It always runs in O(n log n) time.',
      'It sorts in place without using extra memory.',
      'It never uses recursion.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the space complexity of merge sort, excluding the input array?',
    options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the average-case space complexity of quicksort due to its recursion stack depth?',
    options: ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What defines the base case in a recursive function?',
    options: [
      'The first line of code in the function.',
      'The largest input the function can handle.',
      'The part of the function that calls itself again.',
      'The condition under which the function stops calling itself and returns a value directly.',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is a risk of writing a recursive function without a proper base case?',
    options: [
      'Infinite recursion, leading to a stack overflow.',
      'The function will run faster.',
      'The function will return 0.',
      'The function will skip execution.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'In Big-O terms, what is the time complexity of a single loop that iterates n times, doing constant-time work each iteration?',
    options: ['O(1)', 'O(n)', 'O(n²)', 'O(log n)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the time complexity of two nested loops, each iterating n times?',
    options: ['O(n)', 'O(2n)', 'O(n²)', 'O(log n)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the time complexity of a loop that halves the problem size on each iteration (e.g., i = i / 2 until i ≤ 1)?',
    options: ['O(n)', 'O(1)', 'O(n log n)', 'O(log n)'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: "Which best describes 'worst-case' time complexity?",
    options: [
      'The maximum time an algorithm could take for any input of a given size.',
      'The average time across all possible inputs.',
      'The minimum time for the best possible input.',
      'The time complexity ignoring input size entirely.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'For a large sorted dataset, which search algorithm is more efficient?',
    options: ['Linear search', 'Binary search', 'Both are equally efficient', 'Neither is efficient for large datasets'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What is the time complexity of finding the maximum element in an unsorted array of n elements?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'Which sorting algorithm is generally efficient for very small or nearly-sorted arrays due to its low overhead?',
    options: ['Merge sort', 'Quicksort', 'Heap sort', 'Insertion sort'],
    correctIndex: 3,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'What does it mean for an algorithm to run in O(1) time?',
    options: [
      'Its execution time does not depend on the size of the input.',
      'It always takes exactly one second to run.',
      'It only works on inputs of size 1.',
      'It runs once and then stops.',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'Which of the following growth rates is the largest (slowest) for large n?',
    options: ['O(log n)', 'O(n²)', 'O(n)', 'O(n log n)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: "Why can't binary search run as efficiently on a singly linked list as it does on an array?",
    options: [
      'Linked lists cannot store sorted data.',
      'Binary search only works on strings.',
      "Linked lists don't support O(1) random access to the middle element, which binary search relies on.",
      'Linked lists are always unsorted.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    subject: 'Algorithms & Complexity',
    question: 'In the average case, how do hash table lookups compare to binary search on a sorted array?',
    options: [
      'Both average O(1).',
      'Both average O(log n).',
      'Hash table lookup is always slower than binary search.',
      'Hash table lookup averages O(1), while binary search averages O(log n).',
    ],
    correctIndex: 3,
  ),
];

const csCodingPack = QuestionPack(
  id: 'cs_coding',
  name: 'CS & Coding',
  description: 'Data structure, algorithm, and output-prediction concept questions.',
  questions: [
    ..._csCodingDataStructures,
    ..._csCodingAlgorithms,
    ..._csCodingOutputPrediction,
  ],
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

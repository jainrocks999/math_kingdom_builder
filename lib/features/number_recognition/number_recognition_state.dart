class NumberRecognitionState {
  final int currentNumber;
  final List<int> options;
  final bool isCorrect;
  final bool showHint;
  final Set<int> masteredNumbers;

  const NumberRecognitionState({
    required this.currentNumber,
    required this.options,
    this.isCorrect = false,
    this.showHint = false,
    this.masteredNumbers = const {},
  });

  NumberRecognitionState copyWith({
    int? currentNumber,
    List<int>? options,
    bool? isCorrect,
    bool? showHint,
    Set<int>? masteredNumbers,
  }) {
    return NumberRecognitionState(
      currentNumber: currentNumber ?? this.currentNumber,
      options: options ?? this.options,
      isCorrect: isCorrect ?? this.isCorrect,
      showHint: showHint ?? this.showHint,
      masteredNumbers: masteredNumbers ?? this.masteredNumbers,
    );
  }
}
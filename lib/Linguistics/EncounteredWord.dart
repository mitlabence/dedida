import '../Word.dart';
// TODO: not null (required) requirement should match that of database (NOT NULL columns)...
class EncounteredWord extends Word {
  final String dateEncountered; // Required parameter
  final String lastReviewed;
  final int timesReviewed; // Optional parameter
  final int timesCorrect;
  final int reviewHistory;
  final int isMastered;
  final String? customNotes;

  EncounteredWord({
    required super.id,
    required super.gender,
    required super.root,
    required super.level, // Pass these to the superclass
    required this.dateEncountered,
    required this.lastReviewed,
    required this.timesReviewed,
    required this.timesCorrect,
    required this.reviewHistory,
    required this.isMastered,
    this.customNotes
  });

  @override
  String toString() {
    return "${super.toString()}, dateEncountered: $dateEncountered, timesReviewed: ${timesReviewed ?? 0}, reviewHistory: $reviewHistory";
  }
}

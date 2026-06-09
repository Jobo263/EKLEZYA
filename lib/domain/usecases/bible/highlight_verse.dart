import '../../repositories/bible_repository.dart';

class HighlightVerseUseCase {
  final BibleRepository _repository;

  const HighlightVerseUseCase(this._repository);

  Future<void> call({
    required String verseId,
    required String color,
    required String userId,
  }) async {
    await _repository.highlightVerse(
      verseId: verseId,
      color: color,
      userId: userId,
    );
  }

  Future<void> remove({
    required String verseId,
    required String userId,
  }) async {
    await _repository.removeHighlight(verseId: verseId, userId: userId);
  }
}

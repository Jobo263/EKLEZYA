import '../../entities/bible_verse.dart';
import '../../repositories/bible_repository.dart';

class GetChapterUseCase {
  final BibleRepository _repository;

  const GetChapterUseCase(this._repository);

  Future<BibleChapter> call({
    required String bookId,
    required int chapter,
    required String translation,
    required String language,
  }) async {
    // Try cache first
    final cached = await _repository.isChapterCached(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
    );

    final result = await _repository.getChapter(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
      language: language,
    );

    // Cache if not already cached
    if (!cached) {
      await _repository.cacheChapter(result);
    }

    return result;
  }
}

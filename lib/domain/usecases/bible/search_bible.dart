import '../../entities/bible_verse.dart';
import '../../repositories/bible_repository.dart';

class SearchBibleUseCase {
  final BibleRepository _repository;

  const SearchBibleUseCase(this._repository);

  Future<List<BibleVerse>> call({
    required String query,
    required String translation,
    required String language,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    return _repository.searchBible(
      query: query.trim(),
      translation: translation,
      language: language,
      limit: limit,
    );
  }
}

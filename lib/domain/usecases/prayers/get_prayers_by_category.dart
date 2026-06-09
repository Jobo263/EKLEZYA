import '../../entities/prayer.dart';
import '../../repositories/prayer_repository.dart';

class GetPrayersByCategoryUseCase {
  final PrayerRepository _repository;

  const GetPrayersByCategoryUseCase(this._repository);

  Future<List<Prayer>> call(PrayerCategory category) async {
    return _repository.getPrayersByCategory(category);
  }

  Future<List<Prayer>> getAll() async {
    return _repository.getAllPrayers();
  }

  Future<List<Prayer>> getDaily({required bool isMorning}) async {
    return _repository.getDailyPrayers(isMorning: isMorning);
  }

  Future<List<Prayer>> getFavorites(String userId) async {
    return _repository.getFavoritePrayers(userId);
  }
}

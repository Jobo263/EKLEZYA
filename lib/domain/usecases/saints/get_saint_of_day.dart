import '../../entities/saint.dart';
import '../../repositories/saint_repository.dart';

class GetSaintOfDayUseCase {
  final SaintRepository _repository;

  const GetSaintOfDayUseCase(this._repository);

  Future<List<Saint>> call() async {
    return _repository.getSaintsForToday();
  }

  Future<List<Saint>> forDate(DateTime date) async {
    return _repository.getSaintsForDate(date);
  }
}

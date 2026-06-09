import '../../entities/liturgical_day.dart';
import '../../repositories/liturgy_repository.dart';

class GetLiturgicalDayUseCase {
  final LiturgyRepository _repository;

  const GetLiturgicalDayUseCase(this._repository);

  Future<LiturgicalDay> call(DateTime date) async {
    return _repository.getLiturgicalDay(date);
  }

  Future<LiturgicalDay> today() async {
    return _repository.getLiturgicalDay(DateTime.now());
  }

  Future<List<LiturgicalDay>> forMonth({
    required int year,
    required int month,
  }) async {
    return _repository.getLiturgicalDaysForMonth(year: year, month: month);
  }
}

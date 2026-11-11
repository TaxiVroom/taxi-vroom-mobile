import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/earnings_model.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(EarningsPeriod period);
}

// The "Gains" tab: the API computes the period's days in Paris time. Spec
// taxi-vroom-api/docs/specs/gains-reels.md.
class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  const EarningsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<EarningsModel> getEarnings(EarningsPeriod period) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/drivers/me/earnings',
      queryParameters: {
        'period': switch (period) {
          EarningsPeriod.today => 'TODAY',
          EarningsPeriod.week => 'WEEK',
          EarningsPeriod.month => 'MONTH',
        },
      },
    );
    return EarningsModel.fromJson(response.data!);
  }
}

import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';

class DriverDocumentRepositoryImpl implements DriverDocumentRepository {
  const DriverDocumentRepositoryImpl(this._dataSource);

  final DriverDocumentRemoteDataSource _dataSource;

  @override
  Future<Result<DriverDocuments>> getDocuments() async {
    try {
      final models = await _dataSource.getDocuments();
      return Result.ok(
        DriverDocuments(models.map((m) => m.toDomain()).toList()),
      );
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

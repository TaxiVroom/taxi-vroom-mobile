import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';

class DriverDocumentRepositoryImpl implements DriverDocumentRepository {
  const DriverDocumentRepositoryImpl(this._dataSource);

  final DriverDocumentRemoteDataSource _dataSource;

  static const _documentsBlocking = 'DRIVER.DOCUMENTS_BLOCKING';

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

  // Refused: the documents screen says why.
  @override
  Future<Result<void>> allowOnline() async {
    try {
      await _dataSource.allowOnline();
      return const Result.ok(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['code'] == _documentsBlocking) {
        return const Result.error(
          DocumentsBlockingFailure(
            'Un document expiré ou manquant vous empêche de passer en ligne.',
          ),
        );
      }
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> submitDocument({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) async {
    try {
      await _dataSource.submitDocument(
        documentTypeId: documentTypeId,
        frontFilePath: frontFilePath,
        backFilePath: backFilePath,
        expiresAt: expiresAt,
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

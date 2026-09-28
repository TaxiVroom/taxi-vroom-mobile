import 'package:mobile/core/data/datasources/connection_remote_datasource.dart';
import 'package:mobile/core/domain/repositories/connection_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  const ConnectionRepositoryImpl(this._dataSource);

  final ConnectionRemoteDataSource _dataSource;

  @override
  Stream<bool> watchConnection() => _dataSource.watchConnection();
}

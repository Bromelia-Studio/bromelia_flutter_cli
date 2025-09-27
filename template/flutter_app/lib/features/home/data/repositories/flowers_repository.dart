import '../../../../models/flower.dart';
import '../datasources/remote/flowers_remote_datasource.dart';

class FlowersRepository {
  final remoteDatasource = FlowersRemoteDatasource();

  Future<List<Flower>> fetchFlowers() {
    return remoteDatasource.fetchFlowers();
  }
}

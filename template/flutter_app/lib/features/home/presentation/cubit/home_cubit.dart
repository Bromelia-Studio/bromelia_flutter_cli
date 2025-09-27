import 'package:bloc/bloc.dart';

import '../../../../models/flower.dart';
import '../../data/repositories/flowers_repository.dart';

part 'home_state.dart';

class home_cubit extends Cubit<HomeState> {
  home_cubit() : super(HomeState());

  final repository = FlowersRepository();

  Future<void> fetchFlowers() async {
    try {
      emit(state.copyWith(isLoading: true));
      final List<Flower> flowers = await repository.fetchFlowers();
      emit(state.copyWith(isLoading: false, flowers: flowers));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'An error occurred'));
      rethrow;
    }
  }
}

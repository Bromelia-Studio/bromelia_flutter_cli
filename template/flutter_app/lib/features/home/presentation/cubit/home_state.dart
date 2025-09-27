part of 'home_cubit.dart';

class HomeState {
  final List<Flower> flowers;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.flowers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<Flower>? flowers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      flowers: flowers ?? this.flowers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

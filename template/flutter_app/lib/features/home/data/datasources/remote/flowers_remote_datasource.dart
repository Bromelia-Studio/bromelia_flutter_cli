import '../../../../../models/flower.dart';

class FlowersRemoteDatasource {
  // Simulate network call
  Future<List<Flower>> fetchFlowers() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final response = [
      {"name": "Rose", "emoji": "🌹"},
      {"name": "Sunflower", "emoji": "🌻"},
      {"name": "Tulip", "emoji": "🌷"},
      {"name": "Cherry Blossom", "emoji": "🌸"},
      {"name": "Hibiscus", "emoji": "🌺"},
      {"name": "Daisy", "emoji": "🌼"},
      {"name": "Lotus", "emoji": "🪷"},
    ];

    return response.map((json) => Flower.fromJson(json)).toList();
  }
}

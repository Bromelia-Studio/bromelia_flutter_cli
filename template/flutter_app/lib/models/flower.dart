import 'package:json_annotation/json_annotation.dart';

part 'flower.g.dart';
@JsonSerializable()
class Flower{
  final String name;
  final String emoji;

  Flower({
    required this.name,
    required this.emoji,
  });

  factory Flower.fromJson(Map<String, dynamic> json) => _$FlowerFromJson(json);

  Map<String, dynamic> toJson() => _$FlowerToJson(this);
}
class RoutinesModel {
  final String id;
  final String description;
  final bool completed;

  RoutinesModel({
    required this.id,
    required this.description,
    this.completed = false,
  });
}

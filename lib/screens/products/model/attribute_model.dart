class AttributeModel {
  final String name;
  final List<String> values;

  AttributeModel({
    required this.name,
    required this.values,
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      name: json['name'],
      values: List<String>.from(json['values']),
    );
  }
}

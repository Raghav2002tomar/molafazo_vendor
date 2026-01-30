class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ChildCategory {
  final int id;
  final String name;

  ChildCategory({required this.id, required this.name});

  factory ChildCategory.fromJson(Map<String, dynamic> json) {
    return ChildCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

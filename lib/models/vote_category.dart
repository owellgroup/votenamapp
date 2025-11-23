class VoteCategory {
  final int? id;
  final String categoryName;

  VoteCategory({
    this.id,
    required this.categoryName,
  });

  factory VoteCategory.fromJson(Map<String, dynamic> json) {
    String name = '';
    
    if (json['CategoryName'] != null) {
      final value = json['CategoryName'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty && json['categoryName'] != null) {
      final value = json['categoryName'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty && json['name'] != null) {
      final value = json['name'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty) {
      final catId = json['id']?.toString() ?? 'Unknown';
      name = 'Category $catId';
    }
    
    return VoteCategory(
      id: json['id'] as int?,
      categoryName: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
    };
  }
}


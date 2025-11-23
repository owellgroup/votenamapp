class Region {
  final int? id;
  final String regionName;

  Region({
    this.id,
    required this.regionName,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    String name = '';
    
    if (json['RegionName'] != null) {
      final value = json['RegionName'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty && json['regionName'] != null) {
      final value = json['regionName'].toString().trim();
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
      final regionId = json['id']?.toString() ?? 'Unknown';
      name = 'Region $regionId';
    }
    
    return Region(
      id: json['id'] as int?,
      regionName: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regionName': regionName,
    };
  }
}


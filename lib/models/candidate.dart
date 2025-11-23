import 'vote_category.dart';

class Candidate {
  final int? id;
  final String fullName;
  final String partyName;
  final String position;
  final String? photoUrl;
  final String? partyLogoUrl;
  final VoteCategory? voteCategory;

  Candidate({
    this.id,
    required this.fullName,
    required this.partyName,
    required this.position,
    this.photoUrl,
    this.partyLogoUrl,
    this.voteCategory,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['photoUrl'] != null && json['photoUrl'].toString().isNotEmpty) {
      final photo = json['photoUrl'].toString();
      
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        photoUrl = photo.replaceAll('http://localhost:8080', 'https://vote.owellgraphics.com')
                        .replaceAll('https://localhost:8080', 'https://vote.owellgraphics.com');
      } else if (photo.startsWith('/')) {
        photoUrl = 'https://vote.owellgraphics.com$photo';
      } else {
        photoUrl = 'https://vote.owellgraphics.com/api/photos/view/$photo';
      }
    }
    
    String? partyLogoUrl;
    if (json['partyLogoUrl'] != null && json['partyLogoUrl'].toString().isNotEmpty) {
      final logo = json['partyLogoUrl'].toString();
      
      if (logo.startsWith('http://') || logo.startsWith('https://')) {
        partyLogoUrl = logo.replaceAll('http://localhost:8080', 'https://vote.owellgraphics.com')
                           .replaceAll('https://localhost:8080', 'https://vote.owellgraphics.com');
      } else if (logo.startsWith('/')) {
        partyLogoUrl = 'https://vote.owellgraphics.com$logo';
      } else {
        partyLogoUrl = 'https://vote.owellgraphics.com/api/logos/view/$logo';
      }
    }
    
    return Candidate(
      id: json['id'] as int?,
      fullName: json['fullName'] ?? '',
      partyName: json['partyName'] ?? '',
      position: json['position'] ?? '',
      photoUrl: photoUrl,
      partyLogoUrl: partyLogoUrl,
      voteCategory: json['voteCategory'] != null
          ? VoteCategory.fromJson(json['voteCategory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'partyName': partyName,
      'position': position,
      'photoUrl': photoUrl,
      'partyLogoUrl': partyLogoUrl,
      'voteCategory': voteCategory?.toJson(),
    };
  }
}


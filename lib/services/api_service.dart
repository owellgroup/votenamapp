import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vote_category.dart';
import '../models/candidate.dart';
import '../models/region.dart';

class ApiService {
  static const String baseUrl = 'https://vote.wayaspot.com';
  //static const String baseUrl = 'http://localhost:8484';

  // Get all vote categories
  static Future<List<VoteCategory>> getVoteCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/vote-categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['voteCategories'] != null) {
          return (data['voteCategories'] as List)
              .map((item) => VoteCategory.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load vote categories');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get candidates by category
  static Future<List<Candidate>> getCandidatesByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/voter/category/$categoryId/candidates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['candidates'] != null) {
          return (data['candidates'] as List)
              .map((item) => Candidate.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load candidates');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all candidates (for results)
  static Future<List<Candidate>> getAllCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/candidates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['candidates'] != null) {
          return (data['candidates'] as List)
              .map((item) => Candidate.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load candidates');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all regions
  static Future<List<Region>> getRegions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/voter/regions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['regions'] != null) {
          return (data['regions'] as List)
              .map((item) => Region.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load regions');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Submit vote
  static Future<Map<String, dynamic>> submitVote({
    required String fullName,
    required String nationalIdNumber,
    required String dateOfBirth,
    required String address,
    required int regionId,
    required String phoneNumber,
    required String email,
    required String votersIdNumber,
    required int candidateId,
    required int voteCategoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/voter/submit-vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': fullName,
          'nationalIdNumber': nationalIdNumber,
          'dateOfBirth': dateOfBirth,
          'address': address,
          'region': {'id': regionId},
          'phoneNumber': phoneNumber,
          'email': email,
          'votersIdNumber': votersIdNumber,
          'candidate': {'id': candidateId},
          'voteCategory': {'id': voteCategoryId},
        }),
      );

      if (response.statusCode != 200) {
        try {
          final result = json.decode(response.body);
          throw Exception(result['message'] ?? 'Failed to submit vote: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to submit vote: ${response.statusCode} - ${response.body}');
        }
      }

      final result = json.decode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to submit vote');
      }

      return result;
    } catch (e) {
      throw Exception('Error submitting vote: $e');
    }
  }

  // Get all votes (for results)
  static Future<List<Map<String, dynamic>>> getAllVotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/votes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['votes'] != null) {
          return (data['votes'] as List).cast<Map<String, dynamic>>();
        }
      }
      throw Exception('Failed to load votes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


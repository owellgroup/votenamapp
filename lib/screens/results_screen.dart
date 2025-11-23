import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/candidate.dart';
import 'candidate_performance_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Candidate> candidates = [];
  List<Map<String, dynamic>> votes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loadedCandidates = await ApiService.getAllCandidates();
      final loadedVotes = await ApiService.getAllVotes();

      // Calculate vote counts for each candidate
      final Map<int, int> voteCounts = {};
      for (var vote in loadedVotes) {
        final candidateId = vote['candidate']?['id'] as int?;
        if (candidateId != null) {
          voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
        }
      }

      // Sort candidates by vote count
      loadedCandidates.sort((a, b) {
        final aCount = voteCounts[a.id] ?? 0;
        final bCount = voteCounts[b.id] ?? 0;
        return bCount.compareTo(aCount);
      });

      setState(() {
        candidates = loadedCandidates;
        votes = loadedVotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  int _getVoteCount(int? candidateId) {
    if (candidateId == null) return 0;
    return votes.where((vote) => vote['candidate']?['id'] == candidateId).length;
  }

  double _getPercentage(int? candidateId) {
    if (votes.isEmpty) return 0.0;
    final count = _getVoteCount(candidateId);
    return (count / votes.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Voting Results',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF41479B),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: loadData,
          child: const Icon(
            CupertinoIcons.arrow_clockwise,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 60,
                          color: CupertinoColors.systemRed,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Error loading results',
                          style: TextStyle(
                            fontSize: 18,
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        CupertinoButton.filled(
                          onPressed: loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF41479B),
                              const Color(0xFF41479B).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF41479B).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  color: CupertinoColors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Total Votes',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${votes.length}',
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Header (always shown, like web version)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF41479B),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildHeaderCell('Photo', flex: 2),
                            _buildHeaderCell('Full Name', flex: 3),
                            _buildHeaderCell('Party', flex: 2),
                            _buildHeaderCell('Position', flex: 2),
                            _buildHeaderCell('Logo', flex: 2),
                            _buildHeaderCell('Votes', flex: 2),
                          ],
                        ),
                      ),
                      // Table Body (always shown, like web version)
                      Expanded(
                        child: candidates.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.chart_bar,
                                        size: 60,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'No candidates found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: CupertinoColors.secondaryLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 0,
                                ),
                                itemCount: candidates.length,
                                itemBuilder: (context, index) {
                                  final candidate = candidates[index];
                                  final voteCount = _getVoteCount(candidate.id);
                                  final isWinner = index == 0 && voteCount > 0;

                                  return _buildTableRow(
                                    candidate: candidate,
                                    voteCount: voteCount,
                                    isWinner: isWinner,
                                    index: index,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow({
    required Candidate candidate,
    required int voteCount,
    required bool isWinner,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => CandidatePerformanceScreen(
              candidate: candidate,
              allVotes: votes,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: isWinner
              ? Border.all(
                  color: const Color(0xFF41479B),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isWinner
                  ? const Color(0xFF41479B).withOpacity(0.2)
                  : CupertinoColors.black.withOpacity(0.05),
              blurRadius: isWinner ? 15 : 8,
              spreadRadius: isWinner ? 2 : 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo Column
            Expanded(
              flex: 2,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: candidate.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: candidate.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            CupertinoIcons.person_fill,
                            size: 40,
                            color: CupertinoColors.systemGrey,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.person_fill,
                          size: 40,
                          color: CupertinoColors.systemGrey,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Full Name Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isWinner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF41479B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            color: CupertinoColors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Leading',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    candidate.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Party Name Column
            Expanded(
              flex: 2,
              child: Text(
                candidate.partyName,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Position Column
            Expanded(
              flex: 2,
              child: Text(
                candidate.position,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Party Logo Column
            Expanded(
              flex: 2,
              child: candidate.partyLogoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: candidate.partyLogoUrl!,
                      fit: BoxFit.contain,
                      height: 60,
                      width: 60,
                      placeholder: (context, url) => const Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        CupertinoIcons.flag,
                        size: 30,
                        color: CupertinoColors.systemGrey,
                      ),
                    )
                  : const Icon(
                      CupertinoIcons.flag,
                      size: 30,
                      color: CupertinoColors.systemGrey,
                    ),
            ),
            const SizedBox(width: 4),
            // Votes Column
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Color(0xFF41479B),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$voteCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWinner
                                ? const Color(0xFF41479B)
                                : CupertinoColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getPercentage(candidate.id).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/candidate.dart';
import '../models/region.dart';
import '../services/api_service.dart';

class CandidatePerformanceScreen extends StatefulWidget {
  final Candidate candidate;
  final List<Map<String, dynamic>> allVotes;

  const CandidatePerformanceScreen({
    super.key,
    required this.candidate,
    required this.allVotes,
  });

  @override
  State<CandidatePerformanceScreen> createState() => _CandidatePerformanceScreenState();
}

class _CandidatePerformanceScreenState extends State<CandidatePerformanceScreen> {
  List<Region> regions = [];
  bool isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    loadRegions();
  }

  Future<void> loadRegions() async {
    try {
      final loadedRegions = await ApiService.getRegions();
      setState(() {
        regions = loadedRegions;
        isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRegions = false;
      });
    }
  }

  int _getVoteCount() {
    return widget.allVotes.where((vote) => vote['candidate']?['id'] == widget.candidate.id).length;
  }

  double _getPercentage() {
    if (widget.allVotes.isEmpty) return 0.0;
    return (_getVoteCount() / widget.allVotes.length) * 100;
  }

  int _getVoteCountForRegion(int? regionId) {
    if (regionId == null) return 0;
    return widget.allVotes.where((vote) {
      final voteCandidateId = vote['candidate']?['id'];
      final voteRegionId = vote['region']?['id'];
      return voteCandidateId == widget.candidate.id && voteRegionId == regionId;
    }).length;
  }

  int _getTotalVotesForRegion(int? regionId) {
    if (regionId == null) return 0;
    return widget.allVotes.where((vote) {
      final voteRegionId = vote['region']?['id'];
      return voteRegionId == regionId;
    }).length;
  }

  double _getPercentageForRegion(int? regionId) {
    final totalRegionVotes = _getTotalVotesForRegion(regionId);
    if (totalRegionVotes == 0) return 0.0;
    final candidateRegionVotes = _getVoteCountForRegion(regionId);
    return (candidateRegionVotes / totalRegionVotes) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final voteCount = _getVoteCount();
    final percentage = _getPercentage();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.candidate.fullName,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF41479B),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Candidate Photo
            Center(
              child: Container(
                width: 150,
                height: 150,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.candidate.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.candidate.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            CupertinoIcons.person_fill,
                            size: 60,
                            color: CupertinoColors.systemGrey,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.person_fill,
                          size: 60,
                          color: CupertinoColors.systemGrey,
                        ),
                ),
              ),
            ),

            // Candidate Info
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.candidate.fullName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.candidate.partyName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.candidate.position,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),

            // Vote Statistics
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF41479B),
                    const Color(0xFF41479B).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF41479B).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Votes',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$voteCount',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of total votes',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Region Performance Table
            if (isLoadingRegions)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CupertinoActivityIndicator(),
                ),
              )
            else if (regions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'No regions available',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
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
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Region',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Votes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Percentage',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Body
                  ...regions.map((region) => _buildRegionRow(region)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionRow(Region region) {
    final regionVotes = _getVoteCountForRegion(region.id);
    final totalRegionVotes = _getTotalVotesForRegion(region.id);
    final regionPercentage = _getPercentageForRegion(region.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Region Name Column
          Expanded(
            flex: 3,
            child: Text(
              region.regionName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Candidate Votes in Region Column
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      color: Color(0xFF41479B),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$regionVotes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Total Votes in Region Column
          Expanded(
            flex: 2,
            child: Text(
              '$totalRegionVotes',
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Percentage Column
          Expanded(
            flex: 2,
            child: Text(
              '${regionPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: regionPercentage > 0
                    ? const Color(0xFF41479B)
                    : CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

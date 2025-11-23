import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/candidate.dart';
import '../models/vote_category.dart';
import 'voter_details_screen.dart';

class CandidatesScreen extends StatefulWidget {
  final VoteCategory voteCategory;

  const CandidatesScreen({
    super.key,
    required this.voteCategory,
  });

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  List<Candidate> candidates = [];
  bool isLoading = true;
  String? error;
  Candidate? selectedCandidate;

  @override
  void initState() {
    super.initState();
    loadCandidates();
  }

  Future<void> loadCandidates() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loadedCandidates = await ApiService.getCandidatesByCategory(
        widget.voteCategory.id!,
      );
      setState(() {
        candidates = loadedCandidates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.voteCategory.categoryName,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF41479B),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: loadCandidates,
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
                          'Error loading candidates',
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
                          onPressed: loadCandidates,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : candidates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.person_circle,
                              size: 60,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No candidates available',
                              style: TextStyle(
                                fontSize: 18,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
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
                                _buildHeaderCell('Select', flex: 2),
                              ],
                            ),
                          ),
                          // Table Body (always shown, like web version)
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 0,
                              ),
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                final candidate = candidates[index];
                                return _buildTableRow(candidate);
                              },
                            ),
                          ),
                          // Continue to Vote Button
                          if (selectedCandidate != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: SafeArea(
                                child: CupertinoButton.filled(
                                  color: const Color(0xFF41479B),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => VoterDetailsScreen(
                                          candidate: selectedCandidate!,
                                          voteCategory: widget.voteCategory,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.check_mark_circled_solid,
                                        color: CupertinoColors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Continue to Vote',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  Widget _buildTableRow(Candidate candidate) {
    final isSelected = selectedCandidate?.id == candidate.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCandidate = candidate;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF41479B),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF41479B).withOpacity(0.2)
                  : CupertinoColors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 2 : 1,
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
            const SizedBox(width: 8),
            // Full Name Column
            Expanded(
              flex: 3,
              child: Text(
                candidate.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
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
            const SizedBox(width: 8),
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
            const SizedBox(width: 8),
            // Party Logo Column (without container)
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
            const SizedBox(width: 8),
            // Selection Indicator Column
            Expanded(
              flex: 2,
              child: Icon(
                isSelected
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: isSelected
                    ? const Color(0xFF41479B)
                    : CupertinoColors.systemGrey3,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

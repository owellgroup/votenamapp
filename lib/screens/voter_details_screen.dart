import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/candidate.dart';
import '../models/vote_category.dart';
import '../models/region.dart';

class VoterDetailsScreen extends StatefulWidget {
  final Candidate candidate;
  final VoteCategory voteCategory;

  const VoterDetailsScreen({
    super.key,
    required this.candidate,
    required this.voteCategory,
  });

  @override
  State<VoterDetailsScreen> createState() => _VoterDetailsScreenState();
}

class _VoterDetailsScreenState extends State<VoterDetailsScreen> {
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _votersIdController = TextEditingController();

  List<Region> regions = [];
  Region? selectedRegion;
  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadRegions();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _votersIdController.dispose();
    super.dispose();
  }

  Future<void> loadRegions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedRegions = await ApiService.getRegions();
      setState(() {
        regions = loadedRegions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load regions: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _dateOfBirthController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text)
        : DateTime(now.year - 18, now.month, now.day);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: CupertinoDatePicker(
          initialDateTime: initialDate,
          maximumDate: now,
          minimumDate: DateTime(1900),
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (date) {
            setState(() {
              _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(date);
            });
          },
        ),
      ),
    );
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    if (fieldName == 'email' && !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _submitVote() async {
    // Validate all fields
    final fullNameError = _validateField(_fullNameController.text, 'full name');
    final nationalIdError = _validateField(_nationalIdController.text, 'national ID');
    final dateError = _validateField(_dateOfBirthController.text, 'date of birth');
    final addressError = _validateField(_addressController.text, 'address');
    final phoneError = _validateField(_phoneController.text, 'phone number');
    final emailError = _validateField(_emailController.text, 'email');
    if (emailError == null && !_emailController.text.contains('@')) {
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Validation Error'),
          content: Text('Please enter a valid email address'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final votersIdError = _validateField(_votersIdController.text, 'voter ID');

    if (fullNameError != null ||
        nationalIdError != null ||
        dateError != null ||
        addressError != null ||
        phoneError != null ||
        emailError != null ||
        votersIdError != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(
            fullNameError ??
                nationalIdError ??
                dateError ??
                addressError ??
                phoneError ??
                emailError ??
                votersIdError ??
                'Please fill in all required fields',
          ),
          actions: const [
            CupertinoDialogAction(
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (selectedRegion == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Validation Error'),
          content: Text('Please select a region'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ApiService.submitVote(
        fullName: _fullNameController.text.trim(),
        nationalIdNumber: _nationalIdController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        address: _addressController.text.trim(),
        regionId: selectedRegion!.id!,
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        votersIdNumber: _votersIdController.text.trim(),
        candidateId: widget.candidate.id!,
        voteCategoryId: widget.voteCategory.id!,
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Your vote has been successfully submitted!'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to submit vote: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final spacing = isSmallScreen ? 12.0 : 16.0;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Voter Details'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: ListView(
            padding: EdgeInsets.all(padding),
            children: [
              // Candidate Info Card
              Container(
                padding: EdgeInsets.all(padding),
                margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 24),
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
                      'Selected Candidate',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.candidate.fullName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF41479B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.candidate.partyName})',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.voteCategory.categoryName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                placeholder: 'Enter your full name',
                icon: CupertinoIcons.person_fill,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _nationalIdController,
                label: 'National ID Number',
                placeholder: 'Enter your national ID',
                icon: CupertinoIcons.doc_text_fill,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your national ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              _buildDateField(),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                placeholder: 'Enter your address',
                icon: CupertinoIcons.location_fill,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              _buildRegionDropdown(),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                placeholder: '+264811234567',
                icon: CupertinoIcons.phone_fill,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'Enter your email',
                icon: CupertinoIcons.mail_solid,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _votersIdController,
                label: 'Voter ID Number',
                placeholder: 'Enter your voter ID',
                icon: CupertinoIcons.creditcard_fill,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your voter ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              CupertinoButton.filled(
                color: const Color(0xFF41479B),
                onPressed: isSubmitting ? null : _submitVote,
                child: isSubmitting
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(
                        'Submit Vote',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: padding),
            ],
          ),
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: CupertinoColors.secondaryLabel),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: CupertinoColors.secondaryLabel,
              ),
              const SizedBox(width: 8),
              const Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            onPressed: _selectDate,
            child: Text(
              _dateOfBirthController.text.isEmpty
                  ? 'Select date of birth'
                  : _dateOfBirthController.text,
              style: TextStyle(
                fontSize: 17,
                color: _dateOfBirthController.text.isEmpty
                    ? CupertinoColors.placeholderText
                    : CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDropdown() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.map_pin_ellipse,
                size: 16,
                color: CupertinoColors.secondaryLabel,
              ),
              const SizedBox(width: 8),
              const Text(
                'Region',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const CupertinoActivityIndicator()
          else
            CupertinoButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    title: const Text('Select Region'),
                    actions: regions.map((region) {
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            selectedRegion = region;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(region.regionName),
                      );
                    }).toList(),
                    cancelButton: CupertinoActionSheetAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                );
              },
              child: Text(
                selectedRegion?.regionName ?? 'Select region',
                style: TextStyle(
                  fontSize: 17,
                  color: selectedRegion == null
                      ? CupertinoColors.placeholderText
                      : CupertinoColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


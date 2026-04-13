import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/color_constants.dart';
import 'package:form_app_27_3_2026/customer_profile_service.dart';
import 'package:form_app_27_3_2026/update_customer_screen.dart';
import 'package:form_app_27_3_2026/new_customer_screen.dart';

class ExistingCustomerScreen extends StatefulWidget {
  const ExistingCustomerScreen({super.key});

  @override
  State<ExistingCustomerScreen> createState() => _ExistingCustomerScreenState();
}

class _ExistingCustomerScreenState extends State<ExistingCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CustomerProfileService _service = CustomerProfileService();
  String _searchType = 'Customer ID';

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _customerData;

  // Decoded image bytes
  Uint8List? _photoBytes;
  Uint8List? _signatureBytes;
  Uint8List? _ovdImg1;
  Uint8List? _ovdImg2;
  Uint8List? _ovdImg3;
  Uint8List? _ovdImg4;
  Uint8List? _form60Img;

  Future<void> _fetchCustomer() async {
    final valueText = _searchController.text.trim();
    if (valueText.isEmpty) {
      _showSnack('Please enter a value to search');
      return;
    }

    String paramName = 'referenceId';
    if (_searchType == 'Aadhaar') paramName = 'aadharNumber';
    if (_searchType == 'PAN') paramName = 'panNumber';
    if (_searchType == 'CIF ID') paramName = 'cifId';

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _customerData = null;
      _photoBytes = null;
      _signatureBytes = null;
      _ovdImg1 = null;
      _ovdImg2 = null;
      _ovdImg3 = null;
      _ovdImg4 = null;
      _form60Img = null;
    });

    final data = await _service.checkExistence(paramName, valueText);

    if (!mounted) return;

    if (data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'No customer found for $_searchType $valueText.\nPlease verify and try again.';
      });
      return;
    }

    if (data['exists'] == false) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Customer details not found for $_searchType $valueText.\nPlease verify and try again.';
      });
      return;
    }

    if (paramName == 'cifId') {
      final aadhar = (data['aadharNumber'] ?? '').toString().trim();
      final pan = (data['panNumber'] ?? '').toString().trim();

      if (aadhar.isEmpty && pan.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewCustomerScreen(initialMobileNumber: data['mobileNumber']?.toString())),
        );
        return;
      }
    }

    Uint8List? decodeStr(String? str) {
      if (str != null && str.isNotEmpty) {
        try {
          // Strip data URI prefix if present (e.g. "data:image/png;base64,")
          String raw = str;
          if (raw.contains(',')) {
            raw = raw.split(',').last;
          }
          return base64Decode(raw);
        } catch (_) {}
      }
      return null;
    }

    setState(() {
      _isLoading = false;
      _customerData = data;
      _photoBytes = decodeStr(data['photoBase64']);
      _signatureBytes = decodeStr(data['signatureBase64']);
      _ovdImg1 = decodeStr(data['ovdImg1Base64']);
      _ovdImg2 = decodeStr(data['ovdImg2Base64']);
      _ovdImg3 = decodeStr(data['ovdImg3Base64']);
      _ovdImg4 = decodeStr(data['ovdImg4Base64']);
      _form60Img = decodeStr(data['form60_61_ImgBase64']);
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text(
          'Existing Customer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2F5A).withOpacity(0.5),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSearchSection(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SEARCH SECTION
  // ───────────────────────────────────────────────────────────────

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2040),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Details',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _searchType,
                      dropdownColor: const Color(0xFF1A2F5A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null)
                          setState(() => _searchType = newValue);
                      },
                      items: <String>['Customer ID', 'Aadhaar', 'PAN', 'CIF ID']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    keyboardType: _searchType == 'PAN'
                        ? TextInputType.text
                        : TextInputType.number,
                    onSubmitted: (_) => _fetchCustomer(),
                    decoration: InputDecoration(
                      hintText: 'Enter $_searchType…',
                      hintStyle: const TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchCustomer,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A1628),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.search,
                      color: Color(0xFF0A1628),
                      size: 20,
                    ),
              label: Text(
                _isLoading ? 'Searching…' : 'Search',
                style: const TextStyle(
                  color: Color(0xFF0A1628),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BODY STATE
  // ───────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_customerData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a Customer ID and tap Search\nto view customer details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    return _buildCustomerProfile();
  }

  // ───────────────────────────────────────────────────────────────
  // CUSTOMER PROFILE CARD
  // ───────────────────────────────────────────────────────────────

  Widget _buildCustomerProfile() {
    final d = _customerData!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card with photo & name
          _buildHeaderCard(d),
          const SizedBox(height: 16),
          // Detail sections
          _buildSection('Personal Information', Icons.person_outline, [
            _row('Customer ID', '${d['referenceID'] ?? d['customerId']}'),
            _row('Full Name', d['fullName']),
            _row('Name in Marathi', d['nameInMarathi']),
            _row('Father / Husband Name', d['fatherOrHusbandName']),
            _row('Mother Name', d['motherName']),
            _row('Date of Birth', _formatDate(d['dob'])),
            _row('Gender', d['gender']),
            _row('Marital Status', d['maritalStatus']),
            _row('Nationality', d['nationality']),
            _row('Residential Status', d['residentialStatus']),
            _row('Religion', d['religion']),
            _row('Category', d['category']),
          ]),
          const SizedBox(height: 12),
          _buildSection('Contact Information', Icons.contact_phone_outlined, [
            _row('Mobile', d['mobileNumber']),
            _row('Alternate Mobile', d['alternateMobile']),
            _row('Email', d['email']),
          ]),
          const SizedBox(height: 12),
          _buildSection('Current Address', Icons.location_on_outlined, [
            _row('Address', d['currentAddress']),
            _row('City', d['currentCity']),
            _row('Taluka', d['currentTaluka']),
            _row('District', d['currentDistrict']),
            _row('State', d['currentState']),
            _row('PIN Code', d['currentPinCode']),
            _row('Country', d['currentCountry']),
          ]),
          const SizedBox(height: 12),
          _buildSection(
            'Permanent Address',
            Icons.home_outlined,
            d['isPermanentSame'] == true
                ? [_rowRaw(text: 'Same as current address', isNote: true)]
                : [
                    _row('Address', d['permanentAddress']),
                    _row('City', d['permanentCity']),
                    _row('Taluka', d['permanentTaluka']),
                    _row('District', d['permanentDistrict']),
                    _row('State', d['permanentState']),
                    _row('PIN Code', d['permanentPinCode']),
                    _row('Country', d['permanentCountry']),
                  ],
          ),
          const SizedBox(height: 12),
          _buildSection('KYC & Documents', Icons.verified_outlined, [
            _row('Aadhaar Number', d['aadharNumber']),
            _row('PAN Number', d['panNumber']),
            _rowRaw(text: 'OVD Document 1', isNote: true),
            _row('OVD Type 1', d['ovdType_1']),
            _row('OVD Number 1', d['ovdNumber_1']),
            _row('OVD Expiry 1', _formatDate(d['ovdExpiryDate_1'])),
            if ((d['ovdType_2'] ?? '').toString().isNotEmpty) ...[
              _rowRaw(text: 'OVD Document 2', isNote: true),
              _row('OVD Type 2', d['ovdType_2']),
              _row('OVD Number 2', d['ovdNumber_2']),
              _row('OVD Expiry 2', _formatDate(d['ovdExpiryDate_2'])),
            ],
            if ((d['ovdType_3'] ?? '').toString().isNotEmpty) ...[
              _rowRaw(text: 'OVD Document 3', isNote: true),
              _row('OVD Type 3', d['ovdType_3']),
              _row('OVD Number 3', d['ovdNumber_3']),
              _row('OVD Expiry 3', _formatDate(d['ovdExpiryDate_3'])),
            ],
            _row('Address Proof Type', d['addressProofType']),
            _row('Address Proof Number', d['addressProofNumber']),
            _row('Form Type', d['formType']),
          ]),
          const SizedBox(height: 12),
          _buildSection('Professional & Financial', Icons.work_outline, [
            _row('Occupation', d['occupation']),
            _row('Employer Name', d['employerName']),
            _row('Designation', d['designation']),
            _row('Annual Income', d['annualIncome']),
            _row('Source of Funds', d['sourceOfFunds']),
            _row('Is PEP', d['isPEP'] == true ? 'Yes' : 'No'),
            _row('Related to PEP', d['isRelatedToPEP'] == true ? 'Yes' : 'No'),
          ]),
          const SizedBox(height: 12),
          if ((d['nomineeName'] ?? '').toString().isNotEmpty) ...[
            _buildSection('Nominee 1 Details', Icons.family_restroom_outlined, [
              _row('Nominee Name', d['nomineeName']),
              _row('Relationship', d['nomineeRelationship']),
              _row('Nominee DOB', _formatDate(d['nomineeDOB'])),
              _row('Nominee Age', '${d['nomineeAge']}'),
              _row('Share %', '${d['nomineeSharePercent']}%'),
              _row('Nominee Address', d['nomineeAddress']),
              _row('Guardian Name', d['guardianName']),
            ]),
            const SizedBox(height: 12),
          ],
          if ((d['nomineeName1'] ?? '').toString().isNotEmpty) ...[
            _buildSection('Nominee 2 Details', Icons.family_restroom_outlined, [
              _row('Nominee Name', d['nomineeName1']),
              _row('Relationship', d['nomineeRelationship1']),
              _row('Nominee DOB', _formatDate(d['nomineeDOB1'])),
              _row('Nominee Age', '${d['nomineeAge1']}'),
              _row('Share %', '${d['nomineeSharePercent1']}%'),
              _row('Nominee Address', d['nomineeAddress1']),
              _row('Guardian Name', d['guardianName1']),
            ]),
            const SizedBox(height: 12),
          ],
          if ((d['nomineeName2'] ?? '').toString().isNotEmpty) ...[
            _buildSection('Nominee 3 Details', Icons.family_restroom_outlined, [
              _row('Nominee Name', d['nomineeName2']),
              _row('Relationship', d['nomineeRelationship2']),
              _row('Nominee DOB', _formatDate(d['nomineeDOB2'])),
              _row('Nominee Age', '${d['nomineeAge2']}'),
              _row('Share %', '${d['nomineeSharePercent2']}%'),
              _row('Nominee Address', d['nomineeAddress2']),
              _row('Guardian Name', d['guardianName2']),
            ]),
          ],
          const SizedBox(height: 12),
          // Signature card
          if (_signatureBytes != null)
            _buildImageCard('Signature', _signatureBytes!),

          const SizedBox(height: 12),
          if (_ovdImg1 != null)
            _buildImageCard(
              'OVD Document 1 — ${_customerData!['ovdType_1'] ?? ''}',
              _ovdImg1!,
            ),
          const SizedBox(height: 12),
          if (_ovdImg2 != null)
            _buildImageCard(
              'OVD Document 2 — ${_customerData!['ovdType_2'] ?? ''}',
              _ovdImg2!,
            ),
          const SizedBox(height: 12),
          if (_ovdImg3 != null)
            _buildImageCard(
              'OVD Document 3 — ${_customerData!['ovdType_3'] ?? ''}',
              _ovdImg3!,
            ),
          const SizedBox(height: 12),
          if (_ovdImg4 != null) _buildImageCard('OVD Document 4', _ovdImg4!),
          const SizedBox(height: 12),
          if (_form60Img != null)
            _buildImageCard('Form 60/61 Reference', _form60Img!),
          const SizedBox(height: 12),
          _row('Created Date', _formatDate(d['createdDate'])),
          const SizedBox(height: 24),

          // ── Update Profile Button ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UpdateCustomerScreen(customerData: _customerData!),
                  ),
                );
                // If update was successful, re-fetch to show fresh data
                if (result == true) {
                  _fetchCustomer();
                }
              },
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF0A1628)),
              label: const Text(
                'Update Profile',
                style: TextStyle(
                  color: Color(0xFF0A1628),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HEADER WITH PHOTO
  // ───────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(Map<String, dynamic> d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _photoBytes != null
                ? Image.memory(
                    _photoBytes!,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Container(
                    width: 80,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  d['fullName'] ?? '—',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${d['referenceID'] ?? d['customerId']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  d['gender'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'DOB: ${_formatDate(d['dob'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SECTION CARD
  // ───────────────────────────────────────────────────────────────

  Widget _buildSection(String title, IconData icon, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkNavy.withOpacity(0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.darkNavy, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // IMAGE CARD (Signature)
  // ───────────────────────────────────────────────────────────────

  Widget _buildImageCard(String label, Uint8List bytes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.draw_outlined,
                color: AppColors.darkNavy,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                bytes,
                height: 80,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────────────────────

  Widget _row(String label, dynamic value) {
    final text = (value == null || value.toString().isEmpty)
        ? '—'
        : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowRaw({required String text, bool isNote = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (isNote)
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          if (isNote) const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isNote ? Colors.grey : AppColors.darkNavy,
                fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}

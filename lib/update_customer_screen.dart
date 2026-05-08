import 'dart:developer';
import 'package:form_app_27_3_2026/login_screen.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/widgets/image_upload_preview.dart';
import 'package:form_app_27_3_2026/image_preview_screen.dart';
import 'package:form_app_27_3_2026/color_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:form_app_27_3_2026/pan_verification_service.dart';
import 'package:form_app_27_3_2026/customer_profile_service.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,

    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }

      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,

      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,

    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),

      selection: newValue.selection,
    );
  }
}

class MonthYearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,

    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 6) text = text.substring(0, 6);

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';

      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,

      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class NomineeEntry {
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController relationshipController = TextEditingController();

  final TextEditingController otherRelationshipController =
      TextEditingController();

  String? selectedRelationship;

  final TextEditingController dobController = TextEditingController();

  final TextEditingController ageController = TextEditingController();

  final TextEditingController shareController = TextEditingController();

  final TextEditingController guardianAddressController =
      TextEditingController();

  void dispose() {
    fullNameController.dispose();

    relationshipController.dispose();

    otherRelationshipController.dispose();

    dobController.dispose();

    ageController.dispose();

    shareController.dispose();

    guardianAddressController.dispose();
  }
}

class UpdateCustomerScreen extends StatefulWidget {
  final Map<String, dynamic> customerData;

  const UpdateCustomerScreen({super.key, required this.customerData});

  @override
  State<UpdateCustomerScreen> createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  @override
  void initState() {
    super.initState();
    final d = widget.customerData;

    _isAadhaarVerified = true;
    _isPanVerified = true;
    _mobileOtpState = 2; // Verified

    _fullNameController.text = d['fullName'] ?? '';
    _nameMarathiController.text = d['nameInMarathi'] ?? '';
    _fatherHusbandNameController.text = d['fatherOrHusbandName'] ?? '';
    _motherNameController.text = d['motherName'] ?? '';

    if (d['dob'] != null) {
      String iso = d['dob'];
      if (iso.contains('-') && iso.length >= 10) {
        final parts = iso.split('T')[0].split('-');
        if (parts.length == 3) {
          _dobController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          _dobController.text = iso;
        }
      } else {
        _dobController.text = iso;
      }
    }

    _religionController.text = d['religion'] ?? '';
    _currentAddressController.text = d['currentAddress'] ?? '';
    _villageCityController.text = d['currentCity'] ?? '';
    _talukaController.text = d['currentTaluka'] ?? '';
    _districtController.text = d['currentDistrict'] ?? '';
    _stateController.text = d['currentState'] ?? '';
    _pinCodeController.text = d['currentPinCode'] ?? '';
    _countryController.text = d['currentCountry'] ?? '';

    _permanentAddressController.text = d['permanentAddress'] ?? '';
    _permVillageCityController.text = d['permanentCity'] ?? '';
    _permTalukaController.text = d['permanentTaluka'] ?? '';
    _permDistrictController.text = d['permanentDistrict'] ?? '';
    _permStateController.text = d['permanentState'] ?? '';
    _permPinCodeController.text = d['permanentPinCode'] ?? '';
    _permCountryController.text = d['permanentCountry'] ?? '';

    _panNumberController.text = d['panNumber'] ?? '';
    _aadhaarCkycController.text = d['aadharNumber'] ?? '';

    _mobileNumberController.text = d['mobileNumber'] ?? '';
    _alternateMobileController.text = d['alternateMobile'] ?? '';
    _emailController.text = d['email'] ?? '';

    _employerNameController.text = d['employerName'] ?? '';
    _designationController.text = d['designation'] ?? '';

    _selectedGender = (d['gender']?.isNotEmpty == true) ? d['gender'] : null;
    _selectedMaritalStatus = (d['maritalStatus']?.isNotEmpty == true)
        ? d['maritalStatus']
        : null;
    _selectedNationality = (d['nationality']?.isNotEmpty == true)
        ? d['nationality']
        : null;
    _selectedResidentialStatus = (d['residentialStatus']?.isNotEmpty == true)
        ? d['residentialStatus']
        : null;
    _selectedCategory = (d['category']?.isNotEmpty == true)
        ? d['category']
        : null;
    _selectedPermanentAddressSame = (d['isPermanentSame'] == true)
        ? "Same as Current"
        : "Different";

    _form60Status = d['formType'] ?? "N/A";

    _selectedOccupation = (d['occupation']?.isNotEmpty == true)
        ? d['occupation']
        : null;
    _selectedAnnualIncome = (d['annualIncome']?.isNotEmpty == true)
        ? d['annualIncome']
        : null;
    _selectedSourceOfFunds = (d['sourceOfFunds']?.isNotEmpty == true)
        ? d['sourceOfFunds']
        : null;
    _selectedPep = (d['isPEP'] == true) ? "Yes" : "No";
    _selectedRelatedPep = (d['isRelatedToPEP'] == true) ? "Yes" : "No";

    Uint8List? decodeB64(String? str) {
      if (str != null && str.isNotEmpty) {
        try {
          String raw = str;
          if (raw.contains(',')) raw = raw.split(',').last;
          raw = raw.replaceAll(RegExp(r'\s+'), ''); // Clean whitespaces
          return base64Decode(raw);
        } catch (_) {}
      }
      return null;
    }

    // Process Images in async block
    Future.microtask(() async {
      try {
        Directory tempDir = Directory.systemTemp;
        String tempPath = tempDir.path;

        Future<XFile?> createTempFile(Uint8List? bytes, String name) async {
          if (bytes == null) return null;
          File f = File('$tempPath/$name.jpg');
          await f.writeAsBytes(bytes);
          return XFile(f.path);
        }

        _profileImageBytes = decodeB64(d['photoBase64']);
        if (_profileImageBytes != null) {
          _photoFile = await createTempFile(
            _profileImageBytes,
            'photo_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        _signatureBytes = decodeB64(d['signatureBase64']);
        if (_signatureBytes != null) {
          _signatureFile = await createTempFile(
            _signatureBytes,
            'sig_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        _form60Bytes = decodeB64(d['form60_61_ImgBase64']);
        if (_form60Bytes != null) {
          _form60File = await createTempFile(
            _form60Bytes,
            'form60_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        _ovdImageBytesCache[0] = decodeB64(d['ovdImg1Base64']);
        if (_ovdImageBytesCache[0] != null) {
          _ovdImageFiles[0] = await createTempFile(
            _ovdImageBytesCache[0],
            'ovd1_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        _ovdImageBytesCache[1] = decodeB64(d['ovdImg2Base64']);
        if (_ovdImageBytesCache[1] != null) {
          _ovdImageFiles[1] = await createTempFile(
            _ovdImageBytesCache[1],
            'ovd2_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        _ovdImageBytesCache[2] = decodeB64(d['ovdImg3Base64']);
        if (_ovdImageBytesCache[2] != null) {
          _ovdImageFiles[2] = await createTempFile(
            _ovdImageBytesCache[2],
            'ovd3_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        // Load Aadhaar back photo (ovdImg4)
        _aadhaarBackBytesCache = decodeB64(d['ovdImg4Base64']);
        if (_aadhaarBackBytesCache != null) {
          _aadhaarBackFile = await createTempFile(
            _aadhaarBackBytesCache,
            'aadhaar_back_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        if (mounted) setState(() {});
      } catch (e) {
        print('Error writing temp files: $e');
      }
    });

    String ovd1Type = d['ovdType_1'] ?? '';
    String ovd2Type = d['ovdType_2'] ?? '';
    String ovd3Type = d['ovdType_3'] ?? '';

    int cnt = 0;
    if (ovd1Type.isNotEmpty) cnt++;
    if (ovd2Type.isNotEmpty) cnt++;
    if (ovd3Type.isNotEmpty) cnt++;
    _ovdCount = cnt > 0 ? cnt : 2;

    if (ovd1Type.isNotEmpty) _ovdTypes[0] = ovd1Type;
    if (ovd2Type.isNotEmpty) _ovdTypes[1] = ovd2Type;
    if (ovd3Type.isNotEmpty) _ovdTypes[2] = ovd3Type;

    _ovdNumberControllers[0].text = d['ovdNumber_1'] ?? '';
    _ovdNumberControllers[1].text = d['ovdNumber_2'] ?? '';
    _ovdNumberControllers[2].text = d['ovdNumber_3'] ?? '';

    if (d['ovdExpiryDate_1'] != null && d['ovdExpiryDate_1'] != '') {
      String iso = d['ovdExpiryDate_1'];
      if (iso.contains('-')) {
        final parts = iso.split('T')[0].split('-');
        if (parts.length == 3)
          _ovdExpiryControllers[0].text = '${parts[1]}/${parts[0]}';
      }
    }
    if (d['ovdExpiryDate_2'] != null && d['ovdExpiryDate_2'] != '') {
      String iso = d['ovdExpiryDate_2'];
      if (iso.contains('-')) {
        final parts = iso.split('T')[0].split('-');
        if (parts.length == 3)
          _ovdExpiryControllers[1].text = '${parts[1]}/${parts[0]}';
      }
    }
    if (d['ovdExpiryDate_3'] != null && d['ovdExpiryDate_3'] != '') {
      String iso = d['ovdExpiryDate_3'];
      if (iso.contains('-')) {
        final parts = iso.split('T')[0].split('-');
        if (parts.length == 3)
          _ovdExpiryControllers[2].text = '${parts[1]}/${parts[0]}';
      }
    }

    // Nominees
    _nominees.clear();
    List<String> validRels = [
      'Parent',
      'Spouse',
      'Child',
      'Sibling',
      'Grandparent',
      'Grandchild',
      'Relative',
      'Friend',
      'Other',
    ];
    for (int i = 0; i < 3; i++) {
      String suffix = i == 0 ? "" : "$i";
      String nName = d['nomineeName$suffix'] ?? '';
      if (nName.isNotEmpty) {
        var n = NomineeEntry();
        n.fullNameController.text = nName;

        String rel = d['nomineeRelationship$suffix'] ?? '';
        if (rel.isNotEmpty) {
          n.relationshipController.text = rel;
          if (validRels.contains(rel)) {
            n.selectedRelationship = rel;
          } else {
            n.selectedRelationship = 'Other';
            n.otherRelationshipController.text = rel;
          }
        }

        if (d['nomineeDOB$suffix'] != null) {
          String iso = d['nomineeDOB$suffix'];
          if (iso.contains('-') && iso.length >= 10) {
            final parts = iso.split('T')[0].split('-');
            if (parts.length == 3) {
              n.dobController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
            } else {
              n.dobController.text = iso;
            }
          }
        }

        n.ageController.text = (d['nomineeAge$suffix'] ?? '').toString();
        var shareVal = d['nomineeSharePercent$suffix'];
        if (shareVal != null) {
          double? parsed = double.tryParse(shareVal.toString());
          if (parsed != null) {
            n.shareController.text = parsed.toInt().toString();
          } else {
            n.shareController.text = shareVal.toString();
          }
        } else {
          n.shareController.text = '';
        }

        if (n.ageController.text == '0' || n.ageController.text == '0.0')
          n.ageController.text = '';
        if (n.shareController.text == '0' || n.shareController.text == '0.0')
          n.shareController.text = '';

        n.guardianAddressController.text = d['guardianName$suffix'] ?? '';
        _nominees.add(n);
      }
    }
    if (_nominees.isEmpty) {
      _nominees.add(NomineeEntry());
    }

    // Check for images lost during Android process death
    _retrieveLostData();
  }

  // State for Aadhaar verification

  bool _isAadhaarVerified = false; //testing

  bool _isOtpSent = false;

  bool _isAadhaarLoading = false;

  Uint8List? _profileImageBytes;

  // State for PAN verification

  bool _isPanVerified = false;

  bool _isPanLoading = false;
  bool _isOpeningCamera = false;

  // Tracks which image type was being captured when camera launched
  // Used for process-death recovery via retrieveLostData
  String?
  _pendingImageType; // 'photo', 'signature', 'ovd_0', 'ovd_1', 'ovd_2', 'form60', 'aadhaar_back'

  final PanVerificationService _panService = PanVerificationService();

  bool _isSubmitting = false;

  final CustomerProfileService _service = CustomerProfileService();

  // Form Navigation State

  int _currentFormStep = 0;

  final int _totalSteps = 6;

  final ScrollController _scrollController = ScrollController();

  XFile? _photoFile;
  Uint8List?
  _photoBytes; // ✅ cached bytes — survives temp-file cleanup & Android process death

  XFile? _signatureFile;
  Uint8List?
  _signatureBytes; // ✅ cached bytes so temp-file cleanup won't lose data

  // Per-OVD slot image files (one per OVD document)
  final List<XFile?> _ovdImageFiles = [null, null, null];
  final List<Uint8List?> _ovdImageBytesCache = [
    null,
    null,
    null,
  ]; // ✅ cached bytes

  // Aadhaar back photo (shared across all OVD slots — one Aadhaar back photo)
  XFile? _aadhaarBackFile;
  Uint8List? _aadhaarBackBytesCache;
  Map<String, String>? _aadhaarBackLocationData;

  // ADD THIS LINE to store the location data for each captured OVD image
  final List<Map<String, String>?> _ovdLocationData = [null, null, null];

  XFile? _form60File;
  Uint8List? _form60Bytes; // ✅ cached bytes

  final ImagePicker _picker = ImagePicker();

  /// Tracks which image slots are currently uploading.
  final Set<String> _uploadingSlots = {};

  String get _currentReferenceId {
    return (widget.customerData['referenceID'] ??
            widget.customerData['customerId'] ??
            '')
        .toString();
  }

  void _showErrorPopup(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _uploadImageInstantly({
    required String imageSlot,
    required String documentType,
    required String documentNumber,
    required Uint8List imageBytes,
    required String? expiryDate,
    required Map<String, String>? locationData,
  }) async {
    try {
      // Backend requires the data URI prefix on the base64 string
      final String base64Image =
          'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final String captureDate =
          locationData?["captureDate"] ??
          DateTime.now()
              .toUtc()
              .add(const Duration(hours: 5, minutes: 30))
              .toIso8601String();
      final String latitude = locationData?["latitude"] ?? "";
      final String longitude = locationData?["longitude"] ?? "";
      final String location = locationData?["location"] ?? "";

      String? formattedExpiry;
      if (expiryDate != null && expiryDate.isNotEmpty) {
        final clean = expiryDate.trim().replaceAll('/', '-');
        final parts = clean.split('-');
        if (parts.length == 2) {
          // Expected input: MM-YYYY or MM/YYYY -> convert to YYYY-MM-01
          formattedExpiry = "${parts[1]}-${parts[0]}-01";
        } else {
          formattedExpiry = expiryDate; // fallback
        }
      }

      final payload = {
        "referenceID": _currentReferenceId,
        "tempTransactionId":
            "", // Empty string for updates (matches Swagger format)
        "imageSlot": imageSlot,
        "documentType": documentType,
        "documentNumber": documentNumber,
        "expiryDate": formattedExpiry,
        "imageBase64": base64Image,
        "captureDate": captureDate,
        "latitude": latitude,
        "longitude": longitude,
        "location": location,
        "formType": "Standard",
      };

      // ── DEBUG: structured upload payload log (base64 truncated to length) ──
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════╗');
      debugPrint('║  [UPLOAD-IMAGE] Sending payload to backend       ║');
      debugPrint('╠══════════════════════════════════════════════════╣');
      debugPrint('║  URL         : POST /api/CustomerProfile/upload-image');
      debugPrint('║  referenceID : $_currentReferenceId');
      debugPrint('║  imageSlot   : $imageSlot');
      debugPrint('║  documentType: $documentType');
      debugPrint('║  documentNum : $documentNumber');
      debugPrint('║  expiryDate  : $formattedExpiry');
      debugPrint('║  captureDate : $captureDate');
      debugPrint('║  latitude    : $latitude');
      debugPrint('║  longitude   : $longitude');
      debugPrint('║  location    : $location');
      debugPrint('║  formType    : Standard');
      debugPrint(
        '║  imageBase64 : [data:image/jpeg;base64, + ${(imageBytes.length / 1024).toStringAsFixed(1)} KB raw data]',
      );
      debugPrint('╚══════════════════════════════════════════════════╝');
      // ────────────────────────────────────────────────────────────

      final response = await http.post(
        Uri.parse(
          'https://swiftkyc.avsinsotech.com/api/CustomerProfile/upload-image',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      // ── DEBUG: response log ──────────────────────────────────────
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════╗');
      debugPrint('║  [UPLOAD-IMAGE] Response — slot: $imageSlot');
      debugPrint('╠══════════════════════════════════════════════════╣');
      debugPrint('║  Status : ${response.statusCode}');
      debugPrint('║  Body   : ${response.body}');
      debugPrint('╚══════════════════════════════════════════════════╝');
      debugPrint('');
      // ────────────────────────────────────────────────────────────

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          '[UPLOAD-IMAGE] ❌ FAILED for $imageSlot — status: ${response.statusCode} — body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[UPLOAD-IMAGE] ❌ EXCEPTION for $imageSlot: $e');
      return false;
    }
  }

  Future<void> _pickSignature(ImageSource source) async {
    _pendingImageType = 'signature';
    await _saveFormStateToPrefs();
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Signature',
            toolbarColor: const Color(0xFF0F1E4A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Signature'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await File(croppedFile.path).readAsBytes();

        final locationData = await _getLocationData(context);
        if (locationData == null ||
            locationData.isEmpty ||
            locationData["latitude"] == null) {
          _showErrorPopup(
            "Location not captured. Please enable location services and try again.",
          );
          return;
        }

        if (!mounted) return;
        setState(() => _uploadingSlots.add('Signature'));
        final bool success = await _uploadImageInstantly(
          imageSlot: "SIGNATURE",
          documentType: "Signature",
          documentNumber: "",
          imageBytes: bytes,
          expiryDate: "",
          locationData: locationData,
        );
        if (mounted) setState(() => _uploadingSlots.remove('Signature'));

        if (success && mounted) {
          setState(() {
            _signatureFile = XFile(croppedFile.path);
          });
        } else if (mounted) {
          _showErrorPopup("Image upload failed. Please try again.");
        }
      }
    }
  }

  Future<Map<String, String>?> _getLocationData(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please turn on Location Services to capture an image.',
          ),
        ),
      );
      return null;
    }

    // 2. Check and request permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return null;
    }

    // 3. Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4. Convert coordinates to an address string
    String addressString = "Location unavailable";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        addressString =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} - ${place.postalCode}";
      }
    } catch (e) {
      debugPrint('Error getting placemark: $e');
    }

    // 5. Get current IST date (UTC+5:30)
    final String currentDate = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30))
        .toIso8601String();

    return {
      "latitude": position.latitude.toString(),
      "longitude": position.longitude.toString(),
      "location": addressString,
      "captureDate": currentDate,
    };
  }

  void _showSignatureOptions() {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),

      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),

                title: const Text('Capture from Camera'),

                onTap: () {
                  Navigator.pop(context);

                  _pickSignature(ImageSource.camera);
                },
              ),

              // ListTile(
              //   leading: const Icon(Icons.photo_library),

              //   title: const Text('Choose from Gallery'),

              //   onTap: () {
              //     Navigator.pop(context);

              //     _pickSignature(ImageSource.gallery);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  void _showDocImageOptions({
    required String title,
    required Function(XFile, Map<String, String>) onPicked,
    String imageType = 'doc',
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F1E4A),
                  ),
                ),
              ),
              const Divider(height: 1),

              //   ListTile(
              //     leading: const Icon(Icons.camera_alt, color: Color(0xFF0F1E4A)),
              //     title: const Text('Camera Capture'),
              //     onTap: () async {
              //       Navigator.pop(context);
              //       final picked = await _picker.pickImage(
              //         source: ImageSource.camera,
              //       );
              //       if (picked != null) onPicked(picked);
              //     },
              //   ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0F1E4A)),
                title: const Text('Camera Capture'),
                onTap: () async {
                  // 1. CONCURRENCY GUARD
                  if (_isOpeningCamera) return;

                  setState(() {
                    _isOpeningCamera = true;
                  });

                  try {
                    // 2. PERFORMANCE FIX: Close bottom sheet instantly
                    // Use the shadowed 'context' only for the pop action
                    Navigator.pop(context);

                    _pendingImageType = imageType;
                    await _saveFormStateToPrefs();
                    // 3. PERFORMANCE FIX: Open the camera FIRST
                    // final picked = await _picker.pickImage(
                    //   source: ImageSource.camera,
                    // );
                    final picked = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 50,
                      maxWidth: 1080,
                      maxHeight: 1080,
                    );

                    // 4. Fetch location AFTER the user takes the photo
                    if (picked != null && mounted) {
                      // Use 'this.context' (the screen's stable context) instead of the popped sheet's context
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Fetching location data...'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Use the screen's stable context again
                      final locationData = await _getLocationData(this.context);

                      // If location was successfully fetched, pass both back
                      if (locationData != null && mounted) {
                        onPicked(picked, locationData);
                      } else if (mounted) {
                        // ❗ Location fetch failed — show error and discard image
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to fetch location. Please enable GPS and try again.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  } finally {
                    // 5. Always unlock the button if the widget is still mounted
                    if (mounted) {
                      setState(() {
                        _isOpeningCamera = false;
                      });
                    }
                  }
                },
              ),
              // ListTile(
              //   leading: const Icon(
              //     Icons.photo_library,
              //     color: Color(0xFF0F1E4A),
              //   ),
              //   title: const Text('Upload from Device'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     final picked = await _picker.pickImage(
              //       source: ImageSource.gallery,
              //     );
              //     if (picked != null) onPicked(picked);
              //   },
              // ),
              // const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocUploadField({
    required String label,
    required XFile? file,
    required String bottomSheetTitle,
    required Function(XFile, Map<String, String>) onPicked,
    String imageType = 'doc',
    String? uploadSlotKey,
  }) {
    final bool isUploading =
        uploadSlotKey != null && _uploadingSlots.contains(uploadSlotKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isUploading
              ? null
              : () => _showDocImageOptions(
                  title: bottomSheetTitle,
                  onPicked: onPicked,
                  imageType: imageType,
                ),
          child: ImageUploadPreview(
            isUploading: isUploading,
            imageFile: file,
            emptyLabel: 'Tap to Capture or Upload\n$label',
          ),
        ),
      ],
    );
  }

  final TextEditingController _aadhaarController = TextEditingController();

  final TextEditingController _otpController = TextEditingController();

  // OTP States for specific verification chunks

  int _mobileOtpState = 0; // 0: initial, 1: sent, 2: verified
  int _mobileOtpTimerSeconds = 0;
  Timer? _mobileOtpTimer;

  void _startMobileOtpTimer() {
    _mobileOtpTimer?.cancel();
    setState(() {
      _mobileOtpTimerSeconds = 60;
    });
    _mobileOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_mobileOtpTimerSeconds > 0) {
        setState(() {
          _mobileOtpTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  final TextEditingController _mobileOtpController = TextEditingController();

  // Form Controllers

  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _nameMarathiController = TextEditingController();

  final TextEditingController _fatherHusbandNameController =
      TextEditingController();

  final TextEditingController _motherNameController = TextEditingController();

  final TextEditingController _dobController = TextEditingController();

  final TextEditingController _religionController = TextEditingController();

  // Address Controllers

  final TextEditingController _currentAddressController =
      TextEditingController();

  final TextEditingController _villageCityController = TextEditingController();

  final TextEditingController _talukaController = TextEditingController();

  final TextEditingController _districtController = TextEditingController();

  final TextEditingController _stateController = TextEditingController();

  final TextEditingController _pinCodeController = TextEditingController();

  final TextEditingController _countryController = TextEditingController(
    text: "India",
  );

  final TextEditingController _permanentAddressController =
      TextEditingController();

  final TextEditingController _permVillageCityController =
      TextEditingController();

  final TextEditingController _permTalukaController = TextEditingController();

  final TextEditingController _permDistrictController = TextEditingController();

  final TextEditingController _permStateController = TextEditingController();

  final TextEditingController _permPinCodeController = TextEditingController();

  final TextEditingController _permCountryController = TextEditingController(
    text: "India",
  );

  // KYC Controllers

  final TextEditingController _panNumberController = TextEditingController();

  final TextEditingController _aadhaarCkycController = TextEditingController();

  // Per-OVD slot controllers (up to 3 OVD documents)
  final List<TextEditingController> _ovdNumberControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _ovdExpiryControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  // Contact Controllers

  final TextEditingController _mobileNumberController = TextEditingController();

  final TextEditingController _alternateMobileController =
      TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  // Occupation & Income Controllers

  final TextEditingController _employerNameController = TextEditingController();

  final TextEditingController _designationController = TextEditingController();

  // Nominees List

  final List<NomineeEntry> _nominees = [NomineeEntry()];

  // Dropdown Values

  String? _selectedGender;

  String? _selectedMaritalStatus;

  String? _selectedNationality;

  String? _selectedResidentialStatus;

  String? _selectedCategory;

  String? _selectedPermanentAddressSame = "Same as Current";

  // Per-OVD slot type selections
  final List<String?> _ovdTypes = ["Aadhaar Card", null, null];
  int _ovdCount = 2; // minimum 2, max 3

  String? _selectedAddressProof = "Yes \u2014 OVD";

  String _form60Status = "N/A";

  // Occupation Dropdowns

  String? _selectedOccupation;

  String? _selectedAnnualIncome;

  String? _selectedSourceOfFunds;

  String? _selectedPep;

  String? _selectedRelatedPep;

  void _addNominee() {
    setState(() {
      _nominees.add(NomineeEntry());
    });
  }

  void _removeNominee(int index) {
    if (_nominees.length > 1) {
      setState(() {
        _nominees[index].dispose();

        _nominees.removeAt(index);
      });
    }
  }

  Future<void> _sendOtp() async {
    if (_aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 12-digit Aadhaar Number'),
        ),
      );

      return;
    }

    if (!mounted) return;
    setState(() => _isAadhaarLoading = true);

    try {
      // 1. Check if user already exists
      final checkResponse = await http.get(
        Uri.parse(
          'https://swiftkyc.avsinsotech.com/api/CustomerProfile/check-aadhar/${_aadhaarController.text}',
        ),
      );

      if (checkResponse.statusCode == 200) {
        final checkData = json.decode(checkResponse.body);
        if (checkData['exists'] == true) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Customer Exists'),
                content: const Text(
                  'User with that aadhar number already exists',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return; // Stop flow
        }
      }

      // 2. If not exists, send Aadhaar OTP
      final response = await http.post(
        Uri.parse('https://swiftkyc.avsinsotech.com/api/Auth/send-aadhar-otp'),

        headers: {'Content-Type': 'application/json'},

        body: json.encode({"aadharNo": _aadhaarController.text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _isOtpSent = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Sent to registered mobile number'),

            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${response.body}'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAadhaarLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );

      return;
    }

    if (!mounted) return;
    setState(() => _isAadhaarLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://swiftkyc.avsinsotech.com/api/Auth/verify-aadhar-otp',
        ),

        headers: {'Content-Type': 'application/json'},

        body: json.encode({
          "aadharNo": _aadhaarController.text,

          "otp": _otpController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respData = json.decode(response.body);

        final providerStr = respData['providerResponse'];

        if (providerStr != null) {
          final providerResponse = json.decode(providerStr);

          if (providerResponse['data'] != null) {
            final data = providerResponse['data'];

            if (data['full_name'] != null)
              _fullNameController.text = data['full_name'];

            if (data['dob'] != null) {
              try {
                final parts = data['dob'].toString().split('-');

                if (parts.length == 3) {
                  _dobController.text =
                      '${parts[2]} / ${parts[1]} / ${parts[0]}';
                } else
                  _dobController.text = data['dob'];
              } catch (_) {
                _dobController.text = data['dob'];
              }
            }

            if (data['gender'] != null) {
              final g = data['gender'].toString().toUpperCase();

              if (g == 'MALE' || g == 'M')
                _selectedGender = 'Male';
              else if (g == 'FEMALE' || g == 'F')
                _selectedGender = 'Female';
              else
                _selectedGender = 'Transgender';
            }

            if (data['address'] != null) {
              final addr = data['address'];

              String flatHouse = '';

              if (addr['house'] != null) flatHouse += addr['house'] + ' ';

              if (addr['street'] != null) flatHouse += addr['street'] + ' ';

              if (addr['landmark'] != null) flatHouse += addr['landmark'];

              _currentAddressController.text = flatHouse.trim();

              String vilCity = '';

              if (addr['vtc'] != null) vilCity += addr['vtc'] + ' ';

              if (addr['loc'] != null && vilCity.isEmpty)
                vilCity += addr['loc'] + ' ';

              if (addr['po'] != null && vilCity.isEmpty) vilCity += addr['po'];

              _villageCityController.text = vilCity.trim();

              if (addr['subdist'] != null)
                _talukaController.text = addr['subdist'];

              if (addr['dist'] != null) _districtController.text = addr['dist'];

              if (addr['state'] != null) _stateController.text = addr['state'];

              if (addr['country'] != null)
                _countryController.text = addr['country'];
            }

            if (data['zip'] != null) _pinCodeController.text = data['zip'];

            if (data['aadhaar_number'] != null) {
              final aNum = data['aadhaar_number'].toString();

              _aadhaarCkycController.text = aNum.length >= 4
                  ? 'XXXX XXXX ${aNum.substring(aNum.length - 4)}'
                  : aNum;
            }

            if (data['profile_image'] != null) {
              try {
                _profileImageBytes = base64Decode(data['profile_image']);
              } catch (_) {}
            }
          }
        }

        if (mounted) {
          setState(() {
            _isAadhaarVerified = true;
            // Auto-fill OVD number for any slot that has Aadhaar Card selected
            for (int i = 0; i < _ovdCount; i++) {
              if (_ovdTypes[i] == "Aadhaar Card") {
                _ovdNumberControllers[i].text = _aadhaarController.text;
              }
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aadhaar Verified. Data auto-filled successfully.'),

            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failed: ${response.body}'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAadhaarLoading = false);
    }
  }

  bool _isMobileOtpLoading = false;

  Future<void> _sendMobileOtp() async {
    if (_mobileNumberController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit Mobile Number'),
        ),
      );

      return;
    }

    if (!mounted) return;
    setState(() => _isMobileOtpLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://swiftkyc.avsinsotech.com/api/Auth/send-otp'),

        headers: {'Content-Type': 'application/json'},

        body: json.encode({"phoneNumber": _mobileNumberController.text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) setState(() => _mobileOtpState = 1);
        _startMobileOtpTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Sent to mobile number'),

            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${response.body}'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isMobileOtpLoading = false);
    }
  }

  Future<void> _verifyMobileOtp() async {
    if (_mobileOtpController.text.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a valid OTP')));

      return;
    }

    if (!mounted) return;
    setState(() => _isMobileOtpLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://swiftkyc.avsinsotech.com/api/Auth/verify-otp'),

        headers: {'Content-Type': 'application/json'},

        body: json.encode({
          "phoneNumber": _mobileNumberController.text,

          "otpCode": _mobileOtpController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) setState(() => _mobileOtpState = 2);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile Verified successfully.'),

            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failed: ${response.body}'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isMobileOtpLoading = false);
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();

    _otpController.dispose();

    _fullNameController.dispose();

    _nameMarathiController.dispose();

    _fatherHusbandNameController.dispose();

    _motherNameController.dispose();

    _dobController.dispose();

    _religionController.dispose();

    _currentAddressController.dispose();

    _villageCityController.dispose();

    _talukaController.dispose();

    _districtController.dispose();

    _stateController.dispose();

    _pinCodeController.dispose();

    _countryController.dispose();

    _permanentAddressController.dispose();

    _permVillageCityController.dispose();

    _permTalukaController.dispose();

    _permDistrictController.dispose();

    _permStateController.dispose();

    _permPinCodeController.dispose();

    _permCountryController.dispose();

    _panNumberController.dispose();

    _aadhaarCkycController.dispose();

    for (var c in _ovdNumberControllers) c.dispose();
    for (var c in _ovdExpiryControllers) c.dispose();

    _mobileNumberController.dispose();

    _alternateMobileController.dispose();

    _emailController.dispose();

    _employerNameController.dispose();

    _designationController.dispose();

    _mobileOtpTimer?.cancel();

    for (var nominee in _nominees) {
      nominee.dispose();
    }

    _scrollController.dispose();

    super.dispose();
  }

  // ─── PROCESS DEATH: Save form state before camera ───
  static const String _recoveryKey = '_formRecovery_updateCustomer';

  Future<void> _saveFormStateToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> state = {
      'pendingImageType': _pendingImageType,
      'currentFormStep': _currentFormStep,
      'isAadhaarVerified': _isAadhaarVerified,
      'isPanVerified': _isPanVerified,
      'mobileOtpState': _mobileOtpState,
      // Text controllers
      'aadhaar': _aadhaarController.text,
      'fullName': _fullNameController.text,
      'nameMarathi': _nameMarathiController.text,
      'fatherHusbandName': _fatherHusbandNameController.text,
      'motherName': _motherNameController.text,
      'dob': _dobController.text,
      'religion': _religionController.text,
      'currentAddress': _currentAddressController.text,
      'villageCity': _villageCityController.text,
      'taluka': _talukaController.text,
      'district': _districtController.text,
      'state': _stateController.text,
      'pinCode': _pinCodeController.text,
      'country': _countryController.text,
      'permanentAddress': _permanentAddressController.text,
      'permVillageCity': _permVillageCityController.text,
      'permTaluka': _permTalukaController.text,
      'permDistrict': _permDistrictController.text,
      'permState': _permStateController.text,
      'permPinCode': _permPinCodeController.text,
      'permCountry': _permCountryController.text,
      'panNumber': _panNumberController.text,
      'aadhaarCkyc': _aadhaarCkycController.text,
      'mobileNumber': _mobileNumberController.text,
      'alternateMobile': _alternateMobileController.text,
      'email': _emailController.text,
      'employerName': _employerNameController.text,
      'designation': _designationController.text,
      // OVD controllers
      'ovdNumber0': _ovdNumberControllers[0].text,
      'ovdNumber1': _ovdNumberControllers[1].text,
      'ovdNumber2': _ovdNumberControllers[2].text,
      'ovdExpiry0': _ovdExpiryControllers[0].text,
      'ovdExpiry1': _ovdExpiryControllers[1].text,
      'ovdExpiry2': _ovdExpiryControllers[2].text,
      // Dropdowns
      'selectedGender': _selectedGender,
      'selectedMaritalStatus': _selectedMaritalStatus,
      'selectedNationality': _selectedNationality,
      'selectedResidentialStatus': _selectedResidentialStatus,
      'selectedCategory': _selectedCategory,
      'selectedPermanentAddressSame': _selectedPermanentAddressSame,
      'selectedAddressProof': _selectedAddressProof,
      'form60Status': _form60Status,
      'selectedOccupation': _selectedOccupation,
      'selectedAnnualIncome': _selectedAnnualIncome,
      'selectedSourceOfFunds': _selectedSourceOfFunds,
      'selectedPep': _selectedPep,
      'selectedRelatedPep': _selectedRelatedPep,
      // OVD config
      'ovdCount': _ovdCount,
      'ovdType0': _ovdTypes[0],
      'ovdType1': _ovdTypes[1],
      'ovdType2': _ovdTypes[2],
      // Nominees
      'nomineeCount': _nominees.length,
      for (int i = 0; i < _nominees.length; i++) ...{
        'nominee_${i}_fullName': _nominees[i].fullNameController.text,
        'nominee_${i}_relationship': _nominees[i].selectedRelationship,
        'nominee_${i}_otherRelationship':
            _nominees[i].otherRelationshipController.text,
        'nominee_${i}_dob': _nominees[i].dobController.text,
        'nominee_${i}_age': _nominees[i].ageController.text,
        'nominee_${i}_share': _nominees[i].shareController.text,
        'nominee_${i}_guardianAddress':
            _nominees[i].guardianAddressController.text,
      },
    };
    await prefs.setString(_recoveryKey, json.encode(state));
  }

  void _restoreFormStateFromPrefs(Map<String, dynamic> state) {
    _currentFormStep = state['currentFormStep'] ?? 0;
    _isAadhaarVerified = state['isAadhaarVerified'] ?? false;
    _isPanVerified = state['isPanVerified'] ?? false;
    _mobileOtpState = state['mobileOtpState'] ?? 0;

    _aadhaarController.text = state['aadhaar'] ?? '';
    _fullNameController.text = state['fullName'] ?? '';
    _nameMarathiController.text = state['nameMarathi'] ?? '';
    _fatherHusbandNameController.text = state['fatherHusbandName'] ?? '';
    _motherNameController.text = state['motherName'] ?? '';
    _dobController.text = state['dob'] ?? '';
    _religionController.text = state['religion'] ?? '';
    _currentAddressController.text = state['currentAddress'] ?? '';
    _villageCityController.text = state['villageCity'] ?? '';
    _talukaController.text = state['taluka'] ?? '';
    _districtController.text = state['district'] ?? '';
    _stateController.text = state['state'] ?? '';
    _pinCodeController.text = state['pinCode'] ?? '';
    _countryController.text = state['country'] ?? '';
    _permanentAddressController.text = state['permanentAddress'] ?? '';
    _permVillageCityController.text = state['permVillageCity'] ?? '';
    _permTalukaController.text = state['permTaluka'] ?? '';
    _permDistrictController.text = state['permDistrict'] ?? '';
    _permStateController.text = state['permState'] ?? '';
    _permPinCodeController.text = state['permPinCode'] ?? '';
    _permCountryController.text = state['permCountry'] ?? '';
    _panNumberController.text = state['panNumber'] ?? '';
    _aadhaarCkycController.text = state['aadhaarCkyc'] ?? '';
    _mobileNumberController.text = state['mobileNumber'] ?? '';
    _alternateMobileController.text = state['alternateMobile'] ?? '';
    _emailController.text = state['email'] ?? '';
    _employerNameController.text = state['employerName'] ?? '';
    _designationController.text = state['designation'] ?? '';

    _ovdNumberControllers[0].text = state['ovdNumber0'] ?? '';
    _ovdNumberControllers[1].text = state['ovdNumber1'] ?? '';
    _ovdNumberControllers[2].text = state['ovdNumber2'] ?? '';
    _ovdExpiryControllers[0].text = state['ovdExpiry0'] ?? '';
    _ovdExpiryControllers[1].text = state['ovdExpiry1'] ?? '';
    _ovdExpiryControllers[2].text = state['ovdExpiry2'] ?? '';

    _selectedGender = state['selectedGender'];
    _selectedMaritalStatus = state['selectedMaritalStatus'];
    _selectedNationality = state['selectedNationality'];
    _selectedResidentialStatus = state['selectedResidentialStatus'];
    _selectedCategory = state['selectedCategory'];
    _selectedPermanentAddressSame =
        state['selectedPermanentAddressSame'] ?? 'Same as Current';
    _selectedAddressProof = state['selectedAddressProof'] ?? 'Yes \u2014 OVD';
    _form60Status = state['form60Status'] ?? 'N/A';
    _selectedOccupation = state['selectedOccupation'];
    _selectedAnnualIncome = state['selectedAnnualIncome'];
    _selectedSourceOfFunds = state['selectedSourceOfFunds'];
    _selectedPep = state['selectedPep'];
    _selectedRelatedPep = state['selectedRelatedPep'];

    _ovdCount = state['ovdCount'] ?? 2;
    _ovdTypes[0] = state['ovdType0'] ?? 'Aadhaar Card';
    _ovdTypes[1] = state['ovdType1'];
    _ovdTypes[2] = state['ovdType2'];

    // Restore nominees
    final int nomCount = state['nomineeCount'] ?? 1;
    _nominees.clear();
    for (int i = 0; i < nomCount; i++) {
      final n = NomineeEntry();
      n.fullNameController.text = state['nominee_${i}_fullName'] ?? '';
      n.selectedRelationship = state['nominee_${i}_relationship'];
      n.otherRelationshipController.text =
          state['nominee_${i}_otherRelationship'] ?? '';
      n.dobController.text = state['nominee_${i}_dob'] ?? '';
      n.ageController.text = state['nominee_${i}_age'] ?? '';
      n.shareController.text = state['nominee_${i}_share'] ?? '';
      n.guardianAddressController.text =
          state['nominee_${i}_guardianAddress'] ?? '';
      _nominees.add(n);
    }
    if (_nominees.isEmpty) _nominees.add(NomineeEntry());
  }

  Future<void> _clearFormRecoveryPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recoveryKey);
  }

  // ─── PROCESS DEATH: Recover image lost during camera session ───
  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty || response.file == null) {
        // No lost data — clear any stale recovery state
        await _clearFormRecoveryPrefs();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_recoveryKey);
      if (stateJson == null) return;

      final Map<String, dynamic> state = json.decode(stateJson);
      final String? imageType = state['pendingImageType'];

      // Restore all form fields
      _restoreFormStateFromPrefs(state);

      // Read recovered image bytes
      final recoveredFile = response.file!;
      final bytes = await File(recoveredFile.path).readAsBytes();

      // Assign the recovered image to the correct slot
      switch (imageType) {
        case 'photo':
          _photoFile = recoveredFile;
          _photoBytes = bytes;
          _profileImageBytes = null;
          break;
        case 'signature':
          _signatureFile = recoveredFile;
          _signatureBytes = bytes;
          break;
        case 'ovd_0':
          _ovdImageFiles[0] = recoveredFile;
          _ovdImageBytesCache[0] = bytes;
          break;
        case 'ovd_1':
          _ovdImageFiles[1] = recoveredFile;
          _ovdImageBytesCache[1] = bytes;
          break;
        case 'ovd_2':
          _ovdImageFiles[2] = recoveredFile;
          _ovdImageBytesCache[2] = bytes;
          break;
        case 'form60':
          _form60File = recoveredFile;
          _form60Bytes = bytes;
          break;
        case 'aadhaar_back':
          _aadhaarBackFile = recoveredFile;
          _aadhaarBackBytesCache = bytes;
          break;
      }

      await _clearFormRecoveryPrefs();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form restored after camera session'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('retrieveLostData error: $e');
      await _clearFormRecoveryPrefs();
    }
  }

  // ─── OOM FIX: Flush all image memory after successful submission ───
  void _flushMemory() {
    _photoFile = null;
    _photoBytes = null;
    _signatureFile = null;
    _signatureBytes = null;
    _form60File = null;
    _form60Bytes = null;
    _profileImageBytes = null;
    _aadhaarBackFile = null;
    _aadhaarBackBytesCache = null;
    for (int i = 0; i < 3; i++) {
      _ovdImageFiles[i] = null;
      _ovdImageBytesCache[i] = null;
      _ovdLocationData[i] = null;
    }
    _aadhaarBackLocationData = null;

    // Clear Flutter's image cache to release decoded image memory
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  Widget _buildCustomTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    bool isVerified = false,
    bool readOnly = false,
    bool forceEditable = false,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
  }) {
    // Define the base border style to keep the code clean and reusable
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isVerified ? Colors.green : Colors.grey.shade300,
        width: 1.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Label Section ---
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' \u2605',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        // --- TextField Section ---
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            readOnly: forceEditable ? readOnly : (readOnly || isVerified),
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onChanged: onChanged,

            // All background, border, and sizing logic is now handled natively here
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),

              // Background color logic
              filled: true,
              fillColor: isVerified ? const Color(0xFFE8F5E9) : Colors.white,

              // Padding and alignment
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              // Border logic
              border: baseBorder,
              enabledBorder: baseBorder,
              disabledBorder: baseBorder,

              // Slightly thicker/different colored border when the user taps the field
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isVerified
                      ? Colors.green
                      : Colors
                            .blue, // Update Colors.blue to your app's primary color if needed
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        RichText(
          text: TextSpan(
            text: 'GENDER',
            style: const TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.bold,

              color: Colors.grey,
            ),
            children: const [
              TextSpan(
                text: ' \u2605',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = "Male"),

                child: Container(
                  height: 48,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: _selectedGender == "Male"
                        ? AppColors.darkNavy
                        : Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: _selectedGender == "Male"
                          ? AppColors.darkNavy
                          : Colors.grey.shade300,
                    ),
                  ),

                  child: Text(
                    "Male",

                    style: TextStyle(
                      color: _selectedGender == "Male"
                          ? Colors.white
                          : Colors.black87,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = "Female"),

                child: Container(
                  height: 48,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: _selectedGender == "Female"
                        ? AppColors.darkNavy
                        : Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: _selectedGender == "Female"
                          ? AppColors.darkNavy
                          : Colors.grey.shade300,
                    ),
                  ),

                  child: Text(
                    "Female",

                    style: TextStyle(
                      color: _selectedGender == "Female"
                          ? Colors.white
                          : Colors.black87,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = "Transgender"),

                child: Container(
                  height: 48,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: _selectedGender == "Transgender"
                        ? AppColors.darkNavy
                        : Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: _selectedGender == "Transgender"
                          ? AppColors.darkNavy
                          : Colors.grey.shade300,
                    ),
                  ),

                  child: Text(
                    "Transgender",

                    style: TextStyle(
                      color: _selectedGender == "Transgender"
                          ? Colors.white
                          : Colors.black87,

                      fontWeight: FontWeight.bold,

                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomDropdown(
    String label,

    List<String> items,

    String? selectedValue,

    ValueChanged<String?> onChanged, {

    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' \u2605',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Container(
          height: 48,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade300),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,

              isExpanded: true,

              icon: const Padding(
                padding: EdgeInsets.only(right: 12.0),

                child: Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),

              onChanged: onChanged,

              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),

                    child: Text(
                      item,

                      style: const TextStyle(
                        fontSize: 14,

                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Personal Details",

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w900,

            fontFamily: 'Serif',

            color: AppColors.darkNavy,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "SECTION B \u2014 CKYC MANDATORY FIELDS",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: Column(
                children: [
                  _buildCustomTextField(
                    "FULL NAME (AS PER AADHAAR)",

                    _fullNameController,

                    isRequired: true,

                    isVerified: true,
                  ),

                  const SizedBox(height: 16),

                  _buildCustomTextField(
                    "NAME IN MARATHI",

                    _nameMarathiController,

                    isRequired: false,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Upload Person Photo',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF0F1E4A),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF0F1E4A),
                            ),
                            title: const Text('Camera Capture'),
                            onTap: () async {
                              Navigator.pop(ctx);
                              _pendingImageType = 'photo';
                              await _saveFormStateToPrefs();
                              // final picked = await _picker.pickImage(
                              //   source: ImageSource.camera,
                              // );
                              final picked = await _picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 50,
                                maxWidth: 1080,
                                maxHeight: 1080,
                              );
                              if (picked != null) {
                                final CroppedFile? croppedFile =
                                    await ImageCropper().cropImage(
                                      sourcePath: picked.path,
                                      uiSettings: [
                                        AndroidUiSettings(
                                          toolbarTitle: 'Crop Photo',
                                          toolbarColor: const Color(0xFF0F1E4A),
                                          toolbarWidgetColor: Colors.white,
                                          initAspectRatio:
                                              CropAspectRatioPreset.original,
                                          lockAspectRatio: false,
                                        ),
                                        IOSUiSettings(title: 'Crop Photo'),
                                      ],
                                    );
                                if (croppedFile == null || !mounted) return;

                                final bytes = await File(
                                  croppedFile.path,
                                ).readAsBytes();

                                if (!mounted) return;
                                // Show spinner immediately (location + upload both take time)
                                setState(() => _uploadingSlots.add('PHOTO'));

                                final locationData = await _getLocationData(
                                  context,
                                );
                                if (locationData == null ||
                                    locationData.isEmpty ||
                                    locationData["latitude"] == null) {
                                  if (mounted)
                                    setState(
                                      () => _uploadingSlots.remove('PHOTO'),
                                    );
                                  _showErrorPopup(
                                    "Location not captured. Please enable location services and try again.",
                                  );
                                  return;
                                }

                                final bool success =
                                    await _uploadImageInstantly(
                                      imageSlot: "PHOTO",
                                      documentType: "Profile Photo",
                                      documentNumber: "",
                                      imageBytes: bytes,
                                      expiryDate: "",
                                      locationData: locationData,
                                    );
                                if (mounted)
                                  setState(
                                    () => _uploadingSlots.remove('PHOTO'),
                                  );

                                if (success && mounted) {
                                  setState(() {
                                    _photoFile = XFile(croppedFile.path);
                                    _photoBytes =
                                        bytes; // ← cache so preview renders
                                    _profileImageBytes =
                                        null; // ← clear Aadhaar photo
                                  });
                                } else if (mounted) {
                                  _showErrorPopup(
                                    "Image upload failed. Please try again.",
                                  );
                                }
                              }
                            },
                          ),
                          // ListTile(
                          //   leading: const Icon(
                          //     Icons.photo_library,
                          //     color: Color(0xFF0F1E4A),
                          //   ),
                          //   title: const Text('Upload from Device'),
                          //   onTap: () async {
                          //     Navigator.pop(ctx);
                          //     _pendingImageType = 'photo';
                          //     await _saveFormStateToPrefs();
                          //     // final picked = await _picker.pickImage(
                          //     //   source: ImageSource.gallery,
                          //     // );
                          //     final picked = await _picker.pickImage(
                          //       source: ImageSource.gallery,
                          //       imageQuality: 50,
                          //       maxWidth: 1080,
                          //       maxHeight: 1080,
                          //     );
                          //     if (picked != null) {
                          //       final CroppedFile? croppedFile =
                          //           await ImageCropper().cropImage(
                          //             sourcePath: picked.path,
                          //             uiSettings: [
                          //               AndroidUiSettings(
                          //                 toolbarTitle: 'Crop Photo',
                          //                 toolbarColor: const Color(0xFF0F1E4A),
                          //                 toolbarWidgetColor: Colors.white,
                          //                 initAspectRatio:
                          //                     CropAspectRatioPreset.original,
                          //                 lockAspectRatio: false,
                          //               ),
                          //               IOSUiSettings(title: 'Crop Photo'),
                          //             ],
                          //           );
                          //       if (croppedFile == null || !mounted) return;

                          //       final bytes = await File(
                          //         croppedFile.path,
                          //       ).readAsBytes();

                          //       if (!mounted) return;
                          //       final locationData = await _getLocationData(
                          //         context,
                          //       );
                          //       if (locationData == null ||
                          //           locationData.isEmpty ||
                          //           locationData["latitude"] == null) {
                          //         _showErrorPopup(
                          //           "Location not captured. Please enable location services and try again.",
                          //         );
                          //         return;
                          //       }

                          //       final bool success =
                          //           await _uploadImageInstantly(
                          //             imageSlot: "Profile",
                          //             documentType: "Profile Photo",
                          //             documentNumber: "",
                          //             imageBytes: bytes,
                          //             expiryDate: "",
                          //             locationData: locationData,
                          //           );

                          //       if (success && mounted) {
                          //         setState(() {
                          //           _photoFile = XFile(croppedFile.path);
                          //           _profileImageBytes = null;
                          //         });
                          //       } else if (mounted) {
                          //         _showErrorPopup(
                          //           "Image upload failed. Please try again.",
                          //         );
                          //       }
                          //     }
                          //   },
                          // ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },

              child: _uploadingSlots.contains('PHOTO')
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: const Color(0xFF1A6B5A),
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Uploading…',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _profileImageBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _profileImageBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImagePreviewScreen(
                                    imageBytes: _profileImageBytes,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _photoBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _photoBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImagePreviewScreen(
                                    imageBytes: _photoBytes,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _photoFile != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_photoFile!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ImagePreviewScreen(imageFile: _photoFile),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : CustomPaint(
                      painter: DottedBorderPainter(
                        color: Colors.grey.shade400,
                        strokeWidth: 1.5,
                        gap: 6.0,
                      ),
                      child: Container(
                        height: 100,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Photo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "Tap to add",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildCustomTextField(
          "FATHER'S / HUSBAND'S NAME",

          _fatherHusbandNameController,

          isRequired: true,

          hint: "Enter Name",
        ),

        const SizedBox(height: 16),

        _buildCustomTextField(
          "MOTHER'S NAME",

          _motherNameController,

          isRequired: false,

          hint: "Optional",
        ),

        const SizedBox(height: 16),

        _buildCustomTextField(
          "DATE OF BIRTH",

          _dobController,

          isRequired: true,

          hint: "DD/MM/YYYY",

          readOnly: _isAadhaarVerified && _dobController.text.isNotEmpty,

          inputFormatters: [DateInputFormatter()],

          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        _buildGenderSelection(),

        const SizedBox(height: 16),

        _buildCustomDropdown(
          "MARITAL STATUS",

          ["Single", "Married", "Widowed", "Divorced"],

          _selectedMaritalStatus,

          (val) => setState(() => _selectedMaritalStatus = val),

          isRequired: true,
        ),

        const SizedBox(height: 16),

        _buildCustomDropdown(
          "NATIONALITY",

          ["Indian", "NRI", "Other"],

          _selectedNationality,

          (val) => setState(() => _selectedNationality = val),

          isRequired: true,
        ),

        const SizedBox(height: 16),

        _buildCustomDropdown(
          "RESIDENTIAL STATUS",

          ["Resident", "Non-Resident"],

          _selectedResidentialStatus,

          (val) => setState(() => _selectedResidentialStatus = val),

          isRequired: false,
        ),

        const SizedBox(height: 16),

        _buildCustomDropdown(
          "RELIGION",

          [
            "Hinduism",
            "Islam",
            "Christianity",
            "Sikhism",
            "Buddhism",
            "Jainism",
            "Zoroastrianism (Parsi)",
            "Bahá'í Faith",
            "Judaism",
            "Tribal / Indigenous Religions",
          ],

          _religionController.text.isEmpty ? null : _religionController.text,

          (val) => setState(() => _religionController.text = val ?? ''),

          isRequired: false,
        ),

        const SizedBox(height: 16),

        _buildCustomDropdown(
          "CATEGORY",

          ["GEN", "SC", "ST", "OBC", "NT"],

          _selectedCategory,

          (val) => setState(() => _selectedCategory = val),

          isRequired: false,
        ),

        const SizedBox(height: 16),

        _buildSignatureUploadField(),
      ],
    );
  }

  Widget _buildSignatureUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        RichText(
          text: const TextSpan(
            text: "SIGNATURE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
            children: [
              TextSpan(
                text: ' \u2605',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        GestureDetector(
          onTap: _showSignatureOptions,

          child: Container(
            height: 120,

            width: double.infinity,

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(12),

              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),

            child: _signatureFile != null
                ? Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),

                          child: Image.file(
                            File(_signatureFile!.path),

                            fit: BoxFit.contain,

                            width: double.infinity,

                            height: double.infinity,
                            cacheWidth:
                                800, // Keeps the document preview memory extremely low
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewScreen(
                                      imageFile: _signatureFile,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showSignatureOptions,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.draw,

                        color: AppColors.darkNavy,

                        size: 36,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Tap to Capture or Upload Signature\n(Crop for better adjustment)",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.grey.shade600,

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoToggle() {
    bool isSame =
        _selectedPermanentAddressSame == "Same as Current" ||
        _selectedPermanentAddressSame == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "SAME AS CURRENT?",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(
                  () => _selectedPermanentAddressSame = "Same as Current",
                ),

                child: Container(
                  height: 48,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: isSame ? AppColors.darkNavy : Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: isSame ? AppColors.darkNavy : Colors.grey.shade300,
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      if (isSame)
                        const Icon(Icons.check, color: Colors.white, size: 16),

                      if (isSame) const SizedBox(width: 4),

                      Text(
                        "Yes, Same",

                        style: TextStyle(
                          color: isSame ? Colors.white : Colors.black87,

                          fontWeight: FontWeight.bold,

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedPermanentAddressSame = "Different"),

                child: Container(
                  height: 48,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Text(
                    "Different",

                    style: TextStyle(
                      color: !isSame
                          ? AppColors.darkNavy
                          : Colors.grey.shade600,

                      fontWeight: !isSame ? FontWeight.bold : FontWeight.normal,

                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressDetails() {
    bool isSame =
        _selectedPermanentAddressSame == "Same as Current" ||
        _selectedPermanentAddressSame == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Address Details",

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w900,

            fontFamily: 'Serif',

            color: AppColors.darkNavy,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "SECTION D \u2014 CURRENT & PERMANENT ADDRESS",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // Current Address Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.push_pin, color: Colors.pinkAccent, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Current / Correspondence Address",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              _buildCustomTextField(
                "FLAT / HOUSE NO., BUILDING",

                _currentAddressController,

                readOnly:
                    _isAadhaarVerified &&
                    _currentAddressController.text.isNotEmpty,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      "VILLAGE / CITY",

                      _villageCityController,

                      isRequired: true,

                      isVerified: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _villageCityController.text.isNotEmpty,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildCustomTextField(
                      "TALUKA",

                      _talukaController,

                      isRequired: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _talukaController.text.isNotEmpty,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      "DISTRICT",

                      _districtController,

                      isRequired: true,

                      isVerified: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _districtController.text.isNotEmpty,

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],

                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildCustomTextField(
                      "STATE",

                      _stateController,

                      isRequired: true,

                      isVerified: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _stateController.text.isNotEmpty,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      "PIN CODE",

                      _pinCodeController,

                      isRequired: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _pinCodeController.text.isNotEmpty,

                      keyboardType: TextInputType.number,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,

                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildCustomTextField(
                      "COUNTRY",

                      _countryController,

                      isVerified: true,

                      readOnly:
                          _isAadhaarVerified &&
                          _countryController.text.isNotEmpty,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Permanent Address Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.home, color: Colors.deepOrangeAccent, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Permanent Address",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              _buildYesNoToggle(),

              const SizedBox(height: 16),

              if (isSame)
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.transparent),
                  ),

                  child: Text(
                    "Permanent address auto-filled from current address",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey.shade500,

                      fontSize: 13,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else ...[
                _buildCustomTextField(
                  "FLAT / HOUSE NO., BUILDING",

                  _permanentAddressController,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        "VILLAGE / CITY",

                        _permVillageCityController,

                        isRequired: true,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _buildCustomTextField(
                        "TALUKA",

                        _permTalukaController,

                        isRequired: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        "DISTRICT",

                        _permDistrictController,

                        isRequired: true,

                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],

                        textCapitalization: TextCapitalization.words,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _buildCustomTextField(
                        "STATE",

                        _permStateController,

                        isRequired: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        "PIN CODE",

                        _permPinCodeController,

                        isRequired: true,

                        keyboardType: TextInputType.number,

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,

                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _buildCustomTextField(
                        "COUNTRY",

                        _permCountryController,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xFFF6F3E6),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Icon(Icons.push_pin, color: Colors.redAccent, size: 18),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "Address is auto-fetched from your Aadhaar via DigiLocker. Tap to verify.",

                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKycDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "KYC Documents",

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w900,

            fontFamily: 'Serif',

            color: AppColors.darkNavy,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "SECTION C \u2014 IDENTITY VERIFICATION (OVD)",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // PAN Card Container
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.blueAccent, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "PAN Number",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      "",

                      _panNumberController,

                      hint: "Enter PAN Number",

                      isVerified: _isPanVerified,

                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(10),
                      ],

                      textCapitalization: TextCapitalization.characters,

                      keyboardType: TextInputType.text,
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    height: 48,

                    child: ElevatedButton(
                      onPressed: (_isPanVerified || _isPanLoading)
                          ? null
                          : () async {
                              if (_panNumberController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enter PAN Number'),
                                  ),
                                );

                                return;
                              }

                              setState(() => _isPanLoading = true);

                              final result = await _panService.verifyPan(
                                _panNumberController.text.trim(),
                              );

                              if (mounted) {
                                setState(() => _isPanLoading = false);

                                if (result.success) {
                                  bool nameMatch = false;

                                  if (result.fullName != null &&
                                      _fullNameController.text.isNotEmpty) {
                                    final String aadhaarName =
                                        _fullNameController.text
                                            .toLowerCase()
                                            .replaceAll(RegExp(r'\s+'), '');

                                    final String panName = result.fullName!
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'\s+'), '');

                                    nameMatch = (aadhaarName == panName);
                                  }

                                  if (nameMatch) {
                                    setState(() {
                                      _isPanVerified = true;
                                      // Auto-fill OVD number for any slot that has PAN Card selected
                                      for (int i = 0; i < _ovdCount; i++) {
                                        if (_ovdTypes[i] == "PAN Card") {
                                          _ovdNumberControllers[i].text =
                                              _panNumberController.text;
                                        }
                                      }
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Pan verification Successfull',
                                        ),

                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Name mismatch between PAN and Aadhaar.',
                                        ),

                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pan verification failed'),

                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPanVerified
                            ? Colors.green
                            : AppColors.darkNavy,

                        disabledBackgroundColor: _isPanVerified
                            ? Colors.green.shade300
                            : Colors.grey.shade300,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: _isPanLoading
                          ? const SizedBox(
                              width: 20,

                              height: 20,

                              child: CircularProgressIndicator(
                                color: Colors.white,

                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                if (_isPanVerified)
                                  const Icon(
                                    Icons.check,

                                    color: Colors.white,

                                    size: 16,
                                  ),

                                if (_isPanVerified) const SizedBox(width: 4),

                                Text(
                                  _isPanVerified ? "Verified" : "Verify",

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text(
                    "Form 60 / 61: ",

                    style: TextStyle(
                      color: Colors.grey,

                      fontSize: 13,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () => setState(() => _form60Status = "Submitted"),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,

                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: _form60Status == "Submitted"
                            ? AppColors.darkNavy
                            : Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: _form60Status == "Submitted"
                              ? AppColors.darkNavy
                              : Colors.grey.shade300,
                        ),
                      ),

                      child: Text(
                        "Yes",

                        style: TextStyle(
                          color: _form60Status == "Submitted"
                              ? Colors.white
                              : Colors.black87,

                          fontWeight: FontWeight.bold,

                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () => setState(() => _form60Status = "N/A"),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,

                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: _form60Status == "N/A"
                            ? AppColors.darkNavy
                            : Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: _form60Status == "N/A"
                              ? AppColors.darkNavy
                              : Colors.grey.shade300,
                        ),
                      ),

                      child: Text(
                        "N/A",

                        style: TextStyle(
                          color: _form60Status == "N/A"
                              ? Colors.white
                              : Colors.black87,

                          fontWeight: FontWeight.bold,

                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_form60Status == "Submitted") ...[
                const SizedBox(height: 16),

                _buildDocUploadField(
                  label: "FORM 60 / 61",
                  file: _form60File,
                  bottomSheetTitle: "Upload Form 60 / 61",
                  imageType: 'form60',
                  uploadSlotKey: 'Form60_61',
                  onPicked: (picked, locData) async {
                    if (locData.isEmpty || locData["latitude"] == null) {
                      _showErrorPopup(
                        "Location not captured. Please enable location services and try again.",
                      );
                      return;
                    }

                    // ✅ Read bytes NOW so temp-file cleanup won't lose them
                    final bytes = await File(picked.path).readAsBytes();

                    setState(() => _uploadingSlots.add('Form60_61'));
                    final bool success = await _uploadImageInstantly(
                      imageSlot: "FORM60",
                      documentType: "Form 60/61",
                      documentNumber: "",
                      imageBytes: bytes,
                      expiryDate: "",
                      locationData: locData,
                    );
                    if (mounted)
                      setState(() => _uploadingSlots.remove('Form60_61'));

                    if (success && mounted) {
                      setState(() {
                        _form60File = picked;
                      });
                    } else if (mounted) {
                      _showErrorPopup("Image upload failed. Please try again.");
                    }
                  },
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Aadhaar Card Container
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.assignment_ind, color: Colors.brown, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Aadhaar Number",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              _buildCustomTextField(
                "",

                _aadhaarCkycController,

                hint: "Enter Aadhaar Number",

                readOnly: true,
              ),

              const SizedBox(height: 8),

              const Text(
                "Last 4 digits used for CKYC verification",

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // OVD Documents — Per-slot cards
        IgnorePointer(
          ignoring: !(_isPanVerified || _form60Status == "Submitted"),
          child: Opacity(
            opacity: (_isPanVerified || _form60Status == "Submitted")
                ? 1.0
                : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int slotIdx = 0; slotIdx < _ovdCount; slotIdx++) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_open,
                              color: Colors.orangeAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: "OVD Document ${slotIdx + 1}",
                                  style: const TextStyle(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  children: [
                                    if (slotIdx < 2)
                                      const TextSpan(
                                        text: ' ★',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    if (slotIdx >= 2)
                                      const TextSpan(
                                        text: ' (Optional)',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (slotIdx >= 2)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _ovdTypes[slotIdx] = null;
                                    _ovdNumberControllers[slotIdx].clear();
                                    _ovdExpiryControllers[slotIdx].clear();
                                    _ovdImageFiles[slotIdx] = null;
                                    _ovdImageBytesCache[slotIdx] = null;
                                    _ovdLocationData[slotIdx] = null;
                                    _ovdCount = 2;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.grey, thickness: 0.3),
                        ),

                        // Document type dropdown
                        const Text(
                          "DOCUMENT TYPE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _ovdTypes[slotIdx],
                              isExpanded: true,
                              hint: const Text("Select Document"),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              items:
                                  [
                                    "Aadhaar Card",
                                    "PAN Card",
                                    "Passport",
                                    "Voter ID",
                                    "Driving Licence",
                                    "NREGA Job Card",
                                  ].map((type) {
                                    // Check if this type is already used in another slot
                                    bool isUsedElsewhere = false;
                                    for (int j = 0; j < _ovdCount; j++) {
                                      if (j != slotIdx &&
                                          _ovdTypes[j] == type) {
                                        isUsedElsewhere = true;
                                        break;
                                      }
                                    }

                                    // Disable PAN Card if Form 60 is submitted
                                    if (type == "PAN Card" &&
                                        _form60Status == "Submitted") {
                                      isUsedElsewhere = true;
                                    }
                                    return DropdownMenuItem(
                                      value: type,
                                      enabled: !isUsedElsewhere,
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: isUsedElsewhere
                                              ? Colors.grey.shade400
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  final oldVal = _ovdTypes[slotIdx];
                                  _ovdTypes[slotIdx] = val;
                                  // Auto-fill number
                                  if (val == "Aadhaar Card" &&
                                      _aadhaarController.text.isNotEmpty) {
                                    _ovdNumberControllers[slotIdx].text =
                                        _aadhaarController.text;
                                  } else if (val == "PAN Card" &&
                                      _panNumberController.text.isNotEmpty) {
                                    _ovdNumberControllers[slotIdx].text =
                                        _panNumberController.text;
                                  } else {
                                    _ovdNumberControllers[slotIdx].clear();
                                  }
                                  // Clear expiry for non-expiry types
                                  const noExpiry = [
                                    'Aadhaar Card',
                                    'PAN Card',
                                    'Voter ID',
                                  ];
                                  if (val != null && noExpiry.contains(val)) {
                                    _ovdExpiryControllers[slotIdx].clear();
                                  }
                                  // Clear Aadhaar back photo if no slot has Aadhaar
                                  if (oldVal == "Aadhaar Card" &&
                                      val != "Aadhaar Card") {
                                    final bool anyAadhaar = _ovdTypes.any(
                                      (t) => t == "Aadhaar Card",
                                    );
                                    if (!anyAadhaar) {
                                      _aadhaarBackFile = null;
                                      _aadhaarBackBytesCache = null;
                                      _aadhaarBackLocationData = null;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // OVD Number + Expiry row
                        Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final type = _ovdTypes[slotIdx];
                                  List<TextInputFormatter> formatters = [];
                                  if (type == 'Aadhaar Card') {
                                    formatters = [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(12),
                                    ];
                                  } else if (type == 'PAN Card') {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                      LengthLimitingTextInputFormatter(10),
                                    ];
                                  } else if (type == 'Voter ID') {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                      LengthLimitingTextInputFormatter(10),
                                    ];
                                  } else if (type == 'Passport') {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                      LengthLimitingTextInputFormatter(15),
                                    ];
                                  } else if (type == 'Driving Licence') {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                      LengthLimitingTextInputFormatter(16),
                                    ];
                                  } else if (type == 'NREGA Job Card') {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                      LengthLimitingTextInputFormatter(20),
                                    ];
                                  } else {
                                    formatters = [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                    ];
                                  }
                                  return _buildCustomTextField(
                                    "OVD NUMBER",
                                    _ovdNumberControllers[slotIdx],
                                    hint: "Enter No.",
                                    inputFormatters: formatters,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  const hasExpiry = [
                                    'Passport',
                                    'Driving Licence',
                                    'NREGA Job Card',
                                  ];
                                  final bool showExpiry =
                                      _ovdTypes[slotIdx] != null &&
                                      hasExpiry.contains(_ovdTypes[slotIdx]);

                                  if (!showExpiry) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (_ovdExpiryControllers[slotIdx]
                                              .text
                                              .isNotEmpty) {
                                            _ovdExpiryControllers[slotIdx]
                                                .clear();
                                          }
                                        });
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "OVD EXPIRY",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 48,
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            "Not Applicable",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return _buildCustomTextField(
                                    "OVD EXPIRY",
                                    _ovdExpiryControllers[slotIdx],
                                    hint: "MM/YYYY",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      MonthYearInputFormatter(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Per-slot document image upload (Front)
                        _buildDocUploadField(
                          label: _ovdTypes[slotIdx] == "Aadhaar Card"
                              ? "AADHAAR FRONT IMAGE"
                              : "OVD ${slotIdx + 1} DOCUMENT IMAGE",
                          file: _ovdImageFiles[slotIdx],
                          bottomSheetTitle: _ovdTypes[slotIdx] == "Aadhaar Card"
                              ? "Capture Aadhaar Front"
                              : "Upload OVD Document ${slotIdx + 1}",
                          imageType: 'ovd_$slotIdx',
                          uploadSlotKey: 'OVD${slotIdx + 1}',
                          onPicked: (picked, locData) async {
                            if (locData.isEmpty ||
                                locData["latitude"] == null) {
                              _showErrorPopup(
                                "Location not captured. Please enable location services and try again.",
                              );
                              return;
                            }

                            final bytes = await File(picked.path).readAsBytes();

                            final slotKey = 'OVD${slotIdx + 1}';
                            setState(() => _uploadingSlots.add(slotKey));
                            final bool success = await _uploadImageInstantly(
                              imageSlot: slotKey,
                              documentType: _ovdTypes[slotIdx] ?? "Unknown",
                              documentNumber:
                                  _ovdNumberControllers[slotIdx].text,
                              imageBytes: bytes,
                              expiryDate: _ovdExpiryControllers[slotIdx].text,
                              locationData: locData,
                            );
                            if (mounted)
                              setState(() => _uploadingSlots.remove(slotKey));

                            if (success && mounted) {
                              setState(() {
                                _ovdImageFiles[slotIdx] = picked;
                                _ovdLocationData[slotIdx] = locData;
                              });
                            } else if (mounted) {
                              _showErrorPopup(
                                "Image upload failed. Please try again.",
                              );
                            }
                          },
                        ),

                        // Aadhaar Back photo — only when this slot is Aadhaar Card
                        if (_ovdTypes[slotIdx] == "Aadhaar Card") ...[
                          const SizedBox(height: 16),
                          _buildDocUploadField(
                            label: "AADHAAR BACK IMAGE",
                            file: _aadhaarBackFile,
                            bottomSheetTitle: "Capture Aadhaar Back",
                            imageType: 'aadhaar_back',
                            uploadSlotKey: 'AadhaarBack',
                            onPicked: (picked, locData) async {
                              if (locData.isEmpty ||
                                  locData["latitude"] == null) {
                                _showErrorPopup(
                                  "Location not captured. Please enable location services and try again.",
                                );
                                return;
                              }

                              final bytes = await File(
                                picked.path,
                              ).readAsBytes();

                              setState(
                                () => _uploadingSlots.add('AadhaarBack'),
                              );
                              final bool success = await _uploadImageInstantly(
                                imageSlot: "OVD4",
                                documentType: "Aadhaar Card",
                                documentNumber:
                                    _ovdNumberControllers[slotIdx].text,
                                imageBytes: bytes,
                                expiryDate: _ovdExpiryControllers[slotIdx].text,
                                locationData: locData,
                              );
                              if (mounted)
                                setState(
                                  () => _uploadingSlots.remove('AadhaarBack'),
                                );

                              if (success && mounted) {
                                setState(() {
                                  _aadhaarBackFile = picked;
                                  _aadhaarBackLocationData = locData;
                                });
                              } else if (mounted) {
                                _showErrorPopup(
                                  "Image upload failed. Please try again.",
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Add OVD button (only visible when less than 3)
                if (_ovdCount < 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _ovdCount = 3),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkNavy.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.darkNavy,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Add OVD Document 3 (Optional)",
                              style: TextStyle(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Address Proof section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ADDRESS PROOF (OVD SAME?)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _selectedAddressProof = "Yes \u2014 OVD",
                              ),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      _selectedAddressProof == "Yes \u2014 OVD"
                                      ? AppColors.darkNavy
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _selectedAddressProof ==
                                            "Yes \u2014 OVD"
                                        ? AppColors.darkNavy
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  "Yes \u2014 OVD",
                                  style: TextStyle(
                                    color:
                                        _selectedAddressProof ==
                                            "Yes \u2014 OVD"
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _selectedAddressProof = "Separate Doc",
                              ),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedAddressProof == "Separate Doc"
                                      ? AppColors.darkNavy
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _selectedAddressProof == "Separate Doc"
                                        ? AppColors.darkNavy
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  "Separate Doc",
                                  style: TextStyle(
                                    color:
                                        _selectedAddressProof == "Separate Doc"
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Contact Details",

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w900,

            fontFamily: 'Serif',

            color: AppColors.darkNavy,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "SECTION E \u2014 MOBILE, EMAIL & OTP VERIFY",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // Mobile Number Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.dialpad, color: Colors.indigo, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Mobile Number",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Row(
                children: [
                  Container(
                    height: 48,

                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Text(
                      "+91",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildCustomTextField(
                      "",

                      _mobileNumberController,

                      isVerified: _mobileOtpState == 2,

                      forceEditable: true,

                      readOnly: false,

                      hint: "Ex. 9812345678",

                      keyboardType: TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],

                      onChanged: (val) {
                        if (_mobileOtpState != 0) {
                          setState(() => _mobileOtpState = 0);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,

                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: Colors.grey.shade50,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: _mobileOtpState == 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Mobile OTP Verification",

                            style: TextStyle(
                              color: Colors.grey,

                              fontWeight: FontWeight.w500,

                              fontSize: 13,
                            ),
                          ),

                          GestureDetector(
                            onTap: _isMobileOtpLoading ? null : _sendMobileOtp,

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,

                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: _isMobileOtpLoading
                                    ? Colors.grey
                                    : AppColors.darkNavy,

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: _isMobileOtpLoading
                                  ? const SizedBox(
                                      width: 14,

                                      height: 14,

                                      child: CircularProgressIndicator(
                                        color: Colors.white,

                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Send OTP",

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontWeight: FontWeight.bold,

                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    : _mobileOtpState == 1
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 36,

                                  child: TextField(
                                    controller: _mobileOtpController,

                                    keyboardType: TextInputType.number,

                                    decoration: InputDecoration(
                                      hintText: "Enter OTP",

                                      hintStyle: const TextStyle(fontSize: 12),

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),

                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              GestureDetector(
                                onTap: _isMobileOtpLoading
                                    ? null
                                    : _verifyMobileOtp,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,

                                    vertical: 8,
                                  ),

                                  decoration: BoxDecoration(
                                    color: _isMobileOtpLoading
                                        ? Colors.grey
                                        : AppColors.tealAccent,

                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: _isMobileOtpLoading
                                      ? const SizedBox(
                                          width: 14,

                                          height: 14,

                                          child: CircularProgressIndicator(
                                            color: Colors.white,

                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Verify",

                                          style: TextStyle(
                                            color: Colors.white,

                                            fontWeight: FontWeight.bold,

                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              if (_mobileOtpTimerSeconds > 0)
                                Text(
                                  "Resend OTP in ${_mobileOtpTimerSeconds}s",

                                  style: const TextStyle(
                                    fontSize: 12,

                                    color: Colors.grey,
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: _isMobileOtpLoading
                                      ? null
                                      : () async {
                                          await _sendMobileOtp();
                                        },

                                  child: const Text(
                                    "Resend OTP",

                                    style: TextStyle(
                                      fontSize: 12,

                                      color: AppColors.tealAccent,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        // _mobileOtpState == 2
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check, color: Colors.teal, size: 16),

                              SizedBox(width: 4),

                              Text(
                                "OTP Verified",

                                style: TextStyle(
                                  color: Colors.teal,

                                  fontWeight: FontWeight.bold,

                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,

                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.teal,

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: const Text(
                              "Verified",

                              style: TextStyle(
                                color: Colors.white,

                                fontWeight: FontWeight.bold,

                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Alternate Mobile Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: const [
                  Icon(Icons.phone, color: Colors.pink, size: 20),

                  SizedBox(width: 8),

                  Text(
                    "Alternate Mobile / Landline",

                    style: TextStyle(
                      color: AppColors.darkNavy,

                      fontWeight: FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Row(
                children: [
                  Container(
                    height: 48,

                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Text(
                      "+91",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildCustomTextField(
                      "",

                      _alternateMobileController,

                      hint: "Optional",

                      keyboardType: TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Email ID Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: const [
                  Icon(Icons.email, color: Color(0xFFD8BBE1), size: 20),

                  SizedBox(width: 8),

                  Text(
                    "Email ID",

                    style: TextStyle(
                      color: AppColors.darkNavy,

                      fontWeight: FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              _buildCustomTextField(
                "",

                _emailController,

                hint: "Enter email",

                keyboardType: TextInputType.emailAddress,

                isRequired: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.green.shade300, width: 0.5),
          ),

          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.green, fontSize: 13, height: 1.4),

              children: [
                TextSpan(
                  text: "Part 1 Complete! ",

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                TextSpan(
                  text:
                      "You have filled Sections A\u2013E (Customer Details). Next: Part 2 \u2014 Account Opening Details.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillOption(
    String title,

    String? selectedValue,

    ValueChanged<String> onSelect,
  ) {
    bool isSelected = selectedValue == title;

    return GestureDetector(
      onTap: () => onSelect(title),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.white,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isSelected ? AppColors.darkNavy : Colors.grey.shade300,
          ),
        ),

        child: Text(
          title,

          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,

            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,

            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    String title,

    String? selectedValue,

    ValueChanged<String> onSelect,
  ) {
    bool isSelected = selectedValue == title;

    return GestureDetector(
      onTap: () => onSelect(title),

      child: Container(
        color: Colors.transparent,

        padding: const EdgeInsets.symmetric(vertical: 8),

        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,

              color: isSelected ? AppColors.darkNavy : Colors.grey.shade400,

              size: 20,
            ),

            const SizedBox(width: 12),

            Text(
              title,

              style: TextStyle(
                color: isSelected ? AppColors.darkNavy : Colors.grey.shade700,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,

                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoToggleRow(
    String title,

    String? selectedValue,

    ValueChanged<String> onSelect,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 13,

            color: Colors.grey,

            fontWeight: FontWeight.bold,
          ),
        ),

        Row(
          children: [
            GestureDetector(
              onTap: () => onSelect("Yes"),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,

                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: selectedValue == "Yes"
                      ? AppColors.darkNavy
                      : Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: selectedValue == "Yes"
                        ? AppColors.darkNavy
                        : Colors.grey.shade300,
                  ),
                ),

                child: Text(
                  "Yes",

                  style: TextStyle(
                    color: selectedValue == "Yes"
                        ? Colors.white
                        : Colors.black87,

                    fontWeight: FontWeight.bold,

                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () => onSelect("No"),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,

                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: selectedValue == "No"
                      ? AppColors.darkNavy
                      : Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: selectedValue == "No"
                        ? AppColors.darkNavy
                        : Colors.grey.shade300,
                  ),
                ),

                child: Text(
                  "No",

                  style: TextStyle(
                    color: selectedValue == "No"
                        ? Colors.white
                        : Colors.black87,

                    fontWeight: FontWeight.bold,

                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOccupationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Occupation & Income",

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w900,

            fontFamily: 'Serif',

            color: AppColors.darkNavy,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "SECTION F \u2014 CKYC MANDATORY",

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.bold,

            color: Colors.grey,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // Occupation Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.work, color: Colors.brown, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Occupation",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Wrap(
                spacing: 8,

                runSpacing: 8,

                children: [
                  _buildPillOption(
                    "Service",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Business",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Agriculture",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Professional",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Housewife",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Retired",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Student",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),

                  _buildPillOption(
                    "Other",

                    _selectedOccupation,

                    (val) => setState(() => _selectedOccupation = val),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildCustomTextField(
          "Organisation / Employer Name",

          _employerNameController,
        ),

        const SizedBox(height: 16),

        _buildCustomTextField("Designation", _designationController),

        const SizedBox(height: 24),

        // Annual Income Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.orange, size: 20),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Annual Income",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.grey.shade50,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    _buildRadioOption(
                      "Below 1 Lakh",

                      _selectedAnnualIncome,

                      (val) => setState(() => _selectedAnnualIncome = val),
                    ),

                    _buildRadioOption(
                      "1\u20135 Lakh",

                      _selectedAnnualIncome,

                      (val) => setState(() => _selectedAnnualIncome = val),
                    ),

                    _buildRadioOption(
                      "5\u201310 Lakh",

                      _selectedAnnualIncome,

                      (val) => setState(() => _selectedAnnualIncome = val),
                    ),

                    _buildRadioOption(
                      "10\u201325 Lakh",

                      _selectedAnnualIncome,

                      (val) => setState(() => _selectedAnnualIncome = val),
                    ),

                    _buildRadioOption(
                      "Above 25 Lakh",

                      _selectedAnnualIncome,

                      (val) => setState(() => _selectedAnnualIncome = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Source of Funds Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,

                    color: Colors.blueGrey,

                    size: 20,
                  ),

                  SizedBox(width: 8),

                  RichText(
                    text: TextSpan(
                      text: "Source of Funds",
                      style: const TextStyle(
                        color: AppColors.darkNavy,

                        fontWeight: FontWeight.bold,

                        fontSize: 15,
                      ),
                      children: const [
                        TextSpan(
                          text: ' \u2605',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              Wrap(
                spacing: 8,

                runSpacing: 8,

                children: [
                  _buildPillOption(
                    "Salary",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Business",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Agriculture",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Rental",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Savings",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Pension",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),

                  _buildPillOption(
                    "Other",

                    _selectedSourceOfFunds,

                    (val) => setState(() => _selectedSourceOfFunds = val),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // PEP Declaration Card
        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,

                    color: Colors.orangeAccent,

                    size: 20,
                  ),

                  SizedBox(width: 8),

                  Text(
                    "PEP Declaration",

                    style: TextStyle(
                      color: AppColors.darkNavy,

                      fontWeight: FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Divider(color: Colors.grey, thickness: 0.3),
              ),

              _buildYesNoToggleRow(
                "Politically Exposed Person?",

                _selectedPep ?? "No",

                (val) => setState(() => _selectedPep = val),
              ),

              const SizedBox(height: 12),

              _buildYesNoToggleRow(
                "Related to PEP?",

                _selectedRelatedPep ?? "No",

                (val) => setState(() => _selectedRelatedPep = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNomineeDetails() {
    return StatefulBuilder(
      builder: (context, setNomineeState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Nominee Details",

              style: TextStyle(
                fontSize: 26,

                fontWeight: FontWeight.w900,

                fontFamily: 'Serif',

                color: AppColors.darkNavy,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "SECTION G \u2014 UP TO 3 NOMINEES (TOTAL SHARE = 100%)",

              style: TextStyle(
                fontSize: 12,

                fontWeight: FontWeight.bold,

                color: Colors.grey,

                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),

            // Info Banner
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),

                borderRadius: BorderRadius.circular(12),

                border: const Border(
                  left: BorderSide(color: Colors.amber, width: 4),
                ),
              ),

              child: const Text(
                "All nominees' % share must total 100%. If nominee is minor, guardian details mandatory.",

                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            ..._nominees.asMap().entries.map((entry) {
              int idx = entry.key;

              NomineeEntry nominee = entry.value;

              final int? age = int.tryParse(nominee.ageController.text);

              final bool isMinor = age != null && age < 18;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Nominee header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          "Nominee ${idx + 1}",

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,

                            fontSize: 16,

                            color: AppColors.darkNavy,
                          ),
                        ),

                        Row(
                          children: [
                            if (_nominees.length > 1)
                              GestureDetector(
                                onTap: () {
                                  _removeNominee(idx);
                                  // Update the section UI immediately
                                  setNomineeState(() {});
                                },

                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),

                                  padding: const EdgeInsets.all(6),

                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,

                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons.close,

                                    color: Colors.red.shade400,

                                    size: 14,
                                  ),
                                ),
                              ),

                            Container(
                              width: 32,

                              height: 32,

                              decoration: const BoxDecoration(
                                color: AppColors.darkNavy,

                                shape: BoxShape.circle,
                              ),

                              alignment: Alignment.center,

                              child: Text(
                                "${idx + 1}",

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,

                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),

                      child: Divider(color: Colors.grey, thickness: 0.3),
                    ),

                    // Full Name
                    _buildCustomTextField(
                      "FULL NAME",

                      nominee.fullNameController,

                      hint: "Enter full name",
                    ),

                    const SizedBox(height: 14),

                    // Relationship dropdown + % Share
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "RELATIONSHIP",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: nominee.selectedRelationship,
                                    hint: Text(
                                      'Select',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade600,
                                    ),
                                    items:
                                        const [
                                              'Parent',
                                              'Spouse',
                                              'Child',
                                              'Sibling',
                                              'Grandparent',
                                              'Grandchild',
                                              'Relative',
                                              'Friend',
                                              'Other',
                                            ]
                                            .map(
                                              (r) => DropdownMenuItem(
                                                value: r,
                                                child: Text(
                                                  r,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      setNomineeState(() {
                                        nominee.selectedRelationship = val;
                                        if (val != 'Other') {
                                          nominee.otherRelationshipController
                                              .clear();
                                          nominee.relationshipController.text =
                                              val ?? '';
                                        } else {
                                          nominee.relationshipController.text =
                                              '';
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              // Show text field when "Other" is selected
                              if (nominee.selectedRelationship == 'Other') ...[
                                const SizedBox(height: 8),
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: TextField(
                                    controller:
                                        nominee.otherRelationshipController,
                                    onChanged: (val) {
                                      setNomineeState(() {
                                        nominee.relationshipController.text =
                                            val;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Specify relation',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "% SHARE",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 48,
                                child: TextField(
                                  controller: nominee.shareController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  onChanged: (val) {
                                    final entered = int.tryParse(val) ?? 0;
                                    // Sum share of all OTHER nominees
                                    final otherTotal = _nominees
                                        .where((n) => n != nominee)
                                        .fold<int>(
                                          0,
                                          (sum, n) =>
                                              sum +
                                              (int.tryParse(
                                                    n.shareController.text,
                                                  ) ??
                                                  0),
                                        );
                                    final maxAllowed = 100 - otherTotal;
                                    if (entered > maxAllowed) {
                                      nominee.shareController.text = maxAllowed
                                          .toString();
                                      nominee
                                          .shareController
                                          .selection = TextSelection.collapsed(
                                        offset: maxAllowed.toString().length,
                                      );
                                    }
                                    // Refresh the whole Nominee Section
                                    setNomineeState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: "e.g. 70",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.tealAccent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Date of Birth + Age
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomTextField(
                            "DATE OF BIRTH",

                            nominee.dobController,

                            hint: "DD/MM/YYYY",

                            keyboardType: TextInputType.number,

                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),

                              DateInputFormatter(),
                            ],

                            onChanged: (val) {
                              if (val.length == 10) {
                                try {
                                  List<String> parts = val.split('/');

                                  if (parts.length == 3) {
                                    int day = int.parse(parts[0]);

                                    int month = int.parse(parts[1]);

                                    int year = int.parse(parts[2]);

                                    DateTime dob = DateTime(year, month, day);

                                    DateTime today = DateTime.now();

                                    int age = today.year - dob.year;

                                    if (today.month < dob.month ||
                                        (today.month == dob.month &&
                                            today.day < dob.day)) {
                                      age--;
                                    }

                                    if (age >= 0) {
                                      nominee.ageController.text = age
                                          .toString();

                                      setNomineeState(() {});
                                    }
                                  }
                                } catch (_) {}
                              } else if (nominee
                                  .ageController
                                  .text
                                  .isNotEmpty) {
                                nominee.ageController.text = "";

                                setNomineeState(() {});
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "AGE",

                                style: TextStyle(
                                  fontSize: 12,

                                  fontWeight: FontWeight.bold,

                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                height: 48,

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(12),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: TextField(
                                  controller: nominee.ageController,

                                  keyboardType: TextInputType.number,

                                  readOnly: true,

                                  onChanged: (_) => setNomineeState(() {}),

                                  decoration: InputDecoration(
                                    hintText: "e.g. 35",

                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,

                                      fontSize: 14,
                                    ),

                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),

                                    border: InputBorder.none,

                                    enabledBorder: InputBorder.none,

                                    focusedBorder: InputBorder.none,

                                    errorBorder: InputBorder.none,

                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Guardian Name - only shown when nominee is a minor
                    if (isMinor) ...[
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Text(
                            "GUARDIAN NAME (MINOR)",

                            style: TextStyle(
                              fontSize: 12,

                              fontWeight: FontWeight.bold,

                              color: Colors.red,
                            ),
                          ),

                          RichText(
                            text: TextSpan(
                              text: "",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' \u2605',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Container(
                        height: 48,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(color: Colors.red.shade200),
                        ),

                        child: TextField(
                          controller: nominee.guardianAddressController,

                          decoration: InputDecoration(
                            hintText: "Enter guardian's full name",

                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,

                              fontSize: 14,
                            ),

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),

                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            // Add Nominee dashed button (max 3)
            if (_nominees.length < 3)
              GestureDetector(
                onTap: () {
                  _addNominee();
                  setNomineeState(() {});
                },

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),

                  alignment: Alignment.center,

                  child: Text(
                    "+ Add Nominee ${_nominees.length + 1}",

                    style: const TextStyle(
                      color: AppColors.darkNavy,

                      fontWeight: FontWeight.bold,

                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Total Share row
            Row(
              children: [
                const Text(
                  "Total Share:",

                  style: TextStyle(
                    color: Colors.grey,

                    fontSize: 13,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  (() {
                    final int total = _nominees.fold(
                      0,
                      (sum, n) =>
                          sum + (int.tryParse(n.shareController.text) ?? 0),
                    );
                    final bool valid = total == 100;
                    return "$total%${valid ? "  \u2713" : ""}";
                  })(),

                  style: TextStyle(
                    color: (() {
                      final int total = _nominees.fold(
                        0,
                        (sum, n) =>
                            sum + (int.tryParse(n.shareController.text) ?? 0),
                      );
                      return total == 100 ? Colors.teal : Colors.red;
                    })(),

                    fontSize: 14,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _validateCurrentStep() {
    switch (_currentFormStep) {
      case 0: // Personal Details

        if (_fullNameController.text.isEmpty ||
            _fatherHusbandNameController.text.isEmpty ||
            _dobController.text.isEmpty ||
            _selectedGender == null ||
            _selectedMaritalStatus == null ||
            _selectedNationality == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all mandatory personal details.'),
            ),
          );

          return false;
        }

        if (_signatureFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload Signature.')),
          );
          return false;
        }

        return true;

      case 1: // Address Details

        if (_currentAddressController.text.isEmpty ||
            _villageCityController.text.isEmpty ||
            _talukaController.text.isEmpty ||
            _districtController.text.isEmpty ||
            _stateController.text.isEmpty ||
            _pinCodeController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please fill all mandatory current address details.',
              ),
            ),
          );

          return false;
        }

        bool isSame =
            _selectedPermanentAddressSame == "Same as Current" ||
            _selectedPermanentAddressSame == null;

        if (!isSame) {
          if (_permanentAddressController.text.isEmpty ||
              _permVillageCityController.text.isEmpty ||
              _permDistrictController.text.isEmpty ||
              _permStateController.text.isEmpty ||
              _permPinCodeController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please fill all mandatory permanent address details.',
                ),
              ),
            );

            return false;
          }
        }

        return true;

      case 2: // KYC Documents

        final bool hasForm60 =
            _form60Status == "Submitted" && _form60File != null;

        if (!hasForm60 && !_isPanVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify PAN Number (or upload Form 60/61).'),
            ),
          );

          return false;
        }

        if (_form60Status == "Submitted" && _form60File == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload Form 60/61 Document.')),
          );

          return false;
        }

        if (_aadhaarCkycController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aadhaar verification is required.')),
          );
          return false;
        }

        // Validate at least 2 OVD documents are fully filled
        for (int i = 0; i < 2; i++) {
          if (_ovdTypes[i] == null || _ovdTypes[i]!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select document type for OVD ${i + 1}.'),
              ),
            );
            return false;
          }
          if (_ovdNumberControllers[i].text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter OVD number for OVD ${i + 1}.'),
              ),
            );
            return false;
          }
          if (const [
            'Passport',
            'Driving Licence',
            'NREGA Job Card',
          ].contains(_ovdTypes[i])) {
            if (_ovdExpiryControllers[i].text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please enter expiry date for ${_ovdTypes[i]} in OVD ${i + 1}.',
                  ),
                ),
              );
              return false;
            }
          }
          if (_ovdImageFiles[i] == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please upload document image for OVD ${i + 1}.'),
              ),
            );
            return false;
          }
          // Validate Aadhaar back photo if this slot is Aadhaar
          if (_ovdTypes[i] == "Aadhaar Card" && _aadhaarBackFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please capture Aadhaar Back photo.'),
              ),
            );
            return false;
          }
        }
        // Validate optional 3rd OVD if added
        if (_ovdCount >= 3) {
          if (_ovdTypes[2] != null && _ovdTypes[2]!.isNotEmpty) {
            if (_ovdNumberControllers[2].text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter OVD number for OVD 3.'),
                ),
              );
              return false;
            }
            if (const [
              'Passport',
              'Driving Licence',
              'NREGA Job Card',
            ].contains(_ovdTypes[2])) {
              if (_ovdExpiryControllers[2].text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter expiry date for ${_ovdTypes[2]} in OVD 3.',
                    ),
                  ),
                );
                return false;
              }
            }
            if (_ovdImageFiles[2] == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please upload document image for OVD 3.'),
                ),
              );
              return false;
            }
            // Validate Aadhaar back photo if OVD 3 is Aadhaar
            if (_ovdTypes[2] == "Aadhaar Card" && _aadhaarBackFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please capture Aadhaar Back photo.'),
                ),
              );
              return false;
            }
          }
        }

        return true;

      case 3: // Contact Details

        if (_mobileOtpState != 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify Mobile Number.')),
          );

          return false;
        }

        // if (_emailController.text.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Please enter an Email ID.')),
        //   );

        //   return false;
        // }

        return true;

      case 4: // Occupation Details
        if (_selectedOccupation == null ||
            _selectedAnnualIncome == null ||
            _selectedSourceOfFunds == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all mandatory Occupation details.'),
            ),
          );
          return false;
        }
        return true;

      case 5: // Nominee Details
        // ─── Rule 1: At least one nominee must exist ───────────────────
        if (_nominees.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one nominee.'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }

        // ─── Rule 2: All added nominees must have required fields ───────
        for (int i = 0; i < _nominees.length; i++) {
          final n = _nominees[i];
          final label = 'Nominee ${i + 1}';

          if (n.fullNameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label: Full name is required.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
          if (n.relationshipController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label: Relationship is required.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
          if (n.dobController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label: Date of birth is required.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
          if (n.ageController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label: Age is required.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
          if (n.shareController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label: Share % is required.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
        }

        // ─── Rule 3: No nominee can have 0% share ──────────────────────
        for (int i = 0; i < _nominees.length; i++) {
          final int share =
              int.tryParse(_nominees[i].shareController.text.trim()) ?? 0;
          if (share == 0) {
            final label = 'Nominee ${i + 1}';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$label: Share cannot be 0%. Each nominee must have at least 1% share.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
        }

        // ─── Rule 4: If multiple nominees, one cannot hold 100% ─────────
        if (_nominees.length > 1) {
          for (int i = 0; i < _nominees.length; i++) {
            final int share =
                int.tryParse(_nominees[i].shareController.text.trim()) ?? 0;
            if (share == 100) {
              final label = 'Nominee ${i + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$label: Cannot have 100% share when multiple nominees are added. Please distribute the share.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return false;
            }
          }
        }

        // ─── Rule 5: Total share must equal exactly 100 ─────────────────
        final int totalShare = _nominees.fold(
          0,
          (sum, n) => sum + (int.tryParse(n.shareController.text.trim()) ?? 0),
        );
        if (totalShare != 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Total nominee share must be 100%. Current total: $totalShare%.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }

        return true;
      default:
        return true;
    }
  }

  //   Widget _buildFormNavigation() {
  //     return Row(
  //       children: [
  //         if (_currentFormStep > 0)
  //           InkWell(
  //             onTap: () {
  //               setState(() {
  //                 _currentFormStep--;
  //               });

  //               _scrollController.animateTo(
  //                 0,

  //                 duration: const Duration(milliseconds: 300),

  //                 curve: Curves.easeOut,
  //               );
  //             },

  //             child: Container(
  //               height: 56,

  //               width: 56,

  //               decoration: BoxDecoration(
  //                 color: Colors.white,

  //                 borderRadius: BorderRadius.circular(12),

  //                 border: Border.all(color: Colors.grey.shade300),
  //               ),

  //               child: const Icon(Icons.arrow_back, color: Colors.grey),
  //             ),
  //           )
  //         else
  //           Container(
  //             height: 56,

  //             width: 56,

  //             decoration: BoxDecoration(
  //               color: Colors.white,

  //               borderRadius: BorderRadius.circular(12),

  //               border: Border.all(color: Colors.grey.shade300),
  //             ),

  //             child: const Icon(Icons.arrow_back, color: Colors.grey),
  //           ),

  //         const SizedBox(width: 16),

  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: _isSubmitting
  //                 ? null
  //                 : () async {
  //                     if (!_validateCurrentStep()) return;

  //                     if (_currentFormStep < _totalSteps - 1) {
  //                       setState(() {
  //                         _currentFormStep++;
  //                       });

  //                       _scrollController.animateTo(
  //                         0,

  //                         duration: const Duration(milliseconds: 300),

  //                         curve: Curves.easeOut,
  //                       );
  //                     } else {
  //                       setState(() => _isSubmitting = true);

  //                       final currentIso = DateTime.now().toIso8601String();

  //                       String? convertDate(String raw) {
  //                         String ddMMyyyy = raw.replaceAll(' ', '');
  //                         if (ddMMyyyy.isEmpty || ddMMyyyy.length < 10)
  //                           return null;
  //                         try {
  //                           List<String> parts = ddMMyyyy.split('/');
  //                           if (parts.length == 3) {
  //                             return "${parts[2]}-${parts[1]}-${parts[0]}T00:00:00.000Z";
  //                           }
  //                         } catch (_) {}
  //                         return null;
  //                       }

  //                       String? convertExpiry(String raw) {
  //                         if (raw.isEmpty) return null;
  //                         try {
  //                           final parts = raw.split('/');
  //                           if (parts.length == 2) {
  //                             return "${parts[1].trim()}-${parts[0].trim()}-01T00:00:00.000Z";
  //                           }
  //                         } catch (_) {}
  //                         return null;
  //                       }

  //                       // Safe Base64 Helper to prevent PathNotFoundException
  //                       Future<String> safeBase64(dynamic fileObj) async {
  //                         if (fileObj == null) return "";
  //                         File? file;
  //                         if (fileObj is XFile) {
  //                           file = File(fileObj.path);
  //                         } else if (fileObj is File) {
  //                           file = fileObj;
  //                         }

  //                         if (file != null && await file.exists()) {
  //                           try {
  //                             final bytes = await file.readAsBytes();
  //                             return base64Encode(bytes);
  //                           } catch (e) {
  //                             print("Error reading file to Base64: $e");
  //                           }
  //                         }
  //                         return "";
  //                       }

  //                       // Profile image special handling (might be from bytes or file)
  //                       String pImgBase64 = "";
  //                       if (_profileImageBytes != null) {
  //                         pImgBase64 = base64Encode(_profileImageBytes!);
  //                       } else {
  //                         pImgBase64 = await safeBase64(_photoFile);
  //                       }

  //                       String sBase64 = await safeBase64(_signatureFile);
  //                       String o1Base64 = await safeBase64(_ovdImageFiles[0]);
  //                       String o2Base64 = await safeBase64(_ovdImageFiles[1]);
  //                       String o3Base64 = await safeBase64(_ovdImageFiles[2]);
  //                       String f60Base64 = await safeBase64(_form60File);

  //                       // Helper to get location safely for a specific OVD slot
  //                       String? getLoc(int index, String key) {
  //                         if (_ovdLocationData[index] != null &&
  //                             _ovdLocationData[index]![key] != null &&
  //                             _ovdLocationData[index]![key]!.isNotEmpty) {
  //                           return _ovdLocationData[index]![key]!;
  //                         }
  //                         return null;
  //                       }

  //                       // ROOT LEVEL PAYLOAD (Synced with Swagger template)
  //                       Map<String, dynamic> data = {
  //                         "aadharNumber": _aadhaarController.text.isNotEmpty
  //                             ? _aadhaarController.text
  //                             : _aadhaarCkycController.text,

  //                         "panNumber": _panNumberController.text,

  //                         "fullName": _fullNameController.text,

  //                         "nameInMarathi": _nameMarathiController.text,

  //                         "fatherOrHusbandName":
  //                             _fatherHusbandNameController.text,

  //                         "motherName": _motherNameController.text,

  //                         "dob": convertDate(_dobController.text) ?? currentIso,

  //                         "gender": _selectedGender ?? "",

  //                         "maritalStatus": _selectedMaritalStatus ?? "",

  //                         "nationality": _selectedNationality ?? "",

  //                         "residentialStatus": _selectedResidentialStatus ?? "",

  //                         "religion": _religionController.text,

  //                         "category": _selectedCategory ?? "",

  //                         "photoBase64": pImgBase64,

  //                         "signatureBase64": sBase64,

  //                         "ovdImg1Base64": o1Base64,

  //                         "ovdImg2Base64": o2Base64,

  //                         "ovdImg3Base64": o3Base64,

  //                         "ovdImg4Base64": "",

  //                         "form60_61_ImgBase64": f60Base64,

  //                         "currentAddress": _currentAddressController.text,

  //                         "currentCity": _villageCityController.text,

  //                         "currentTaluka": _talukaController.text,

  //                         "currentDistrict": _districtController.text,

  //                         "currentState": _stateController.text,

  //                         "currentPinCode": _pinCodeController.text,

  //                         "currentCountry": _countryController.text,

  //                         "isPermanentSame":
  //                             _selectedPermanentAddressSame == "Same as Current",

  //                         "permanentAddress": _permanentAddressController.text,

  //                         "permanentCity": _permVillageCityController.text,

  //                         "permanentTaluka": _permTalukaController.text,

  //                         "permanentDistrict": _permDistrictController.text,

  //                         "permanentState": _permStateController.text,

  //                         "permanentPinCode": _permPinCodeController.text,

  //                         "permanentCountry": _permCountryController.text,

  //                         "ovdType_1": _ovdTypes[0] ?? "",
  //                         "ovdNumber_1": _ovdNumberControllers[0].text,
  //                         "ovdExpiryDate_1":
  //                             convertExpiry(_ovdExpiryControllers[0].text) ??
  //                             currentIso,

  //                         "ovdType_2": _ovdTypes[1] ?? "",
  //                         "ovdNumber_2": _ovdNumberControllers[1].text,
  //                         "ovdExpiryDate_2":
  //                             convertExpiry(_ovdExpiryControllers[1].text) ??
  //                             currentIso,

  //                         "ovdType_3": _ovdCount >= 3 ? (_ovdTypes[2] ?? "") : "",
  //                         "ovdNumber_3": _ovdCount >= 3
  //                             ? _ovdNumberControllers[2].text
  //                             : "",
  //                         "ovdExpiryDate_3": _ovdCount >= 3
  //                             ? (convertExpiry(_ovdExpiryControllers[2].text) ??
  //                                   currentIso)
  //                             : currentIso,

  //                         "addressProofType": _selectedAddressProof ?? "",

  //                         "addressProofNumber": "N/A",

  //                         "formType": _form60Status,

  //                         "mobileNumber": _mobileNumberController.text,

  //                         "alternateMobile": _alternateMobileController.text,

  //                         "email": _emailController.text,

  //                         "occupation": _selectedOccupation ?? "",

  //                         "employerName": _employerNameController.text,

  //                         "designation": _designationController.text,

  //                         "annualIncome": _selectedAnnualIncome ?? "",

  //                         "sourceOfFunds": _selectedSourceOfFunds ?? "",

  //                         "isPEP": _selectedPep == "Yes",

  //                         "isRelatedToPEP": _selectedRelatedPep == "Yes",

  //                         "nomineeName": _nominees.isNotEmpty
  //                             ? _nominees[0].fullNameController.text
  //                             : "",

  //                         "nomineeRelationship": _nominees.isNotEmpty
  //                             ? _nominees[0].relationshipController.text
  //                             : "",

  //                         "nomineeDOB": _nominees.isNotEmpty
  //                             ? (convertDate(_nominees[0].dobController.text) ??
  //                                   currentIso)
  //                             : currentIso,

  //                         "nomineeAge": _nominees.isNotEmpty
  //                             ? (int.tryParse(_nominees[0].ageController.text) ??
  //                                   0)
  //                             : 0,

  //                         "nomineeSharePercent": _nominees.isNotEmpty
  //                             ? (int.tryParse(
  //                                     _nominees[0].shareController.text,
  //                                   ) ??
  //                                   0)
  //                             : 0,

  //                         "nomineeAddress": "",

  //                         "guardianName": _nominees.isNotEmpty
  //                             ? _nominees[0].guardianAddressController.text
  //                             : "",

  //                         "branchCode": "",
  //                         "kycNumber": "",
  //                         "dateOfApplication": currentIso,
  //                         "placeOfApplication": "",
  //                         "namePrefix": "",
  //                         "nameLast": "",
  //                         "fatherSpouseNamePrefix": "",
  //                         "mobileISDCode": "",
  //                         "cifid": "",
  //                         "branchName": "",

  //                         "nomineeName1": _nominees.length > 1
  //                             ? _nominees[1].fullNameController.text
  //                             : "",
  //                         "nomineeRelationship1": _nominees.length > 1
  //                             ? _nominees[1].relationshipController.text
  //                             : "",
  //                         "nomineeDOB1": _nominees.length > 1
  //                             ? (convertDate(_nominees[1].dobController.text) ??
  //                                   currentIso)
  //                             : currentIso,
  //                         "nomineeAge1": _nominees.length > 1
  //                             ? (int.tryParse(_nominees[1].ageController.text) ??
  //                                   0)
  //                             : 0,
  //                         "nomineeSharePercent1": _nominees.length > 1
  //                             ? (int.tryParse(
  //                                     _nominees[1].shareController.text,
  //                                   ) ??
  //                                   0)
  //                             : 0,
  //                         "nomineeAddress1": "",
  //                         "guardianName1": _nominees.length > 1
  //                             ? _nominees[1].guardianAddressController.text
  //                             : "",

  //                         "nomineeName2": _nominees.length > 2
  //                             ? _nominees[2].fullNameController.text
  //                             : "",
  //                         "nomineeRelationship2": _nominees.length > 2
  //                             ? _nominees[2].relationshipController.text
  //                             : "",
  //                         "nomineeDOB2": _nominees.length > 2
  //                             ? (convertDate(_nominees[2].dobController.text) ??
  //                                   currentIso)
  //                             : currentIso,
  //                         "nomineeAge2": _nominees.length > 2
  //                             ? (int.tryParse(_nominees[2].ageController.text) ??
  //                                   0)
  //                             : 0,
  //                         "nomineeSharePercent2": _nominees.length > 2
  //                             ? (int.tryParse(
  //                                     _nominees[2].shareController.text,
  //                                   ) ??
  //                                   0)
  //                             : 0,
  //                         "nomineeAddress2": "",
  //                         "guardianName2": _nominees.length > 2
  //                             ? _nominees[2].guardianAddressController.text
  //                             : "",

  //                         "ovD1_CaptureDate":
  //                             getLoc(0, 'captureDate') ?? currentIso,
  //                         "ovD1_Latitude": getLoc(0, 'latitude') ?? "",
  //                         "ovD1_Longitude": getLoc(0, 'longitude') ?? "",
  //                         "ovD1_Location": getLoc(0, 'location') ?? "",

  //                         "ovD2_CaptureDate":
  //                             getLoc(1, 'captureDate') ?? currentIso,
  //                         "ovD2_Latitude": getLoc(1, 'latitude') ?? "",
  //                         "ovD2_Longitude": getLoc(1, 'longitude') ?? "",
  //                         "ovD2_Location": getLoc(1, 'location') ?? "",

  //                         "ovD3_CaptureDate":
  //                             getLoc(2, 'captureDate') ?? currentIso,
  //                         "ovD3_Latitude": getLoc(2, 'latitude') ?? "",
  //                         "ovD3_Longitude": getLoc(2, 'longitude') ?? "",
  //                         "ovD3_Location": getLoc(2, 'location') ?? "",

  //                         "ovD4_CaptureDate": currentIso,
  //                         "ovD4_Latitude": "",
  //                         "ovD4_Longitude": "",
  //                         "ovD4_Location": "",
  //                       };

  //                       print('--- SENDING THIS SUBMIT PAYLOAD ---');
  //                       // WRAPPING IN "request" key for API model binding
  //                       final wrappedPayload = {"request": data};
  //                       print(json.encode(wrappedPayload));

  //                       var response = await _service.submitProfile(
  //                         wrappedPayload,
  //                       );

  //                       setState(() => _isSubmitting = false);

  //                       if (response != null) {
  //                         final String msg =
  //                             response['message'] ??
  //                             'Customer Form Submitted Successfully!';

  //                         final dynamic customerId =
  //                             response['referenceID'] ?? response['customerId'];

  //                         showDialog(
  //                           context: context,

  //                           builder: (context) => AlertDialog(
  //                             title: const Text('Success'),

  //                             content: Text(
  //                               '$msg\nCustomer Reference Number: ${customerId ?? "N/A"}',
  //                             ),

  //                             actions: [
  //                               TextButton(
  //                                 onPressed: () {
  //                                   Navigator.pop(context);

  //                                   Navigator.pop(context);
  //                                 },

  //                                 child: const Text('OK'),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       } else {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text(
  //                               'Failed to submit registration. Check log for details.',
  //                             ),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
  //                       }
  //                     }
  //                   },

  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF2A3A6A),

  //               elevation: 0,

  //               padding: const EdgeInsets.symmetric(vertical: 18),

  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),

  //             child: _isSubmitting
  //                 ? const SizedBox(
  //                     width: 24,

  //                     height: 24,

  //                     child: CircularProgressIndicator(
  //                       color: Colors.white,

  //                       strokeWidth: 2,
  //                     ),
  //                   )
  //                 : Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,

  //                     children: [
  //                       Text(
  //                         _currentFormStep < _totalSteps - 1
  //                             ? "Save & Continue"
  //                             : "Submit",

  //                         style: const TextStyle(
  //                           fontSize: 16,

  //                           fontWeight: FontWeight.bold,

  //                           color: Colors.white,
  //                         ),
  //                       ),

  //                       const SizedBox(width: 8),

  //                       const Icon(
  //                         Icons.arrow_forward,

  //                         color: Colors.white,

  //                         size: 20,
  //                       ),
  //                     ],
  //                   ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  Widget _buildFormNavigation() {
    return Row(
      children: [
        if (_currentFormStep > 0)
          InkWell(
            onTap: () {
              setState(() {
                _currentFormStep--;
              });
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.grey),
            ),
          )
        else
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.grey),
          ),

        const SizedBox(width: 16),

        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (!_validateCurrentStep()) return;

                    if (_currentFormStep < _totalSteps - 1) {
                      setState(() {
                        _currentFormStep++;
                      });
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      if (!mounted) return;
                      setState(() => _isSubmitting = true);

                      try {
                        // ✅ Fetch location once at submit time for any
                        // images that don't already have location data
                        // (existing images loaded from API won't have it)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fetching location data...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        final submitLocation = await _getLocationData(context);
                        if (submitLocation == null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to fetch location. Please enable GPS and try again.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          if (mounted) setState(() => _isSubmitting = false);
                          return;
                        }

                        // Fill missing OVD location data with submit-time location
                        for (int i = 0; i < _ovdCount; i++) {
                          if (_ovdLocationData[i] == null &&
                              _ovdImageFiles[i] != null) {
                            _ovdLocationData[i] = submitLocation;
                          }
                        }
                        // Fill missing Aadhaar back location
                        if (_aadhaarBackLocationData == null &&
                            _aadhaarBackFile != null) {
                          _aadhaarBackLocationData = submitLocation;
                        }

                        final currentIso = DateTime.now().toIso8601String();

                        // ✅ DD/MM/YYYY → ISO
                        String? convertDate(String raw) {
                          final clean = raw.replaceAll(' ', '');
                          if (clean.isEmpty || clean.length < 10) return null;
                          try {
                            final parts = clean.split('/');
                            if (parts.length == 3) {
                              return "${parts[2]}-${parts[1]}-${parts[0]}T00:00:00.000Z";
                            }
                          } catch (_) {}
                          return null;
                        }

                        // ✅ MM/YYYY → ISO
                        String? convertExpiry(String raw) {
                          final clean = raw.trim();
                          if (clean.isEmpty) return null;
                          try {
                            final parts = clean.split('/');
                            if (parts.length == 2) {
                              return "${parts[1].trim()}-${parts[0].trim()}-01T00:00:00.000Z";
                            }
                          } catch (_) {}
                          return null;
                        }

                        // ✅ AUTO-UPLOAD MISSING IMAGES VIA INSTANT API
                        bool needsAutoUpload =
                            (_photoFile == null &&
                                _profileImageBytes != null) ||
                            (_signatureFile == null &&
                                _signatureBytes != null) ||
                            (_form60File == null && _form60Bytes != null) ||
                            (_ovdImageFiles[0] == null &&
                                _ovdImageBytesCache[0] != null) ||
                            (_ovdImageFiles[1] == null &&
                                _ovdImageBytesCache[1] != null) ||
                            (_ovdImageFiles[2] == null &&
                                _ovdImageBytesCache[2] != null) ||
                            (_aadhaarBackFile == null &&
                                _aadhaarBackBytesCache != null);

                        if (needsAutoUpload) {
                          final autoLocData = await _getLocationData(context);
                          if (autoLocData != null && mounted) {
                            if (_photoFile == null &&
                                _profileImageBytes != null) {
                              await _uploadImageInstantly(
                                imageSlot: "PHOTO",
                                documentType: "Profile Photo",
                                documentNumber: "",
                                imageBytes: _profileImageBytes!,
                                expiryDate: "",
                                locationData: autoLocData,
                              );
                            }
                            if (_signatureFile == null &&
                                _signatureBytes != null) {
                              await _uploadImageInstantly(
                                imageSlot: "SIGNATURE",
                                documentType: "Signature",
                                documentNumber: "",
                                imageBytes: _signatureBytes!,
                                expiryDate: "",
                                locationData: autoLocData,
                              );
                            }
                            if (_form60File == null && _form60Bytes != null) {
                              await _uploadImageInstantly(
                                imageSlot: "FORM60",
                                documentType: "Form 60/61",
                                documentNumber: "",
                                imageBytes: _form60Bytes!,
                                expiryDate: "",
                                locationData: autoLocData,
                              );
                            }
                            for (int i = 0; i < 3; i++) {
                              if (_ovdImageFiles[i] == null &&
                                  _ovdImageBytesCache[i] != null) {
                                await _uploadImageInstantly(
                                  imageSlot: "OVD${i + 1}",
                                  documentType: _ovdTypes[i] ?? "Unknown",
                                  documentNumber: _ovdNumberControllers[i].text,
                                  imageBytes: _ovdImageBytesCache[i]!,
                                  expiryDate: _ovdExpiryControllers[i].text,
                                  locationData: autoLocData,
                                );
                              }
                            }
                            if (_aadhaarBackFile == null &&
                                _aadhaarBackBytesCache != null) {
                              String aadhaarDocNumber = "";
                              String aadhaarExpiry = "";
                              for (int i = 0; i < 3; i++) {
                                if (_ovdTypes[i] == "Aadhaar Card") {
                                  aadhaarDocNumber =
                                      _ovdNumberControllers[i].text;
                                  aadhaarExpiry = _ovdExpiryControllers[i].text;
                                  break;
                                }
                              }
                              await _uploadImageInstantly(
                                imageSlot: "OVD4",
                                documentType: "Aadhaar Card",
                                documentNumber: aadhaarDocNumber,
                                imageBytes: _aadhaarBackBytesCache!,
                                expiryDate: aadhaarExpiry,
                                locationData: autoLocData,
                              );
                            }
                          }
                        }

                        // ✅ Safe OVD location getter
                        String getLoc(int index, String key) {
                          return (_ovdLocationData[index] != null &&
                                  (_ovdLocationData[index]![key]?.isNotEmpty ??
                                      false))
                              ? _ovdLocationData[index]![key]!
                              : "";
                        }

                        String getLocDate(int index) {
                          return (_ovdLocationData[index] != null &&
                                  (_ovdLocationData[index]!['captureDate']
                                          ?.isNotEmpty ??
                                      false))
                              ? _ovdLocationData[index]!['captureDate']!
                              : currentIso;
                        }

                        // ✅ Safe nominee helper
                        String nomineeText(
                          int i,
                          String Function(dynamic n) fn,
                        ) {
                          return _nominees.length > i ? fn(_nominees[i]) : "";
                        }

                        int nomineeInt(int i, String Function(dynamic n) fn) {
                          return _nominees.length > i
                              ? (int.tryParse(fn(_nominees[i])) ?? 0)
                              : 0;
                        }

                        String nomineeDob(int i) {
                          return _nominees.length > i
                              ? (convertDate(_nominees[i].dobController.text) ??
                                    currentIso)
                              : currentIso;
                        }

                        Future<int?> getUserId() async {
                          final prefs = await SharedPreferences.getInstance();
                          return prefs.getInt('userID');
                        }

                        int? userId = await getUserId();

                        if (userId != null) {
                          print("User ID: $userId");
                        }

                        // ✅ FLAT payload — no "request" wrapper (matches Swagger)
                        final Map<String, dynamic> data = {
                          "aadharNumber": _aadhaarController.text.isNotEmpty
                              ? _aadhaarController.text
                              : _aadhaarCkycController.text,
                          "panNumber": _panNumberController.text,
                          "fullName": _fullNameController.text,
                          "nameInMarathi": _nameMarathiController.text,
                          "fatherOrHusbandName":
                              _fatherHusbandNameController.text,
                          "motherName": _motherNameController.text,
                          "dob": convertDate(_dobController.text) ?? currentIso,
                          "gender": _selectedGender ?? "",
                          "maritalStatus": _selectedMaritalStatus ?? "",
                          "nationality": _selectedNationality ?? "",
                          "residentialStatus": _selectedResidentialStatus ?? "",
                          "religion": _religionController.text,
                          "category": _selectedCategory ?? "",
                          "photoBase64": "",
                          "signatureBase64": "",
                          "ovdImg1Base64": "",
                          "ovdImg2Base64": "",
                          "ovdImg3Base64": "",
                          "ovdImg4Base64": "",
                          "form60_61_ImgBase64": "",

                          // Current address
                          "currentAddress": _currentAddressController.text,
                          "currentCity": _villageCityController.text,
                          "currentTaluka": _talukaController.text,
                          "currentDistrict": _districtController.text,
                          "currentState": _stateController.text,
                          "currentPinCode": _pinCodeController.text,
                          "currentCountry": _countryController.text,

                          // Permanent address
                          "isPermanentSame":
                              _selectedPermanentAddressSame ==
                              "Same as Current",
                          "permanentAddress": _permanentAddressController.text,
                          "permanentCity": _permVillageCityController.text,
                          "permanentTaluka": _permTalukaController.text,
                          "permanentDistrict": _permDistrictController.text,
                          "permanentState": _permStateController.text,
                          "permanentPinCode": _permPinCodeController.text,
                          "permanentCountry": _permCountryController.text,

                          // OVD 1
                          "ovdType_1": _ovdTypes[0] ?? "",
                          "ovdNumber_1": _ovdNumberControllers[0].text,
                          "ovdExpiryDate_1":
                              const [
                                    'Passport',
                                    'Driving Licence',
                                    'NREGA Job Card',
                                  ].contains(_ovdTypes[0]) &&
                                  _ovdExpiryControllers[0].text
                                      .trim()
                                      .isNotEmpty
                              ? convertExpiry(_ovdExpiryControllers[0].text)
                              : null,

                          // OVD 2
                          "ovdType_2": _ovdTypes[1] ?? "",
                          "ovdNumber_2": _ovdNumberControllers[1].text,
                          "ovdExpiryDate_2":
                              const [
                                    'Passport',
                                    'Driving Licence',
                                    'NREGA Job Card',
                                  ].contains(_ovdTypes[1]) &&
                                  _ovdExpiryControllers[1].text
                                      .trim()
                                      .isNotEmpty
                              ? convertExpiry(_ovdExpiryControllers[1].text)
                              : null,

                          // OVD 3 — only if user added 3rd OVD
                          "ovdType_3": _ovdCount >= 3
                              ? (_ovdTypes[2] ?? "")
                              : "",
                          "ovdNumber_3": _ovdCount >= 3
                              ? _ovdNumberControllers[2].text
                              : "",
                          "ovdExpiryDate_3":
                              (_ovdCount >= 3 &&
                                  const [
                                    'Passport',
                                    'Driving Licence',
                                    'NREGA Job Card',
                                  ].contains(_ovdTypes[2]) &&
                                  _ovdExpiryControllers[2].text
                                      .trim()
                                      .isNotEmpty)
                              ? convertExpiry(_ovdExpiryControllers[2].text)
                              : null,

                          "addressProofType": _selectedAddressProof ?? "",
                          "addressProofNumber":
                              "", // populate if you have a controller for this
                          "formType": _form60Status,

                          "mobileNumber": _mobileNumberController.text,
                          "alternateMobile": _alternateMobileController.text,
                          "email": _emailController.text,
                          "occupation": _selectedOccupation ?? "",
                          "employerName": _employerNameController.text,
                          "designation": _designationController.text,
                          "annualIncome": _selectedAnnualIncome ?? "",
                          "sourceOfFunds": _selectedSourceOfFunds ?? "",
                          "isPEP": _selectedPep == "Yes",
                          "isRelatedToPEP": _selectedRelatedPep == "Yes",

                          // ✅ Nominee 0
                          "nomineeName": _nominees.isNotEmpty
                              ? _nominees[0].fullNameController.text
                              : "",
                          "nomineeRelationship": _nominees.isNotEmpty
                              ? _nominees[0].relationshipController.text
                              : "",
                          "nomineeDOB": _nominees.isNotEmpty
                              ? (convertDate(_nominees[0].dobController.text) ??
                                    currentIso)
                              : currentIso,
                          "nomineeAge": _nominees.isNotEmpty
                              ? (int.tryParse(
                                      _nominees[0].ageController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeSharePercent": _nominees.isNotEmpty
                              ? (int.tryParse(
                                      _nominees[0].shareController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeAddress": "", // ✅ no UI field, send empty
                          "guardianName": _nominees.isNotEmpty
                              ? _nominees[0]
                                    .guardianAddressController
                                    .text // ✅ only controller available
                              : "",

                          // Static / server-filled fields
                          "branchCode": "",
                          "kycNumber": "",
                          "dateOfApplication": currentIso,
                          "placeOfApplication": "",
                          "namePrefix": "",
                          "nameLast": "",
                          "fatherSpouseNamePrefix": "",
                          "mobileISDCode": "",
                          "cifid": "",
                          "branchName": "",

                          // ✅ Nominee 1
                          "nomineeName1": _nominees.length > 1
                              ? _nominees[1].fullNameController.text
                              : "",
                          "nomineeRelationship1": _nominees.length > 1
                              ? _nominees[1].relationshipController.text
                              : "",
                          "nomineeDOB1": _nominees.length > 1
                              ? (convertDate(_nominees[1].dobController.text) ??
                                    currentIso)
                              : currentIso,
                          "nomineeAge1": _nominees.length > 1
                              ? (int.tryParse(
                                      _nominees[1].ageController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeSharePercent1": _nominees.length > 1
                              ? (int.tryParse(
                                      _nominees[1].shareController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeAddress1": "", // ✅ no UI field, send empty
                          "guardianName1": _nominees.length > 1
                              ? _nominees[1]
                                    .guardianAddressController
                                    .text // ✅ only controller available
                              : "",

                          // ✅ Nominee 2
                          "nomineeName2": _nominees.length > 2
                              ? _nominees[2].fullNameController.text
                              : "",
                          "nomineeRelationship2": _nominees.length > 2
                              ? _nominees[2].relationshipController.text
                              : "",
                          "nomineeDOB2": _nominees.length > 2
                              ? (convertDate(_nominees[2].dobController.text) ??
                                    currentIso)
                              : currentIso,
                          "nomineeAge2": _nominees.length > 2
                              ? (int.tryParse(
                                      _nominees[2].ageController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeSharePercent2": _nominees.length > 2
                              ? (int.tryParse(
                                      _nominees[2].shareController.text,
                                    ) ??
                                    0)
                              : 0,
                          "nomineeAddress2": "", // ✅ no UI field, send empty
                          "guardianName2": _nominees.length > 2
                              ? _nominees[2]
                                    .guardianAddressController
                                    .text // ✅ only controller available
                              : "",

                          // OVD location metadata
                          "ovD1_CaptureDate": getLocDate(0),
                          "ovD1_Latitude": getLoc(0, 'latitude'),
                          "ovD1_Longitude": getLoc(0, 'longitude'),
                          "ovD1_Location": getLoc(0, 'location'),

                          "ovD2_CaptureDate": getLocDate(1),
                          "ovD2_Latitude": getLoc(1, 'latitude'),
                          "ovD2_Longitude": getLoc(1, 'longitude'),
                          "ovD2_Location": getLoc(1, 'location'),

                          "ovD3_CaptureDate": getLocDate(2),
                          "ovD3_Latitude": getLoc(2, 'latitude'),
                          "ovD3_Longitude": getLoc(2, 'longitude'),
                          "ovD3_Location": getLoc(2, 'location'),

                          "ovD4_CaptureDate": currentIso,
                          "ovD4_Latitude": "",
                          "ovD4_Longitude": "",
                          "ovD4_Location": "",
                          "submittedByUserId": userId,
                        };

                        debugPrint('--- SUBMIT PAYLOADddd ---');
                        log(json.encode(data));

                        // ✅ Send flat — NO {"request": data} wrapper

                        final referenceId =
                            (widget.customerData['referenceID'] ??
                                    widget.customerData['customerId'] ??
                                    '')
                                .toString();
                        final response = await _service.updateProfile(
                          referenceId,
                          data,
                        );
                        if (mounted) setState(() => _isSubmitting = false);
                        if (response['success'] == true) {
                          final String msg =
                              response['data']?['message'] ??
                              'Customer Profile Updated Successfully!';
                          final dynamic customerId =
                              response['data']?['referenceID'] ??
                              response['data']?['customerId'];

                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Success'),
                                content: Text(
                                  '$msg\nCustomer Reference Number: ${customerId ?? "N/A"}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _flushMemory();
                                      _clearFormRecoveryPrefs();
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(context); // back to caller
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to submit registration. Check log for details.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e, stack) {
                        if (mounted) setState(() => _isSubmitting = false);
                        debugPrint('Submit error: $e\n$stack');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A6A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentFormStep < _totalSteps - 1
                            ? "Save & Continue"
                            : "Submit",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    Widget currentSection;

    switch (_currentFormStep) {
      case 0:
        currentSection = _buildPersonalDetails();

        break;

      case 1:
        currentSection = _buildAddressDetails();

        break;

      case 2:
        currentSection = _buildKycDetails();

        break;

      case 3:
        currentSection = _buildContactDetails();

        break;

      case 4:
        currentSection = _buildOccupationDetails();

        break;

      case 5:
      default:
        currentSection = _buildNomineeDetails();

        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        currentSection,

        const SizedBox(height: 32),

        _buildFormNavigation(),

        const SizedBox(height: 8),

        Center(child: const VersionTrackerText(darkText: true)),
      ],
    );
  }

  Widget _buildAadhaarVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aadhaar Verification",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.darkNavy, // Ensure AppColors is imported
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Enter your 12-digit Aadhaar number to continue",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Main card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Aadhaar Number Field ---
              const Text(
                "AADHAAR NUMBER",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  readOnly: _isOtpSent,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Enter 12-digit Aadhaar",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    counterText:
                        "", // Hide default counter text below the field
                    // Native Borders
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.tealAccent,
                        width: 1.5,
                      ),
                    ),

                    // Replaces the Expanded/Row setup for the counter
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centers text vertically
                        children: [
                          Text(
                            "${_aadhaarController.text.length}/12",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),

              // --- OTP Field (Shown after Send OTP) ---
              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                const Text(
                  "OTP",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Enter 6-digit OTP",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      counterText: "",

                      // Native Borders
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.tealAccent.withOpacity(0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.tealAccent.withOpacity(0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.tealAccent,
                          width: 1.5,
                        ),
                      ),

                      // Replaces the Expanded/Row setup for the counter
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${_otpController.text.length}/6",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isAadhaarLoading
                      ? null
                      : (_isOtpSent ? _verifyOtp : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAadhaarLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isOtpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // --- Resend OTP Button ---
              if (_isOtpSent) ...[
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _isOtpSent = false;
                      _otpController.clear();
                    }),
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: AppColors.tealAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Step 1/11 = Aadhaar verification, Steps 2–7 = form sections

    const stepInfo = [
      {
        "title": "Aadhaar Verification",
        "step": "Step 1/7",
        "pct": "14%",
        "val": 0.14,
      },
      {
        "title": "Personal Details",
        "step": "Step 2/7",
        "pct": "28%",
        "val": 0.28,
      },
      {
        "title": "Address Details",
        "step": "Step 3/7",
        "pct": "42%",
        "val": 0.42,
      },
      {"title": "KYC Documents", "step": "Step 4/7", "pct": "57%", "val": 0.57},
      {
        "title": "Contact Details",
        "step": "Step 5/7",
        "pct": "71%",
        "val": 0.71,
      },
      {
        "title": "Occupation & Income",
        "step": "Step 6/7",
        "pct": "85%",
        "val": 0.85,
      },
      {
        "title": "Nominee Details",
        "step": "Step 7/7",
        "pct": "100%",
        "val": 1.0,
      },
    ];

    // Index 0 = Aadhaar step, indices 1–6 = form steps

    final int headerIndex = _isAadhaarVerified ? (_currentFormStep + 1) : 0;

    final info = stepInfo[headerIndex.clamp(0, stepInfo.length - 1)];

    final String headerTitle = info["title"] as String;

    final String headerStep = info["step"] as String;

    final String headerPercentage = info["pct"] as String;

    final double headerProgressValue = info["val"] as double;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E4A),

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,

                vertical: 16.0,
              ),

              child: Row(
                children: [
                  Container(
                    width: 44,

                    height: 44,

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    alignment: Alignment.center,

                    child: const Text(
                      "C°",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 20,

                        color: Color(0xFF0F1E4A),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "CoopSeva",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              "360°",

                              style: TextStyle(
                                color: Color(0xFFFFC107),

                                fontSize: 13,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 4),

                            Text(
                              "Account Opening",

                              style: TextStyle(
                                color: Color(0xFFFFC107),

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Text(
                    headerStep,

                    style: const TextStyle(
                      color: Color(0xFFFFC107),

                      fontWeight: FontWeight.bold,

                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,

                vertical: 8.0,
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        headerTitle,

                        style: const TextStyle(
                          color: Colors.white70,

                          fontSize: 14,
                        ),
                      ),

                      Text(
                        headerPercentage,

                        style: const TextStyle(
                          color: Color(0xFFFFC107),

                          fontSize: 14,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: headerProgressValue,

                    backgroundColor: Colors.white30,

                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFC107),
                    ),

                    borderRadius: BorderRadius.circular(12),

                    minHeight: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: AppColors.bgGrey,

                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),

                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),

                  child: SingleChildScrollView(
                    controller: _scrollController,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,

                      vertical: 32.0,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        if (!_isAadhaarVerified) _buildAadhaarVerification(),
                        // if (!_isAadhaarVerified) _buildKycDetails(),
                        if (_isAadhaarVerified) _buildForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;

  final double strokeWidth;

  final double gap;

  DottedBorderPainter({
    required this.color,

    this.strokeWidth = 1.0,

    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),

      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);

    Path dashPath = Path();

    double distance = 0.0;

    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + gap),

          Offset.zero,
        );

        distance += gap * 2;
      }

      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

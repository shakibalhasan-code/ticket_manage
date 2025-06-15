// FileReportScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/controllers/report_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/distributor_model.dart';
import 'package:workflowx/core/models/product_model.dart';
import 'package:workflowx/core/themes/app_colors.dart';

class FileReportScreen extends StatefulWidget {
  final Product? product;
  final Map<String, dynamic>? initialData;

  const FileReportScreen({super.key, this.product, this.initialData});

  @override
  State<FileReportScreen> createState() => _FileReportScreenState();
}

class _FileReportScreenState extends State<FileReportScreen> {
  final ReportController reportController = Get.put(ReportController());
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _issueDescriptionController =
      TextEditingController();

  String? selectedUserType;
  DistributorModel? selectedDistributor;

  final List<String> userTypes = ['Applicator', 'Distributor'];
  final List<String> issueTypes = [
    'Hardware',
    'Software',
    'Connectivity',
    'Battery',
    'Physical Damage',
    'Other',
  ];
  List<String> selectedIssueTypes = [];
  List<XFile> selectedFiles = [];
  String? customIssueText;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    selectedUserType =
        (widget.initialData?['userType'] as String?) ?? 'Applicator';
    if (!userTypes.contains(selectedUserType)) {
      selectedUserType = 'Applicator';
    }

    if (widget.initialData != null) {
      final data = widget.initialData!;

      if (data['phone'] is String) {
        _numberController.text = data['phone'] as String;
      }
      if (data['issue'] is List) {
        final issuesFromData = List<dynamic>.from(data['issue'] as List);
        selectedIssueTypes = [];
        List<String> unknownIssuesForCustomText = [];

        for (var issueItem in issuesFromData) {
          if (issueItem is String) {
            if (issueTypes.contains(issueItem)) {
              selectedIssueTypes.add(issueItem);
            } else {
              if (!selectedIssueTypes.contains('Other')) {
                selectedIssueTypes.add('Other');
              }
              unknownIssuesForCustomText.add(issueItem);
            }
          }
        }
        if (unknownIssuesForCustomText.isNotEmpty) {
          customIssueText = unknownIssuesForCustomText.join(", ");
        }
      }
      String mainDescription = (data['description'] as String?) ?? '';
      _issueDescriptionController.text = mainDescription;
      String note = (data['note'] as String?) ?? '';
      if (note.isNotEmpty) {
        bool otherIsOnlyIssueAndDescIsNote =
            selectedIssueTypes.contains('Other') &&
            selectedIssueTypes.length == 1 &&
            (customIssueText == note || mainDescription == note);

        if (!otherIsOnlyIssueAndDescIsNote) {
          if (_issueDescriptionController.text.isNotEmpty) {
            _issueDescriptionController.text += "\nNote: $note";
          } else {
            _issueDescriptionController.text = "Note: $note";
          }
        }
      }
      if (selectedIssueTypes.contains('Other') &&
          (customIssueText == null || customIssueText!.isEmpty)) {
        if (note.isNotEmpty) {
          customIssueText = note;
        } else if (selectedIssueTypes.length == 1) {
          customIssueText = mainDescription;
        }
      }
    } else {
      selectedUserType = 'Applicator';
    }
  }

  Future<void> _pickMedia() async {
    if (selectedFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can select up to 5 images only.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (pickedImages.isNotEmpty) {
        final combinedFiles = [...selectedFiles, ...pickedImages];
        if (combinedFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Max 5 images allowed. Some images were not added.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => selectedFiles = combinedFiles.sublist(0, 5));
        } else {
          setState(() => selectedFiles = combinedFiles);
        }
      }
    } catch (e) {
      debugPrint('Pick media error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleIssueType(String issueType) {
    setState(() {
      if (selectedIssueTypes.contains(issueType)) {
        selectedIssueTypes.remove(issueType);
        if (issueType == 'Other') customIssueText = null;
      } else {
        selectedIssueTypes.add(issueType);
      }
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _serialNumberController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }

  void _submitTicketHandler() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // *** ADDED: Validation for applicator selection ***
    if (selectedUserType == 'Applicator' && selectedDistributor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an applicator from the list.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedIssueTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one issue type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedIssueTypes.contains('Other') &&
        (customIssueText == null || customIssueText!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify the issue if "Other" is selected.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String finalDescription = _issueDescriptionController.text.trim();
    if (selectedIssueTypes.contains('Other') &&
        customIssueText != null &&
        customIssueText!.trim().isNotEmpty) {
      if (finalDescription.isNotEmpty) {
        finalDescription += "\n\nOther Issue: ${customIssueText!.trim()}";
      } else {
        finalDescription = "Other Issue: ${customIssueText!.trim()}";
      }
    }

    if (finalDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue description cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // *** MODIFIED: Pass distributorId to the controller ***
    bool success = await reportController.submitNewReport(
      productId: widget.product?.sId,
      phoneNumber: _numberController.text,
      userType: selectedUserType,
      distributorId: selectedDistributor?.sId, // Pass the ID here
      productSerialNumber: _serialNumberController.text,
      issueTypes: selectedIssueTypes,
      issueDescription: finalDescription,
      imageFiles: selectedFiles,
    );

    if (success) {
      Get.back(); // Navigate back on success
    }
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String? imageUrl =
        (product?.image != null && product!.image!.isNotEmpty)
            ? '${ApiEndpoints.baseImageUrl}/${product.image}'
            : null;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          product != null
              ? 'Report for ${product.model}'
              : 'File a General Report',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (product != null) ...[
                  Text(
                    'Product Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        if (imageUrl != null) const SizedBox(height: 16),
                        _buildDetailRow('Model', product.model),
                        _buildDetailRow('Description', product.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Your Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _numberController,
                  'Phone Number *',
                  'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _serialNumberController,
                  'Serial Number *',
                  'Enter product serial number',
                  keyboardType: TextInputType.text,
                  isRequired: true,
                ),
                const SizedBox(height: 20),
                Text(
                  'User Type *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      userTypes.map((userType) {
                        bool isSelected = selectedUserType == userType;
                        return ChoiceChip(
                          label: Text(userType),
                          selected: isSelected,
                          onSelected:
                              (selected) => setState(() {
                                if (selected) {
                                  selectedUserType = userType;
                                  if (userType != 'Applicator') {
                                    selectedDistributor = null;
                                  }
                                }
                              }),
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black87,
                          ),
                        );
                      }).toList(),
                ),
                if (selectedUserType == 'Applicator')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Obx(
                      () => DropdownButtonFormField<DistributorModel>(
                        value: selectedDistributor,
                        items:
                            reportController.distributors.map((
                              DistributorModel distributor,
                            ) {
                              return DropdownMenuItem<DistributorModel>(
                                value: distributor,
                                child: Text(
                                  distributor.shopName ?? 'Unnamed Applicator',
                                ),
                              );
                            }).toList(),
                        onChanged: (DistributorModel? newValue) {
                          setState(() {
                            selectedDistributor = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Applicator *',
                          hintText: 'Choose an applicator from the list',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an applicator.';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Select Issue Type(s) *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children:
                      issueTypes.map((issueType) {
                        final isSelected = selectedIssueTypes.contains(
                          issueType,
                        );
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.42,
                          child: CheckboxListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              issueType,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: isSelected,
                            onChanged: (_) => _toggleIssueType(issueType),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        );
                      }).toList(),
                ),
                if (selectedIssueTypes.contains('Other'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: _buildTextField(
                      null,
                      'Specify "Other" Issue *',
                      'Describe the other issue here',
                      initialValue: customIssueText,
                      onChanged: (val) => setState(() => customIssueText = val),
                      maxLines: 2,
                      isRequired: true,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Describe the Issue in Detail *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  _issueDescriptionController,
                  'Issue Description',
                  'Please provide as much detail as possible...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Upload Supporting Media (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max 5 images.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      selectedFiles.length < 5 ? selectedFiles.length + 1 : 5,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == selectedFiles.length &&
                        selectedFiles.length < 5) {
                      return GestureDetector(
                        onTap: _pickMedia,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade100,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.instance.primaryColor,
                                size: 36,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Add Image",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.instance.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (index >= selectedFiles.length) {
                      return const SizedBox.shrink();
                    }
                    final file = selectedFiles[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap:
                                () => setState(
                                  () => selectedFiles.removeAt(index),
                                ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Obx(
                  () => SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          reportController.isLoading.value
                              ? null
                              : _submitTicketHandler,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.instance.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          reportController.isLoading.value
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : const Text(
                                'Submit Report',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController? controller,
    String label,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
    bool isRequired = false,
    bool isEmail = false,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            if (label == 'Issue Description' &&
                selectedIssueTypes.contains('Other') &&
                customIssueText != null &&
                customIssueText!.trim().isNotEmpty) {
              return null;
            }
            return '$label is required.';
          }
          if (isEmail) {
            if (value != null &&
                value.isNotEmpty &&
                !GetUtils.isEmail(value.trim())) {
              return 'Please enter a valid email address.';
            }
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/controllers/report_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/product_model.dart';
import 'package:workflowx/core/themes/app_colors.dart';

class FileReportScreen extends StatefulWidget {
  final Product? product; // Made nullable to handle general report filing too
  const FileReportScreen({
    super.key,
    this.product,
  }); // Allow product to be optional

  @override
  State<FileReportScreen> createState() => _FileReportScreenState();
}

class _FileReportScreenState extends State<FileReportScreen> {
  // Get an instance of ReportController
  final ReportController reportController = Get.put(ReportController());

  final ImagePicker _picker = ImagePicker();
  final _formKey =
      GlobalKey<FormState>(); // Add a GlobalKey for Form validation

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _issueDescriptionController =
      TextEditingController();

  String? selectedUserType = 'Customer';
  final List<String> userTypes = ['Customer', 'Distributor'];
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
    _issueDescriptionController.dispose();
    // It's good practice to dispose GetX controllers if they are only used by this screen
    // and `permanent: false` (default) was used in Get.put.
    // However, if Get.put is here, it might be better in initState or as a final field
    // Get.delete<ReportController>(); // If appropriate for your app structure
    super.dispose();
  }

  void _submitTicketHandler() async {
    if (!_formKey.currentState!.validate()) {
      // Use Form key for validation
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

    // Call the controller's method
    bool success = await reportController.submitNewReport(
      productId: widget.product?.sId,
      productModel: widget.product?.model,

      phoneNumber: _numberController.text,
      userType: selectedUserType,
      issueTypes: selectedIssueTypes,
      customIssueDetail: customIssueText,
      issueDescription: _issueDescriptionController.text,
      imageFiles: selectedFiles,
    );

    if (success) {
      // Optionally, clear the form or navigate back
      // _formKey.currentState?.reset();
      // setState(() {
      //   selectedIssueTypes.clear();
      //   selectedFiles.clear();
      //   customIssueText = null;
      //   selectedUserType = 'Customer';
      // });
      Get.back(); // Navigate back after successful submission
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
    final product = widget.product; // Can be null if filing a general report
    final String? imageUrl =
        (product?.image != null && product!.image!.isNotEmpty)
            ? '${ApiEndpoints.baseImageUrl}/${product.image}'
            : null;

    return Scaffold(
      appBar: AppBar(
        // ... (appBar code remains the same)
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
          onPressed: () => Get.back(), // Use Get.back()
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            // Wrap ListView with Form
            key: _formKey,
            child: ListView(
              children: [
                if (product != null) ...[
                  // Show product info only if a product is passed
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
                        _buildDetailRow('Brand', product.brandName),
                        _buildDetailRow('Description', product.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Your Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 12),
                _buildTextField(
                  _numberController,
                  'Phone Number *',
                  'Enter your phone number',
                  keyboardType: TextInputType.phone,
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
                                if (selected) selectedUserType = userType;
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
                  'Please provide as much detail as possible about the problem...',
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
                  // ... (GridView code remains largely the same)
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
                    if (index >= selectedFiles.length)
                      return const SizedBox.shrink();
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

                // Submit Button with Loading State
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
    bool isRequired = false, // For TextFormField validation
    bool isEmail = false, // For email validation
  }) {
    return Padding(
      // Add padding around each text field for better spacing
      padding: const EdgeInsets.only(bottom: 0.0), // Adjusted from 8.0
      child: TextFormField(
        // Changed to TextFormField
        controller: controller,
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
          // Add validator
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label is required.';
          }
          if (isEmail) {
            if (value != null &&
                value.isNotEmpty &&
                !GetUtils.isEmail(value.trim())) {
              return 'Please enter a valid email address.';
            }
          }
          return null; // Return null if valid
        },
        autovalidateMode:
            AutovalidateMode.onUserInteraction, // Validate as user types
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/widgets/date_picker_widget.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trippify/core/services/supabase_service.dart';
import 'dart:io';

import 'package:trippify/presentation/widgets/snackbars/general_error_snackbar.dart';

class CreateTripTab extends StatefulWidget {
  const CreateTripTab({super.key});

  @override
  State<CreateTripTab> createState() => _CreateTripTabState();
}

class _CreateTripTabState extends State<CreateTripTab> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController tripLocationController = TextEditingController();
  final TextEditingController tripDescriptionController =
      TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  XFile? pickedImage;
  bool isUploadingImage = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) {
        log('No image selected');
        return;
      }

      log('Image selected: ${image.path}');
      setState(() {
        pickedImage = image;
      });

      final tripVM = Provider.of<TripViewmodel>(context, listen: false);
      tripVM.clearValidationErrors();
    } catch (e) {
      log('Error picking image: $e');
      showGeneralErrorSnackbar(
        message: 'Failed to pick image: $e',
        context: context,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<String?> _uploadImage() async {
    if (pickedImage == null) return null;

    try {
      setState(() => isUploadingImage = true);

      final file = File(pickedImage!.path);
      if (!await file.exists()) {
        log('File does not exist: ${pickedImage!.path}');
        setState(() => isUploadingImage = false);
        return null;
      }

      final imageUrl = await SupabaseService.uploadImage(
        filePath: pickedImage!.path,
        fileName: pickedImage!.name,
      );

      log('Upload successful, URL: $imageUrl');
      setState(() => isUploadingImage = false);
      return imageUrl;
    } catch (e) {
      log('Error uploading image: $e');
      setState(() => isUploadingImage = false);
      showGeneralErrorSnackbar(
        message: 'Failed to upload image: $e',
        context: context,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripVM = Provider.of<TripViewmodel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCreating = tripVM.isLoading || isUploadingImage;

    return Stack(
      children: [
        Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 70.h,
              bottom: 120.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create a Trip",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : neutral900,
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap:
                      isCreating
                          ? null
                          : () async {
                            await _pickImage();
                          },
                  child: Container(
                    height: 140.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color:
                            tripVM.imageError
                                ? accentOrange
                                : (isDarkMode
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : neutral300),
                        width: tripVM.imageError ? 2 : 1,
                      ),
                      color:
                          isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : neutral100,
                    ),
                    child:
                        isUploadingImage
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Uploading image...',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color:
                                          isDarkMode ? neutral400 : neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : pickedImage == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: secondaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 32.r,
                                    color: secondaryColor,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Add Trip Photo',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDarkMode ? Colors.white : neutral900,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Tap to select',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDarkMode ? neutral400 : neutral600,
                                  ),
                                ),
                              ],
                            )
                            : Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(
                                    File(pickedImage!.path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: const Icon(Icons.error_outline),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: tripNameController,
                  enabled: !isCreating,
                  decoration: const InputDecoration(
                    labelText: "Trip Name",
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter trip name';
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: tripLocationController,
                  enabled: !isCreating,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    prefixIcon: Icon(Icons.place),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter location';
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: tripDescriptionController,
                  enabled: !isCreating,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                    hintText: "Tell us about your trip...",
                  ),
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 500,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: DatePickerWidget(
                        label:
                            startDate != null
                                ? startDate!.toLocal().toString().split(' ')[0]
                                : 'Start Date',
                        isError: tripVM.startDateError,
                        enabled: !isCreating,
                        onTap: () async {
                          tripVM.clearValidationErrors();
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null)
                            setState(() => startDate = picked);
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: DatePickerWidget(
                        label:
                            endDate != null
                                ? endDate!.toLocal().toString().split(' ')[0]
                                : 'End Date',
                        isError: tripVM.endDateError,
                        enabled: !isCreating,
                        onTap: () async {
                          tripVM.clearValidationErrors();
                          final base = startDate ?? DateTime.now();

                          DateTime initialDate;
                          if (endDate != null && !endDate!.isBefore(base)) {
                            initialDate = endDate!;
                          } else {
                            initialDate = base;
                          }

                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: base,
                            lastDate: DateTime(base.year + 5),
                          );
                          if (picked != null) setState(() => endDate = picked);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                PrimaryButton(
                  label: isCreating ? "Creating..." : "Create Trip",
                  onTap:
                      isCreating
                          ? null
                          : () async {
                            if (!formKey.currentState!.validate()) {
                              showGeneralErrorSnackbar(
                                message: 'Please fill all required fields',
                                context: context,
                              );
                              return;
                            }

                            final isValid = tripVM.validateTripForm(
                              context: context,
                              hasImage: pickedImage != null,
                              startDate: startDate,
                              endDate: endDate,
                            );

                            if (!isValid) {
                              return;
                            }

                            final imageUrl = await _uploadImage();
                            if (imageUrl == null) {
                              showGeneralErrorSnackbar(
                                message:
                                    'Failed to upload image. Please try again.',
                                context: context,
                              );
                              return;
                            }

                            final success = await tripVM.createTrip(
                              context: context,
                              name: tripNameController.text,
                              location: tripLocationController.text,
                              description: tripDescriptionController.text,
                              startDate: startDate!,
                              endDate: endDate!,
                              imageUrl: imageUrl,
                            );

                            if (success) {
                              tripNameController.clear();
                              tripLocationController.clear();
                              tripDescriptionController.clear();
                              tripVM.clearValidationErrors();
                              setState(() {
                                startDate = null;
                                endDate = null;
                                pickedImage = null;
                              });
                            }
                          },
                ),
              ],
            ),
          ),
        ),
        if (isCreating)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? neutral800 : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Creating your trip...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : neutral900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

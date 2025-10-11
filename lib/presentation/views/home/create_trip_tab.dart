import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/widgets/date_picker_widget.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CreateTripTab extends StatefulWidget {
  const CreateTripTab({super.key});

  @override
  State<CreateTripTab> createState() => _CreateTripTabState();
}

class _CreateTripTabState extends State<CreateTripTab> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController tripLocationController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  XFile? pickedImage;
  bool isUploadingImage = false;
  String? uploadedImageUrl;
  bool startDateError = false;
  bool endDateError = false;
  bool imageError = false;

  Future<String?> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) {
        print('No image selected');
        return null;
      }

      print('Image selected: ${image.path}');
      setState(() {
        pickedImage = image;
        isUploadingImage = true;
      });

      final file = File(image.path);
      if (!await file.exists()) {
        print('File does not exist: ${image.path}');
        setState(() => isUploadingImage = false);
        return null;
      }

      final storageRef = FirebaseStorage.instance.ref().child(
        'trip_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
      );

      print('Uploading to: ${storageRef.fullPath}');
      final uploadTask = await storageRef.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      print('Upload successful, URL: $url');
      setState(() {
        isUploadingImage = false;
        uploadedImageUrl = url;
      });
      return url;
    } catch (e) {
      print('Error picking/uploading image: $e');
      setState(() {
        isUploadingImage = false;
        pickedImage = null;
        uploadedImageUrl = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripVM = Provider.of<TripViewmodel>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 50.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.h),
            Text("Create a trip", style: ts24CFFW400),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap:
                  isUploadingImage
                      ? null
                      : () async {
                        imageError = false;
                        await _pickAndUploadImage();
                        setState(() {});
                      },
              child: Container(
                height: 140.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        imageError
                            ? Colors.redAccent
                            : Colors.white.withValues(alpha: 0.2),
                  ),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child:
                    isUploadingImage
                        ? const CircularProgressIndicator()
                        : pickedImage == null
                        ? const Icon(Icons.add_a_photo_outlined)
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                color: Colors.red.withValues(alpha: 0.1),
                                child: const Icon(Icons.error_outline),
                              );
                            },
                          ),
                        ),
              ),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: tripNameController,
              decoration: const InputDecoration(labelText: "Trip Name"),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter trip name';
                return null;
              },
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: tripLocationController,
              decoration: const InputDecoration(labelText: "Location"),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter location';
                return null;
              },
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: DatePickerWidget(
                    label:
                        startDate != null
                            ? startDate!.toLocal().toString().split(' ')[0]
                            : 'Start Date',
                    isError: startDateError,
                    onTap: () async {
                      startDateError = false;
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) setState(() => startDate = picked);
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
                    isError: endDateError,
                    onTap: () async {
                      endDateError = false;
                      final base = startDate ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? base,
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
              label: "Create",
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  final imageUrl = uploadedImageUrl;
                  // Validate photo and dates
                  bool hasError = false;
                  if (imageUrl == null || imageUrl.isEmpty) {
                    imageError = true;
                    hasError = true;
                  }
                  if (startDate == null) {
                    startDateError = true;
                    hasError = true;
                  }
                  if (endDate == null) {
                    endDateError = true;
                    hasError = true;
                  }
                  if (startDate != null &&
                      endDate != null &&
                      endDate!.isBefore(startDate!)) {
                    endDateError = true;
                    hasError = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('End date must be after start date'),
                      ),
                    );
                  }
                  if (hasError) {
                    setState(() {});
                    return;
                  }
                  final success = await tripVM.createTrip(
                    context: context,
                    name: tripNameController.text,
                    location: tripLocationController.text,
                    startDate: startDate!,
                    endDate: endDate!,
                    imageUrl: imageUrl,
                  );

                  if (success) {
                    // Optionally clear fields
                    tripNameController.clear();
                    tripLocationController.clear();
                    setState(() {
                      startDate = null;
                      endDate = null;
                      pickedImage = null;
                      uploadedImageUrl = null;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

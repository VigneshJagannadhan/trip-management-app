import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/widgets/date_picker_widget.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';
import 'package:provider/provider.dart';

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
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: DatePickerWidget(
                    label:
                        endDate != null
                            ? endDate!.toLocal().toString().split(' ')[0]
                            : 'End Date',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
              label: "Create",
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  final success = await tripVM.createTrip(
                    context: context,
                    name: tripNameController.text,
                    location: tripLocationController.text,
                    startDate: startDate ?? DateTime.now(),
                    endDate: endDate ?? DateTime.now().add(Duration(days: 3)),
                  );

                  if (success) {
                    // Optionally clear fields
                    tripNameController.clear();
                    tripLocationController.clear();
                    setState(() {
                      startDate = null;
                      endDate = null;
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/presentation/widgets/primary_button.dart';

class SubscriptionView extends StatefulWidget {
  static const String route = '/subscription';

  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  int selectedPlanIndex = 0; // 0 = monthly, 1 = yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Header
            Text(
              'Upgrade to Premium',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unlock unlimited trips and premium features',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 32.h),

            // Monthly Plan
            _buildPlanCard(
              index: 0,
              title: 'Monthly Plan',
              price: '₹200',
              period: '/month',
              features: [
                'Unlimited trips',
                'Premium support',
                'Advanced analytics',
                'Cancel anytime',
              ],
              badge: null,
            ),
            SizedBox(height: 16.h),

            // Yearly Plan
            _buildPlanCard(
              index: 1,
              title: 'Yearly Plan',
              price: '₹2,000',
              period: '/year',
              features: [
                'Everything in Monthly',
                'Save ₹400 per year',
                'Priority support',
                'Exclusive travel guides',
                'Early access to features',
              ],
              badge: 'BEST VALUE',
              discount: '17% OFF',
            ),
            SizedBox(height: 32.h),

            // Features List
            _buildFeaturesList(),
            SizedBox(height: 32.h),

            // Subscribe Button
            PrimaryButton(
              label:
                  selectedPlanIndex == 0
                      ? 'Subscribe for ₹200/month'
                      : 'Subscribe for ₹2,000/year',
              onTap: () async {
                _handleSubscribe();
              },
            ),
            SizedBox(height: 16.h),

            // Terms
            Text(
              'By subscribing, you agree to our Terms of Service and Privacy Policy. Auto-renewal can be turned off at any time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    String? badge,
    String? discount,
  }) {
    final isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedPlanIndex = index);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color:
              isSelected ? secondaryColor.withValues(alpha: 0.15) : neutral800,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isSelected
                    ? secondaryColor
                    : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (discount != null) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          discount,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentTeal, accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Features
            ...features.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isSelected ? secondaryColor : accentTeal,
                      size: 20.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selection indicator
            if (isSelected) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: secondaryColor, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: neutral800,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.flight_takeoff,
            'Unlimited Trips',
            'Create as many trips as you want without any limits',
          ),
          SizedBox(height: 12.h),
          _buildFeatureItem(
            Icons.people,
            'Team Collaboration',
            'Invite unlimited members to your trips',
          ),
          SizedBox(height: 12.h),
          _buildFeatureItem(
            Icons.cloud_upload,
            'Cloud Storage',
            'Unlimited photo and document storage',
          ),
          SizedBox(height: 12.h),
          _buildFeatureItem(
            Icons.analytics,
            'Analytics',
            'Track your travel statistics and insights',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: secondaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: secondaryColor, size: 20.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSubscribe() {
    final plan = selectedPlanIndex == 0 ? 'Monthly' : 'Yearly';
    final price = selectedPlanIndex == 0 ? '₹200' : '₹2,000';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Subscribe'),
            content: Text(
              'You are subscribing to the $plan plan for $price.\n\nPayment integration will be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment feature coming soon!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}

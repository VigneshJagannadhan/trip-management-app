import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/core/theme/app_styles.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/widgets/chat_tile.dart';

class HomeViewTab extends StatefulWidget {
  const HomeViewTab({super.key});

  @override
  State<HomeViewTab> createState() => _HomeViewTabState();
}

class _HomeViewTabState extends State<HomeViewTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      TripViewmodel tripVM = Provider.of<TripViewmodel>(context, listen: false);
      await tripVM.fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripViewmodel>(
      builder: (context, tripVM, child) {
        return CustomScrollView(
          slivers: [
            const HomeViewSliverAppbar(),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              sliver:
                  tripVM.isLoading
                      ? SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : tripVM.trips.isEmpty
                      ? SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "No trips available",
                            style: ts20CFFFW400,
                          ),
                        ),
                      )
                      : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final trip = tripVM.trips[index];
                          return ChatTile(trip: trip);
                        }, childCount: tripVM.trips.length),
                      ),
            ),
          ],
        );
      },
    );
  }
}

class HomeViewSliverAppbar extends StatelessWidget {
  const HomeViewSliverAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 50.h,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      child: SvgPicture.asset(
                        AppAssets.searchIcon,
                        colorFilter: ColorFilter.mode(
                          colorFFF,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text("Your Trips", style: ts20CFFFW400),
                    CircleAvatar(radius: 20.r),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

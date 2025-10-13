import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/data/models/trip_model.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/widgets/chat_tile.dart';

class HomeViewTab extends StatefulWidget {
  const HomeViewTab({super.key});

  @override
  State<HomeViewTab> createState() => _HomeViewTabState();
}

class _HomeViewTabState extends State<HomeViewTab> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      TripViewmodel tripVM = Provider.of<TripViewmodel>(context, listen: false);
      await tripVM.fetchTrips();
    });
  }

  List<TripModel> getFilteredTrips(List<TripModel> trips) {
    if (searchQuery.isEmpty) return trips;
    return trips.where((trip) {
      final query = searchQuery.toLowerCase();
      return trip.name.toLowerCase().contains(query) ||
          trip.location.toLowerCase().contains(query) ||
          trip.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripViewmodel>(
      builder: (context, tripVM, child) {
        final filteredTrips = getFilteredTrips(tripVM.trips);

        return CustomScrollView(
          slivers: [
            HomeViewSliverAppbar(
              onSearchChanged: (query) {
                setState(() => searchQuery = query);
              },
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: 100.h,
              ),
              sliver:
                  tripVM.isLoading
                      ? SliverFillRemaining(child: _buildLoadingState())
                      : filteredTrips.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final trip = filteredTrips[index];
                          return ChatTile(trip: trip);
                        }, childCount: filteredTrips.length),
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral200,
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.white : secondaryColor,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Loading your trips...",
            style: TextStyle(
              fontSize: 16.sp,
              color:
                  isDarkMode ? Colors.white.withValues(alpha: 0.7) : neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_takeoff,
              size: 60.r,
              color:
                  isDarkMode ? Colors.white.withValues(alpha: 0.5) : neutral400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "No trips yet",
            style: TextStyle(
              fontSize: 24.sp,
              color: isDarkMode ? Colors.white : neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start your adventure by creating\nyour first trip",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color:
                  isDarkMode ? Colors.white.withValues(alpha: 0.6) : neutral600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withValues(alpha: 0.2)
                        : secondaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: isDarkMode ? Colors.white : secondaryColor,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Create Trip",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDarkMode ? Colors.white : secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeViewSliverAppbar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const HomeViewSliverAppbar({super.key, required this.onSearchChanged});

  @override
  State<HomeViewSliverAppbar> createState() => _HomeViewSliverAppbarState();
}

class _HomeViewSliverAppbarState extends State<HomeViewSliverAppbar> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : neutral900;
    final subtextColor =
        isDarkMode ? Colors.white.withValues(alpha: 0.7) : neutral600;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 150.h,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDarkMode
                      ? [neutral900, neutral800, neutral700]
                      : [Colors.white, neutral50, neutral100],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: subtextColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Your Trips",
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : neutral300,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: isDarkMode ? neutral700 : neutral200,
                          child: Icon(
                            Icons.person,
                            color: isDarkMode ? Colors.white : neutral600,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: searchController,
                    onChanged: widget.onSearchChanged,
                    style: TextStyle(color: textColor, fontSize: 15.sp),
                    decoration: InputDecoration(
                      hintText: "Search your trips...",
                      hintStyle: TextStyle(
                        color: subtextColor,
                        fontSize: 15.sp,
                      ),
                      prefixIcon: Icon(Icons.search, color: subtextColor),
                      filled: true,
                      fillColor:
                          isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : neutral300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : neutral300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: secondaryColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

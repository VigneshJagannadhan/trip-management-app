import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/constants/app_assets.dart';
import 'package:trippify/data/models/trip_model.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/user_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/friend_viewmodel.dart';
import 'package:trippify/presentation/views/chat/chat_screen.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripDetailView extends StatefulWidget {
  final String tripId;
  static const String route = '/trip-detail';

  const TripDetailView({super.key, required this.tripId});

  @override
  State<TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<TripDetailView> {
  TripModel? trip;
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, UserModel> memberUsers = {};

  @override
  void initState() {
    super.initState();
    _fetchTrip();
  }

  Future<void> _fetchTrip() async {
    final tripVM = Provider.of<TripViewmodel>(context, listen: false);
    final userVM = Provider.of<UserViewmodel>(context, listen: false);

    final fetchedTrip = await tripVM.fetchTripById(tripId: widget.tripId);
    log('Fetched trip: ${fetchedTrip?.name}');

    final Map<String, UserModel> loadedUsers = {};
    if (fetchedTrip != null) {
      log('Trip has ${fetchedTrip.members.length} members');
      for (String memberId in fetchedTrip.members) {
        log('Fetching user data for: $memberId');
        final user = await userVM.fetchUserById(userId: memberId);
        if (user != null) {
          log('Found user: ${user.displayName} (${user.email})');
          loadedUsers[memberId] = user;
        } else {
          log('User not found in Firestore: $memberId');
        }
      }
      log('Loaded ${loadedUsers.length} users');
    }

    if (mounted) {
      setState(() {
        trip = fetchedTrip;
        memberUsers = loadedUsers;
        isLoading = false;
      });
    }
  }

  bool get isCreator {
    if (trip == null) return false;
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid == trip!.creatorId;
  }

  void _showInviteFriendsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InviteFriendsBottomSheet(tripId: trip!.id),
    );
  }

  Future<void> _deleteTrip() async {
    if (trip == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Trip'),
            content: const Text(
              'Are you sure you want to delete this trip? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: accentOrange),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => isDeleting = true);
      final tripVM = Provider.of<TripViewmodel>(context, listen: false);
      final success = await tripVM.deleteTrip(
        context: context,
        tripId: trip!.id,
      );

      if (success) {
        Navigator.of(context).pop();
      }
      setState(() => isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body:
          isLoading
              ? _buildLoadingState()
              : trip == null
              ? _buildErrorState()
              : _buildTripDetail(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Trip not found',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This trip may have been deleted or you may not have access to it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripInfo(),
                SizedBox(height: 24.h),
                _buildChatButton(),
                SizedBox(height: 24.h),
                _buildTripDetails(),
                SizedBox(height: 24.h),
                if (isCreator) _buildInviteFriendsButton(),
                if (isCreator) SizedBox(height: 24.h),
                _buildMembersSection(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions:
          isCreator
              ? [
                Container(
                  margin: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon:
                        isDeleting
                            ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.delete, color: Colors.white),
                    onPressed: isDeleting ? null : _deleteTrip,
                  ),
                ),
              ]
              : [],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              trip!.imageUrl.isNotEmpty
                  ? trip!.imageUrl
                  : AppAssets.dummyPlaceImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: neutral800,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 64.r,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip!.name,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 18.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        trip!.location,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withValues(alpha: 0.8),
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
    );
  }

  Widget _buildTripInfo() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'Start Date',
          value: _formatDate(trip!.startTime),
        ),
        SizedBox(height: 12.h),
        _buildInfoCard(
          icon: Icons.event,
          title: 'End Date',
          value: _formatDate(trip!.endTime),
        ),
        SizedBox(height: 12.h),
        _buildInfoCard(
          icon: Icons.schedule,
          title: 'Duration',
          value: _getDuration(trip!.startTime, trip!.endTime),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
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
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
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

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ChatScreen.route,
          arguments: {'tripId': trip!.id, 'tripName': trip!.name},
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentTeal, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: accentTeal.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.chat_bubble, color: Colors.white, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Text(
              'Open Group Chat',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.r),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetails() {
    if (trip!.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Description',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: neutral800,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            trip!.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteFriendsButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showInviteFriendsDialog();
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person_add, color: Colors.white, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Add more people to this trip',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18.r),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Members',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trip!.members.length,
          itemBuilder: (context, index) {
            final memberId = trip!.members[index];
            final isCreator = memberId == trip!.creatorId;
            final user = memberUsers[memberId];

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: secondaryColor,
                    backgroundImage:
                        user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                    child:
                        user?.photoUrl == null
                            ? Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20.r,
                            )
                            : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          user?.email ?? memberId,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCreator)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentTeal,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Creator',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start).inDays;
    if (duration == 0) return '1 day';
    if (duration == 1) return '2 days';
    return '${duration + 1} days';
  }
}

class _InviteFriendsBottomSheet extends StatefulWidget {
  final String tripId;

  const _InviteFriendsBottomSheet({required this.tripId});

  @override
  State<_InviteFriendsBottomSheet> createState() =>
      _InviteFriendsBottomSheetState();
}

class _InviteFriendsBottomSheetState extends State<_InviteFriendsBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  List<UserModel> filteredFriends = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => isLoading = true);
    final friendVM = Provider.of<FriendViewmodel>(context, listen: false);
    await friendVM.fetchFriends();
    setState(() {
      filteredFriends = friendVM.friends;
      isLoading = false;
    });
  }

  void _filterFriends(String query) {
    final friendVM = Provider.of<FriendViewmodel>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        filteredFriends = friendVM.friends;
      } else {
        filteredFriends =
            friendVM.friends.where((friend) {
              final lowerQuery = query.toLowerCase();
              return friend.displayName.toLowerCase().contains(lowerQuery) ||
                  friend.email.toLowerCase().contains(lowerQuery);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDarkMode ? neutral600 : neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(Icons.group_add, color: secondaryColor, size: 24.r),
                SizedBox(width: 12.w),
                Text(
                  'Invite Friends to Trip',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : neutral900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: searchController,
              onChanged: _filterFriends,
              decoration: InputDecoration(
                hintText: 'Search your friends...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            _filterFriends('');
                          },
                        )
                        : null,
              ),
            ),
          ),

          SizedBox(height: 16.h),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredFriends.isEmpty
                    ? Center(
                      child: Text(
                        searchController.text.isEmpty
                            ? 'No friends to invite'
                            : 'No friends found',
                        style: TextStyle(
                          color: isDarkMode ? neutral400 : neutral600,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        return _buildFriendInviteTile(friend, isDarkMode);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendInviteTile(UserModel friend, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? neutral700 : neutral50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: secondaryColor,
            backgroundImage:
                friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
            child:
                friend.photoUrl == null
                    ? Icon(Icons.person, color: Colors.white, size: 24.r)
                    : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : neutral900,
                  ),
                ),
                Text(
                  friend.email,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDarkMode ? neutral400 : neutral600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final tripVM = Provider.of<TripViewmodel>(context, listen: false);
              final success = await tripVM.sendTripInvitation(
                context: context,
                tripId: widget.tripId,
                receiverId: friend.uid,
              );
              if (success && mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}

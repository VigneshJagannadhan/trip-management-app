import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/data/models/friend_request_model.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/presentation/viewmodels/friend_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/user_viewmodel.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final friendVM = Provider.of<FriendViewmodel>(context, listen: false);
      friendVM.fetchFriends();
      friendVM.fetchPendingRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? primaryColor : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Tab Bar
            _buildTabBar(isDarkMode),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFriendsList(), _buildFriendRequests()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendDialog(),
        backgroundColor: secondaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Friend',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Friends",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : neutral900,
                ),
              ),
              Consumer<FriendViewmodel>(
                builder: (context, friendVM, _) {
                  final requestCount = friendVM.pendingRequests.length;
                  if (requestCount == 0) return const SizedBox.shrink();

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '$requestCount ${requestCount == 1 ? 'Request' : 'Requests'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : neutral100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? neutral400 : neutral600,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        tabs: const [Tab(text: 'My Friends'), Tab(text: 'Requests')],
      ),
    );
  }

  Widget _buildFriendsList() {
    return Consumer<FriendViewmodel>(
      builder: (context, friendVM, _) {
        if (friendVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (friendVM.friends.isEmpty) {
          return _buildEmptyFriends();
        }

        return Column(
          children: [
            // Search bar
            Padding(padding: EdgeInsets.all(20.w), child: _buildSearchBar()),

            // Friends list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: friendVM.friends.length,
                itemBuilder: (context, index) {
                  final friend = friendVM.friends[index];
                  return _buildFriendTile(friend, friendVM);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : neutral100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral300,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search friends...',
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? neutral400 : neutral600,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFriendTile(UserModel friend, FriendViewmodel friendVM) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral200,
        ),
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
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? neutral400 : neutral600,
            ),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_remove,
                          color: accentOrange,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        const Text('Remove Friend'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        _confirmRemoveFriend(friend, friendVM);
                      });
                    },
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRequests() {
    return Consumer2<FriendViewmodel, UserViewmodel>(
      builder: (context, friendVM, userVM, _) {
        if (friendVM.pendingRequests.isEmpty) {
          return _buildEmptyRequests();
        }

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: friendVM.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = friendVM.pendingRequests[index];
            return FutureBuilder<UserModel?>(
              future: userVM.fetchUserById(userId: request.senderId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final sender = snapshot.data!;
                return _buildRequestTile(request, sender, friendVM);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestTile(
    FriendRequestModel request,
    UserModel sender,
    FriendViewmodel friendVM,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: secondaryColor,
                backgroundImage:
                    sender.photoUrl != null
                        ? NetworkImage(sender.photoUrl!)
                        : null,
                child:
                    sender.photoUrl == null
                        ? Icon(Icons.person, color: Colors.white, size: 28.r)
                        : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : neutral900,
                      ),
                    ),
                    Text(
                      sender.email,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDarkMode ? neutral400 : neutral600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    friendVM.acceptFriendRequest(
                      context: context,
                      requestId: request.id,
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    friendVM.rejectFriendRequest(
                      context: context,
                      requestId: request.id,
                    );
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? neutral400 : neutral600,
                    side: BorderSide(
                      color: isDarkMode ? neutral600 : neutral300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFriends() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80.r,
            color: isDarkMode ? neutral600 : neutral400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No friends yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : neutral900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start adding friends to plan trips together',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? neutral400 : neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequests() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80.r,
            color: isDarkMode ? neutral600 : neutral400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No friend requests',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : neutral900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You don\'t have any pending requests',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? neutral400 : neutral600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddFriendBottomSheet(),
    );
  }

  void _confirmRemoveFriend(UserModel friend, FriendViewmodel friendVM) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Friend'),
            content: Text(
              'Are you sure you want to remove ${friend.displayName} from your friends list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  friendVM.removeFriend(context: context, friendId: friend.uid);
                },
                style: TextButton.styleFrom(foregroundColor: accentOrange),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}

class _AddFriendBottomSheet extends StatefulWidget {
  @override
  State<_AddFriendBottomSheet> createState() => _AddFriendBottomSheetState();
}

class _AddFriendBottomSheetState extends State<_AddFriendBottomSheet> {
  final TextEditingController searchController = TextEditingController();

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
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDarkMode ? neutral600 : neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'Add Friend',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : neutral900,
              ),
            ),
          ),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                final friendVM = Provider.of<FriendViewmodel>(
                  context,
                  listen: false,
                );
                friendVM.searchUsers(query);
              },
              decoration: InputDecoration(
                hintText: 'Search by email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            final friendVM = Provider.of<FriendViewmodel>(
                              context,
                              listen: false,
                            );
                            friendVM.clearSearch();
                          },
                        )
                        : null,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Results
          Expanded(
            child: Consumer<FriendViewmodel>(
              builder: (context, friendVM, _) {
                if (searchController.text.isEmpty) {
                  return Center(
                    child: Text(
                      'Start typing to search for users',
                      style: TextStyle(
                        color: isDarkMode ? neutral400 : neutral600,
                      ),
                    ),
                  );
                }

                if (friendVM.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: isDarkMode ? neutral400 : neutral600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: friendVM.searchResults.length,
                  itemBuilder: (context, index) {
                    final user = friendVM.searchResults[index];
                    return _buildUserSearchTile(user, friendVM, isDarkMode);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchTile(
    UserModel user,
    FriendViewmodel friendVM,
    bool isDarkMode,
  ) {
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
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child:
                user.photoUrl == null
                    ? Icon(Icons.person, color: Colors.white, size: 24.r)
                    : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : neutral900,
                  ),
                ),
                Text(
                  user.email,
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
              final success = await friendVM.sendFriendRequest(
                context: context,
                receiverId: user.uid,
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/theme/app_colors.dart';
import 'package:trippify/data/models/chat_message_model.dart';
import 'package:trippify/data/models/user_model.dart';
import 'package:trippify/presentation/viewmodels/chat_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/user_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final String tripId;
  final String tripName;
  static const String route = '/chat';

  const ChatScreen({super.key, required this.tripId, required this.tripName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Map<String, UserModel> userCache = {};

  @override
  void initState() {
    super.initState();
    _loadChatroom();
  }

  Future<void> _loadChatroom() async {
    final chatVM = Provider.of<ChatViewmodel>(context, listen: false);
    await chatVM.fetchChatroomByTripId(tripId: widget.tripId);
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final chatVM = Provider.of<ChatViewmodel>(context, listen: false);
    final success = await chatVM.sendMessage(
      context: context,
      message: messageController.text,
    );

    if (success) {
      messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? primaryColor : Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tripName,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              'Group Chat',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDarkMode ? neutral400 : neutral600,
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? neutral800 : Colors.white,
        elevation: 1,
      ),
      body: Consumer<ChatViewmodel>(
        builder: (context, chatVM, _) {
          if (chatVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatVM.currentChatroom == null) {
            return _buildNoChatroom();
          }

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: chatVM.messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyChat(isDarkMode);
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data![index];
                        return _buildMessageBubble(message, isDarkMode);
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(isDarkMode),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoChatroom() {
    return const Center(child: Text('Chatroom not available'));
  }

  Widget _buildEmptyChat(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.r,
            color: isDarkMode ? neutral600 : neutral400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : neutral900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? neutral400 : neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isDarkMode) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMe = message.senderId == currentUserId;

    return FutureBuilder<UserModel?>(
      future: _getUserFromCache(message.senderId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? 'User';

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            constraints: BoxConstraints(maxWidth: 0.75.sw),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: EdgeInsets.only(left: 12.w, bottom: 4.h),
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDarkMode ? neutral400 : neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? secondaryColor
                            : (isDarkMode ? neutral800 : neutral100),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMe ? 16.r : 4.r),
                      topRight: Radius.circular(isMe ? 4.r : 16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          isMe
                              ? Colors.white
                              : (isDarkMode ? Colors.white : neutral900),
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: isMe ? 0 : 12.w,
                    right: isMe ? 12.w : 0,
                    top: 4.h,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDarkMode ? neutral500 : neutral500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? neutral800 : Colors.white,
        border: Border(
          top: BorderSide(
            color:
                isDarkMode ? Colors.white.withValues(alpha: 0.1) : neutral200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? neutral700 : neutral100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserModel?> _getUserFromCache(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId];
    }

    final userVM = Provider.of<UserViewmodel>(context, listen: false);
    final user = await userVM.fetchUserById(userId: userId);

    if (user != null) {
      userCache[userId] = user;
    }

    return user;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:trippify/data/models/chat_message_model.dart';
import 'package:trippify/data/models/chatroom_model.dart';
import 'package:trippify/data/repositories/chat_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/core/errors/app_exception.dart';
import '../widgets/snackbars/general_error_snackbar.dart';

class ChatViewmodel extends BaseViewmodel {
  final ChatRepo chatRepo;

  ChatViewmodel({required this.chatRepo});

  ChatroomModel? currentChatroom;
  Stream<List<ChatMessageModel>>? messagesStream;

  Future<ChatroomModel?> fetchChatroomByTripId({required String tripId}) async {
    try {
      currentChatroom = await chatRepo.getChatroomByTripId(tripId: tripId);

      if (currentChatroom != null) {
        messagesStream = chatRepo.getMessages(chatroomId: currentChatroom!.id);
      }

      return currentChatroom;
    } catch (e) {
      debugPrint('FetchChatroomByTripId error: $e');
      return null;
    }
  }

  Future<bool> sendMessage({
    required BuildContext context,
    required String message,
  }) async {
    if (currentChatroom == null) {
      showGeneralErrorSnackbar(message: 'No active chatroom', context: context);
      return false;
    }

    if (message.trim().isEmpty) {
      return false;
    }

    try {
      await chatRepo.sendMessage(
        chatroomId: currentChatroom!.id,
        message: message.trim(),
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to send message.',
        context: context,
      );
      return false;
    }
  }
}

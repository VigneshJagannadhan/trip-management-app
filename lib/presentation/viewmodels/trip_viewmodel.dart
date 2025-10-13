import 'package:flutter/material.dart';
import 'package:trippify/data/models/trip_model.dart';
import 'package:trippify/data/models/trip_invitation_model.dart';
import 'package:trippify/data/repositories/trip_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/core/errors/app_exception.dart';
import '../widgets/snackbars/general_error_snackbar.dart';

class TripViewmodel extends BaseViewmodel {
  final TripRepo tripRepo;

  TripViewmodel({required this.tripRepo});

  List<TripModel> trips = [];
  List<TripInvitationModel> tripInvitations = [];

  bool imageError = false;
  bool startDateError = false;
  bool endDateError = false;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearValidationErrors() {
    imageError = false;
    startDateError = false;
    endDateError = false;
    notifyListeners();
  }

  bool validateTripForm({
    required BuildContext context,
    required bool hasImage,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    bool hasError = false;

    if (!hasImage) {
      imageError = true;
      hasError = true;
    } else {
      imageError = false;
    }

    if (startDate == null) {
      startDateError = true;
      hasError = true;
    } else {
      startDateError = false;
    }

    if (endDate == null) {
      endDateError = true;
      hasError = true;
    } else {
      endDateError = false;
    }

    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      endDateError = true;
      hasError = true;
      showGeneralErrorSnackbar(
        message: 'End date must be after start date',
        context: context,
      );
    }

    if (hasError) {
      notifyListeners();
    }

    return !hasError;
  }

  Future<bool> createTrip({
    required BuildContext context,
    required String name,
    required String location,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    String? imageUrl,
  }) async {
    try {
      isLoading = true;
      await tripRepo.createTrip(
        name: name,
        location: location,
        description: description,
        startTime: startDate,
        endTime: endDate,
        imageUrl: imageUrl,
      );
      await fetchTrips();
      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip created successfully',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Unexpected error occurred.',
        context: context,
      );
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> updateTrip({
    required BuildContext context,
    required TripModel trip,
  }) async {
    try {
      isLoading = true;
      await tripRepo.updateTrip(
        tripId: trip.id,
        name: trip.name,
        location: trip.location,
        startTime: trip.startTime,
        endTime: trip.endTime,
      );

      final index = trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) trips[index] = trip;
      notifyListeners();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip updated successfully',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Unexpected error occurred.',
        context: context,
      );
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> addUserToTrip({
    required BuildContext context,
    required String tripId,
    required String userId,
  }) async {
    try {
      isLoading = true;
      await tripRepo.addUserToTrip(tripId: tripId, userId: userId);
      final trip = trips.firstWhere((t) => t.id == tripId);
      trip.members.add(userId);
      notifyListeners();
      showGeneralSuccessSnackbar(
        context: context,
        message: 'User added to trip successfully',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Unexpected error occurred.',
        context: context,
      );
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchTrips() async {
    try {
      isLoading = true;
      trips = await tripRepo.getTrips();
    } catch (e) {
      debugPrint('FetchTrips error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<TripModel?> fetchTripById({required String tripId}) async {
    try {
      final trip = await tripRepo.getTripById(tripId: tripId);
      return trip;
    } catch (e) {
      debugPrint('FetchTripById error: $e');
      return null;
    }
  }

  List<TripModel> getFilteredTrips() {
    if (searchQuery.isEmpty) return trips;
    return trips.where((trip) {
      final query = searchQuery.toLowerCase();
      return trip.name.toLowerCase().contains(query) ||
          trip.location.toLowerCase().contains(query) ||
          trip.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> deleteTrip({
    required BuildContext context,
    required String tripId,
  }) async {
    try {
      isLoading = true;
      await tripRepo.deleteTrip(tripId: tripId);

      // Remove from local list
      trips.removeWhere((trip) => trip.id == tripId);
      notifyListeners();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip deleted successfully',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Unexpected error occurred.',
        context: context,
      );
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchTripInvitations() async {
    try {
      tripInvitations = await tripRepo.getPendingTripInvitations();
      notifyListeners();
    } catch (e) {
      debugPrint('FetchTripInvitations error: $e');
    }
  }

  Future<bool> sendTripInvitation({
    required BuildContext context,
    required String tripId,
    required String receiverId,
  }) async {
    try {
      await tripRepo.sendTripInvitation(tripId: tripId, receiverId: receiverId);
      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip invitation sent',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to send invitation.',
        context: context,
      );
      return false;
    }
  }

  Future<bool> acceptTripInvitation({
    required BuildContext context,
    required String invitationId,
  }) async {
    try {
      await tripRepo.acceptTripInvitation(invitationId: invitationId);

      tripInvitations.removeWhere((inv) => inv.id == invitationId);
      await fetchTrips();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip invitation accepted',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to accept invitation.',
        context: context,
      );
      return false;
    }
  }

  Future<bool> rejectTripInvitation({
    required BuildContext context,
    required String invitationId,
  }) async {
    try {
      await tripRepo.rejectTripInvitation(invitationId: invitationId);

      tripInvitations.removeWhere((inv) => inv.id == invitationId);
      notifyListeners();

      showGeneralSuccessSnackbar(
        context: context,
        message: 'Trip invitation rejected',
      );
      return true;
    } on AppException catch (e) {
      showGeneralErrorSnackbar(message: e.message, context: context);
      return false;
    } catch (e) {
      showGeneralErrorSnackbar(
        message: 'Failed to reject invitation.',
        context: context,
      );
      return false;
    }
  }
}

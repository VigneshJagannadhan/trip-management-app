import 'package:flutter/material.dart';
import 'package:trippify/data/models/trip_model.dart';
import 'package:trippify/data/repositories/trip_repo.dart';
import 'package:trippify/presentation/viewmodels/base_viewmodel.dart';
import 'package:trippify/core/errors/app_exception.dart';
import '../widgets/snackbars/general_error_snackbar.dart';

class TripViewmodel extends BaseViewmodel {
  final TripRepo tripRepo;

  TripViewmodel({required this.tripRepo});

  List<TripModel> trips = [];

  Future<bool> createTrip({
    required BuildContext context,
    required String name,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    String? imageUrl,
  }) async {
    try {
      isLoading = true;
      await tripRepo.createTrip(
        name: name,
        location: location,
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

      // Update local list
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
}

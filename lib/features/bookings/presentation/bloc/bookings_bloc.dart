import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_upcoming_bookings.dart';
import '../../domain/usecases/get_past_bookings.dart';
import '../../domain/usecases/get_booking_by_id.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/modify_booking.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/submit_report.dart';
import 'bookings_event.dart';
import 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final GetUpcomingBookings getUpcomingBookings;
  final GetPastBookings getPastBookings;
  final GetBookingById getBookingById;
  final CreateBooking createBooking;
  final ModifyBooking modifyBooking;
  final CancelBooking cancelBooking;
  final SubmitReport submitReport;

  BookingsBloc({
    required this.getUpcomingBookings,
    required this.getPastBookings,
    required this.getBookingById,
    required this.createBooking,
    required this.modifyBooking,
    required this.cancelBooking,
    required this.submitReport,
  }) : super(BookingsInitial()) {
    on<LoadUpcomingBookings>(_onLoadUpcoming);
    on<LoadPastBookings>(_onLoadPast);
    on<LoadBookingById>(_onLoadBookingById);
    on<SubmitReportEvent>(_onSubmitReport);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<ModifyBookingEvent>(_onModifyBooking);
  }

  Future<void> _onLoadUpcoming(
    LoadUpcomingBookings event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingsLoading());
    final upcomingResult = await getUpcomingBookings();
    final pastResult = await getPastBookings();

    upcomingResult.fold(
      (failure) => emit(BookingsError(failure.message)),
      (upcoming) {
        pastResult.fold(
          (failure) => emit(BookingsError(failure.message)),
          (past) => emit(BookingsLoaded(
            upcomingBookings: upcoming,
            pastBookings: past,
            isUpcomingTab: true,
          )),
        );
      },
    );
  }

  Future<void> _onLoadPast(
    LoadPastBookings event,
    Emitter<BookingsState> emit,
  ) async {
    if (state is BookingsLoaded) {
      emit((state as BookingsLoaded).copyWith(isUpcomingTab: false));
      return;
    }

    emit(BookingsLoading());
    final upcomingResult = await getUpcomingBookings();
    final pastResult = await getPastBookings();

    upcomingResult.fold(
      (failure) => emit(BookingsError(failure.message)),
      (upcoming) {
        pastResult.fold(
          (failure) => emit(BookingsError(failure.message)),
          (past) => emit(BookingsLoaded(
            upcomingBookings: upcoming,
            pastBookings: past,
            isUpcomingTab: false,
          )),
        );
      },
    );
  }

  Future<void> _onLoadBookingById(
    LoadBookingById event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingsLoading());
    final result = await getBookingById(event.bookingId);
    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (booking) => emit(BookingDetailLoaded(booking)),
    );
  }

  Future<void> _onSubmitReport(
    SubmitReportEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingActionLoading());
    final result = await submitReport(
      bookingId: event.bookingId,
      description: event.description,
    );
    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (_) => emit(BookingActionSuccess('Report submitted successfully')),
    );
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingActionLoading());
    final result = await createBooking(
      professionalId: event.professionalId,
      serviceName: event.serviceName,
      servicePrice: event.servicePrice,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      address: event.address,
      description: event.description,
      imageUrls: event.imageUrls,
    );
    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (_) => emit(BookingActionSuccess('Booking created successfully')),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingActionLoading());
    final result = await cancelBooking(event.bookingId);
    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (_) => emit(BookingCancelledSuccess()),
    );
  }

  Future<void> _onModifyBooking(
    ModifyBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingActionLoading());
    final result = await modifyBooking(
      bookingId: event.bookingId,
      serviceName: event.serviceName,
      servicePrice: event.servicePrice,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      address: event.address,
      description: event.description,
    );
    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (_) => emit(BookingModifiedSuccess()),
    );
  }
}

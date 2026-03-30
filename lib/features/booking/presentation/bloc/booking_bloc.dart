import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/booking/domain/use_cases/create_booking_usecase.dart';
import 'package:gp/features/booking/domain/use_cases/get_my_bookings_usecase.dart';
import 'package:gp/features/booking/domain/use_cases/cancel_booking_usecase.dart';
import 'package:gp/features/booking/domain/use_cases/get_booking_status_usecase.dart';
import 'package:gp/features/booking/domain/entities/booking_entity.dart';
// ─── Events ────────────────────────────────────────────────────────────────

abstract class BookingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateBookingRequested extends BookingEvent {
  final BookingEntity booking;
  CreateBookingRequested(this.booking);

  @override
  List<Object?> get props => [booking];
}

class GetMyBookingsRequested extends BookingEvent {}

class CancelBookingRequested extends BookingEvent {
  final int id;
  CancelBookingRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class GetBookingStatusRequested extends BookingEvent {
  final int id;
  GetBookingStatusRequested(this.id);

  @override
  List<Object?> get props => [id];
}

// ─── States ────────────────────────────────────────────────────────────────

abstract class BookingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreatedSuccess extends BookingState {
  final BookingEntity booking;
  BookingCreatedSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class MyBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;
  MyBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingCancelledSuccess extends BookingState {}

class BookingStatusLoaded extends BookingState {
  final BookingEntity booking;
  BookingStatusLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final GetBookingStatusUseCase getBookingStatusUseCase;

  BookingBloc({
    required this.createBookingUseCase,
    required this.getMyBookingsUseCase,
    required this.cancelBookingUseCase,
    required this.getBookingStatusUseCase,
  }) : super(BookingInitial()) {
    on<CreateBookingRequested>(_onCreate);
    on<GetMyBookingsRequested>(_onGetAll);
    on<CancelBookingRequested>(_onCancel);
    on<GetBookingStatusRequested>(_onGetStatus);
  }

  Future<void> _onCreate(
      CreateBookingRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await createBookingUseCase(event.booking);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreatedSuccess(booking)),
    );
  }

  Future<void> _onGetAll(
      GetMyBookingsRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await getMyBookingsUseCase();
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(MyBookingsLoaded(bookings)),
    );
  }

  Future<void> _onCancel(
      CancelBookingRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await cancelBookingUseCase(event.id);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) => emit(BookingCancelledSuccess()),
    );
  }

  Future<void> _onGetStatus(
      GetBookingStatusRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await getBookingStatusUseCase(event.id);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingStatusLoaded(booking)),
    );
  }
}

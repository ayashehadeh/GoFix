import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/usecases/earnings_usecases.dart';

// Events
abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEarningsEvent extends EarningsEvent {}

class RefreshEarningsEvent extends EarningsEvent {}

class ChangePeriodEvent extends EarningsEvent {
  final String period;

  const ChangePeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

// States
abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final Map<String, Earning> earnings;
  final String selectedPeriod;

  const EarningsLoaded({
    required this.earnings,
    this.selectedPeriod = 'weekly',
  });

  Earning get currentEarning => earnings[selectedPeriod]!;

  EarningsLoaded copyWith({String? selectedPeriod}) {
    return EarningsLoaded(
      earnings: earnings,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [earnings, selectedPeriod];
}

class EarningsError extends EarningsState {
  final String message;

  const EarningsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetEarnings getEarnings;
  final RefreshEarnings refreshEarnings;

  EarningsBloc({
    required this.getEarnings,
    required this.refreshEarnings,
  }) : super(EarningsInitial()) {
    on<LoadEarningsEvent>(_onLoad);
    on<RefreshEarningsEvent>(_onRefresh);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoad(LoadEarningsEvent event, Emitter<EarningsState> emit) async {
    emit(EarningsLoading());

    final result = await getEarnings();

    result.fold(
      (failure) => emit(EarningsError(failure.message)),
      (data) => emit(EarningsLoaded(earnings: data)),
    );
  }

  Future<void> _onRefresh(RefreshEarningsEvent event, Emitter<EarningsState> emit) async {
    final currentState = state;

    final result = await refreshEarnings();

    result.fold(
      (failure) {
        if (currentState is! EarningsLoaded) {
          emit(EarningsError(failure.message));
        }
      },
      (data) {
        final period = currentState is EarningsLoaded ? currentState.selectedPeriod : 'weekly';
        emit(EarningsLoaded(earnings: data, selectedPeriod: period));
      },
    );
  }

  void _onChangePeriod(ChangePeriodEvent event, Emitter<EarningsState> emit) {
    if (state is EarningsLoaded) {
      emit((state as EarningsLoaded).copyWith(selectedPeriod: event.period));
    }
  }
}

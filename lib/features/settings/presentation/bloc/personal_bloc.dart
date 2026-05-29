import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/features/settings/domain/entities/profile_entity.dart';
import 'package:gp/features/settings/domain/repositories/profile_repository.dart';

// ══════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════
abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateNameEvent extends ProfileEvent {
  final String name;
  UpdateNameEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdatePhoneEvent extends ProfileEvent {
  final String phone;
  UpdatePhoneEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class UpdateEmailEvent extends ProfileEvent {
  final String email;
  UpdateEmailEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class UpdateDateOfBirthEvent extends ProfileEvent {
  final String dob;
  UpdateDateOfBirthEvent(this.dob);
  @override
  List<Object?> get props => [dob];
}

class UpdateGenderEvent extends ProfileEvent {
  final String gender;
  UpdateGenderEvent(this.gender);
  @override
  List<Object?> get props => [gender];
}

// ══════════════════════════════════════════
// STATES
// ══════════════════════════════════════════
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isUpdate;
  ProfileLoaded(this.profile, {this.isUpdate = false});
  @override
  List<Object?> get props => [profile, isUpdate];
}

class ProfileError extends ProfileState with AppErrorState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════
class PersonalBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileEntity? _current;

  PersonalBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateNameEvent>(_onUpdateName);
    on<UpdatePhoneEvent>(_onUpdatePhone);
    on<UpdateEmailEvent>(_onUpdateEmail);
    on<UpdateDateOfBirthEvent>(_onUpdateDOB);
    on<UpdateGenderEvent>(_onUpdateGender);
  }

  Future<void> _onLoad(LoadProfileEvent e, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.getProfile();
    result.fold(
      (err) => emit(ProfileError(err)),
      (profile) {
        _current = profile;
        emit(ProfileLoaded(profile, isUpdate: false));
      },
    );
  }

  Future<void> _onUpdateName(
      UpdateNameEvent e, Emitter<ProfileState> emit) async {
    final result = await repository.updateName(e.name);
    result.fold(
      (err) => emit(ProfileError(err)),
      (_) {
        _current = _current?.copyWith(name: e.name);
        emit(ProfileLoaded(_current!, isUpdate: true));
      },
    );
  }

  Future<void> _onUpdatePhone(
      UpdatePhoneEvent e, Emitter<ProfileState> emit) async {
    final result = await repository.updatePhone(e.phone);
    result.fold(
      (err) => emit(ProfileError(err)),
      (_) {
        _current = _current?.copyWith(phone: e.phone);
        emit(ProfileLoaded(_current!, isUpdate: true));
      },
    );
  }

  Future<void> _onUpdateEmail(
      UpdateEmailEvent e, Emitter<ProfileState> emit) async {
    final result = await repository.updateEmail(e.email);
    result.fold(
      (err) => emit(ProfileError(err)),
      (_) {
        _current = _current?.copyWith(email: e.email);
        emit(ProfileLoaded(_current!, isUpdate: true));
      },
    );
  }

  Future<void> _onUpdateDOB(
      UpdateDateOfBirthEvent e, Emitter<ProfileState> emit) async {
    final result = await repository.updateDateOfBirth(e.dob);
    result.fold(
      (err) => emit(ProfileError(err)),
      (_) {
        _current = _current?.copyWith(dateOfBirth: e.dob);
        emit(ProfileLoaded(_current!, isUpdate: true));
      },
    );
  }

  Future<void> _onUpdateGender(
      UpdateGenderEvent e, Emitter<ProfileState> emit) async {
    final result = await repository.updateGender(e.gender);
    result.fold(
      (err) => emit(ProfileError(err)),
      (_) {
        _current = _current?.copyWith(gender: e.gender);
        emit(ProfileLoaded(_current!, isUpdate: true));
      },
    );
  }
}

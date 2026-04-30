import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/domain/usecases/address_usecases.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class GetAddressesEvent extends AddressEvent {
  const GetAddressesEvent();
}

class AddAddressEvent extends AddressEvent {
  final AddressEntity address;
  const AddAddressEvent(this.address);
  @override
  List<Object?> get props => [address];
}

class UpdateAddressEvent extends AddressEvent {
  final AddressEntity address;
  const UpdateAddressEvent(this.address);
  @override
  List<Object?> get props => [address];
}

class DeleteAddressEvent extends AddressEvent {
  final String id;
  const DeleteAddressEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;
  const AddressLoaded(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

class AddressActionSuccess extends AddressState {
  final List<AddressEntity> addresses;
  const AddressActionSuccess(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressesUseCase getAddresses;
  final AddAddressUseCase addAddress;
  final UpdateAddressUseCase updateAddress;
  final DeleteAddressUseCase deleteAddress;

  AddressBloc({
    required this.getAddresses,
    required this.addAddress,
    required this.updateAddress,
    required this.deleteAddress,
  }) : super(const AddressInitial()) {
    on<GetAddressesEvent>(_onGet);
    on<AddAddressEvent>(_onAdd);
    on<UpdateAddressEvent>(_onUpdate);
    on<DeleteAddressEvent>(_onDelete);
  }

  Future<void> _onGet(
    GetAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    final result = await getAddresses();
    result.fold(
      (f) => emit(const AddressError('Failed to load addresses')),
      (list) => emit(AddressLoaded(list)),
    );
  }

  Future<void> _onAdd(
    AddAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    final result = await addAddress(event.address);
    await result.fold(
      (f) async => emit(const AddressError('Failed to add address')),
      (_) async {
        final refresh = await getAddresses();
        refresh.fold(
          (f) => emit(const AddressError('Failed to reload')),
          (list) => emit(AddressActionSuccess(list)),
        );
      },
    );
  }

  Future<void> _onUpdate(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    final result = await updateAddress(event.address);
    await result.fold(
      (f) async => emit(const AddressError('Failed to update address')),
      (_) async {
        final refresh = await getAddresses();
        refresh.fold(
          (f) => emit(const AddressError('Failed to reload')),
          (list) => emit(AddressActionSuccess(list)),
        );
      },
    );
  }

  Future<void> _onDelete(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    final result = await deleteAddress(event.id);
    await result.fold(
      (f) async => emit(const AddressError('Failed to delete address')),
      (_) async {
        final refresh = await getAddresses();
        refresh.fold(
          (f) => emit(const AddressError('Failed to reload')),
          (list) => emit(AddressActionSuccess(list)),
        );
      },
    );
  }
}

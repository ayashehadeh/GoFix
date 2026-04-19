import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/professional_application.dart';
import '../../domain/usecases/submit_professional_application.dart';
import 'become_professional_event.dart';
import 'become_professional_state.dart';

class BecomeProfessionalBloc
    extends Bloc<BecomeProfessionalEvent, BecomeProfessionalState> {
  final SubmitProfessionalApplication submitApplication;

  BecomeProfessionalBloc({required this.submitApplication})
      : super(BecomeProfessionalFormState()) {
    on<UpdateStep1>(_onUpdateStep1);
    on<UpdateServices>(_onUpdateServices);
    on<UpdateDocument>(_onUpdateDocument);
    on<SubmitApplication>(_onSubmit);
  }

  void _onUpdateStep1(
    UpdateStep1 event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final current = _formState;
    emit(current.copyWith(
      serviceCategory: event.serviceCategory,
      experienceLevel: event.experienceLevel,
      workDescription: event.workDescription,
    ));
  }

  void _onUpdateServices(
    UpdateServices event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(_formState.copyWith(services: event.services));
  }

  void _onUpdateDocument(
    UpdateDocument event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final current = _formState;
    switch (event.type) {
      case DocumentType.profile:
        emit(current.copyWith(profileImagePath: event.path));
        break;
      case DocumentType.id:
        emit(current.copyWith(idImagePath: event.path));
        break;
      case DocumentType.certification:
        emit(current.copyWith(certificationImagePath: event.path));
        break;
      case DocumentType.conduct:
        emit(current.copyWith(conductImagePath: event.path));
        break;
    }
  }

  Future<void> _onSubmit(
    SubmitApplication event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    emit(BecomeProfessionalSubmitting());
    final result = await submitApplication(_formState.toEntity());
    result.fold(
      (failure) => emit(BecomeProfessionalError(failure.message)),
      (_) => emit(BecomeProfessionalSuccess()),
    );
  }

  /// Safe getter — always returns the current form state.
  BecomeProfessionalFormState get _formState {
    final s = state;
    if (s is BecomeProfessionalFormState) return s;
    return BecomeProfessionalFormState();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class LocaleEvent {}

class ChangeLocaleEvent extends LocaleEvent {
  final Locale locale;
  ChangeLocaleEvent(this.locale);
}

// ─── States ───────────────────────────────────────────────────────────────────

class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<ChangeLocaleEvent>(_onChange);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    emit(LocaleState(Locale(code)));
  }

  Future<void> _onChange(
    ChangeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', event.locale.languageCode);
    emit(LocaleState(event.locale));
  }
}

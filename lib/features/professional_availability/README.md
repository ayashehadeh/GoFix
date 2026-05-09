# Professional Availability Feature - Clean Architecture

## 📁 Complete Structure Created

All files follow Clean Architecture principles with proper separation of concerns.

## 🚀 Installation Instructions

1. Copy the entire `professional_availability_CLEAN_ARCH` folder
2. Paste it into `lib/features/` in your project
3. Rename it to just `professional_availability`
4. Update `injection_container.dart` (see below)
5. Done!

## ⚙️ Dependency Injection Setup

Add to your `injection_container.dart`:

```dart
// Data sources
sl.registerLazySingleton<AvailabilityLocalDataSource>(
  () => AvailabilityLocalDataSourceImpl(sharedPreferences: sl()),
);

// Repository
sl.registerLazySingleton<AvailabilityRepository>(
  () => AvailabilityRepositoryImpl(localDataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => GetAvailability(sl()));
sl.registerLazySingleton(() => SaveAvailability(sl()));

// BLoC
sl.registerFactory(
  () => AvailabilityBloc(
    getAvailability: sl(),
    saveAvailability: sl(),
  ),
);
```

## 📦 Required Dependencies

Make sure these are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  shared_preferences: ^2.2.2
```

## 🎯 Usage in Dashboard

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../professional_availability/presentation/bloc/availability_bloc.dart';
import '../../../professional_availability/presentation/pages/my_availability_screen.dart';

// In your dashboard navigation:
_buildMenuItem(
  context,
  Icons.calendar_today,
  'My Availability',
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AvailabilityBloc>(),
          child: const MyAvailabilityScreen(),
        ),
      ),
    );
  },
),
```

## ✅ Features

- ✅ Clean Architecture (Domain/Data/Presentation)
- ✅ BLoC State Management
- ✅ Local Storage with SharedPreferences
- ✅ Proper Error Handling
- ✅ Dependency Injection Ready
- ✅ Testable Code Structure


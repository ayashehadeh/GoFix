import 'package:gp/features/professionals/data/models/professional_model.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/professionals/domain/entities/working_hours.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import '../models/area_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ProfessionalModel>> searchProfessionals(String query);
  Future<List<AreaResultModel>> searchAreas(String query);
  Future<List<ServiceResult>> searchServices(String query);
  Future<List<ProfessionalModel>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  });
}

/// Mock implementation — swap for a real Dio datasource when the API is ready.
class MockSearchDataSource implements SearchRemoteDataSource {
  // ── Static mock professional pool ─────────────────────────────────────────

  static final List<ProfessionalModel> _allProfessionals = [
    _pro('p1',  'Ahmad Khalil',    ServiceCategory.plumbing,       4.9, 34, 8, ['Khalda', 'Sweifieh', 'AlJubaiha'], 20),
    _pro('p2',  'Ali Emad',        ServiceCategory.electricalWork, 4.7, 21, 5, ['Sweifieh', 'Khalda'],              18),
    _pro('p3',  'Omar Amer',       ServiceCategory.carpentry,      4.6, 18, 3, ['Khalda', 'Marka'],                 25),
    _pro('p4',  'Yousef Abdallah', ServiceCategory.electricalWork, 4.7, 31, 7, ['Khalda', 'AlJubaiha'],             18),
    _pro('p5',  'Omar Hamed',      ServiceCategory.plumbing,       4.8, 23, 5, ['Khalda', 'Sweifieh'],              15),
    _pro('p6',  'Rami Nasser',     ServiceCategory.acRepair,       4.6, 18, 3, ['Khalda', 'Bayader'],               25),
    _pro('p7',  'Khalid Mansour',  ServiceCategory.plumbing,       4.5, 12, 4, ['Irbid', 'Ramtha'],                 22),
    _pro('p8',  'Mahmoud Saleh',   ServiceCategory.painting,       4.8, 27, 6, ['Sweifieh', 'Shmeisani'],           30),
    _pro('p9',  'Hassan Khalil',   ServiceCategory.cleaning,       4.4,  9, 2, ['AlJubaiha', 'Khalda'],             12),
    _pro('p10', 'Firas Khalid',    ServiceCategory.applianceRepair,4.7, 15, 5, ['Marka', 'Zarqa'],                  20),
  ];

  // ── Static mock area pool ─────────────────────────────────────────────────

  static final List<AreaResultModel> _allAreas = [
    const AreaResultModel(name: 'Khalda',        city: 'Amman', proCount: 18),
    const AreaResultModel(name: 'Khaldun Street',city: 'Irbid',  proCount: 4),
    const AreaResultModel(name: 'Sweifieh',      city: 'Amman', proCount: 22),
    const AreaResultModel(name: 'AlJubaiha',     city: 'Amman', proCount: 11),
    const AreaResultModel(name: 'Shmeisani',     city: 'Amman', proCount: 15),
    const AreaResultModel(name: 'Marka',         city: 'Amman', proCount:  8),
    const AreaResultModel(name: 'Bayader',       city: 'Amman', proCount:  6),
    const AreaResultModel(name: 'Zarqa',         city: 'Zarqa', proCount:  9),
    const AreaResultModel(name: 'Ramtha',        city: 'Irbid',  proCount:  5),
    const AreaResultModel(name: 'Irbid Center',  city: 'Irbid',  proCount: 13),
  ];

  // ── Static mock service pool ──────────────────────────────────────────────
  // Each entry is a named service that a professional can offer, mapped to its
  // parent category and how many pros in the mock pool offer it.

  static const List<ServiceResult> _allServices = [
    // Plumbing
    ServiceResult(serviceName: 'Pipe Installation',   category: ServiceCategory.plumbing,       proCount: 3),
    ServiceResult(serviceName: 'Pipe Repair',         category: ServiceCategory.plumbing,       proCount: 3),
    ServiceResult(serviceName: 'Leak Repairs',        category: ServiceCategory.plumbing,       proCount: 2),
    ServiceResult(serviceName: 'Water Heater Service',category: ServiceCategory.plumbing,       proCount: 2),
    ServiceResult(serviceName: 'Drain Unclogging',    category: ServiceCategory.plumbing,       proCount: 3),
    ServiceResult(serviceName: 'Bathroom Fixtures',   category: ServiceCategory.plumbing,       proCount: 2),
    ServiceResult(serviceName: 'Faucet Repair',       category: ServiceCategory.plumbing,       proCount: 3),
    // Electrical
    ServiceResult(serviceName: 'Wiring Repair',       category: ServiceCategory.electricalWork, proCount: 2),
    ServiceResult(serviceName: 'Light Fixture Install',category: ServiceCategory.electricalWork,proCount: 2),
    ServiceResult(serviceName: 'Circuit Breaker Fix', category: ServiceCategory.electricalWork, proCount: 2),
    ServiceResult(serviceName: 'Outlet Installation', category: ServiceCategory.electricalWork, proCount: 2),
    // AC
    ServiceResult(serviceName: 'AC Installation',     category: ServiceCategory.acRepair,       proCount: 1),
    ServiceResult(serviceName: 'AC Maintenance',      category: ServiceCategory.acRepair,       proCount: 1),
    ServiceResult(serviceName: 'AC Cleaning',         category: ServiceCategory.acRepair,       proCount: 1),
    ServiceResult(serviceName: 'Refrigerant Refill',  category: ServiceCategory.acRepair,       proCount: 1),
    // Carpentry
    ServiceResult(serviceName: 'Furniture Assembly',  category: ServiceCategory.carpentry,      proCount: 1),
    ServiceResult(serviceName: 'Door Repair',         category: ServiceCategory.carpentry,      proCount: 1),
    ServiceResult(serviceName: 'Cabinet Installation',category: ServiceCategory.carpentry,      proCount: 1),
    ServiceResult(serviceName: 'Wood Flooring',       category: ServiceCategory.carpentry,      proCount: 1),
    // Painting
    ServiceResult(serviceName: 'Interior Painting',   category: ServiceCategory.painting,       proCount: 1),
    ServiceResult(serviceName: 'Exterior Painting',   category: ServiceCategory.painting,       proCount: 1),
    ServiceResult(serviceName: 'Ceiling Painting',    category: ServiceCategory.painting,       proCount: 1),
    // Cleaning
    ServiceResult(serviceName: 'Deep Cleaning',       category: ServiceCategory.cleaning,       proCount: 1),
    ServiceResult(serviceName: 'Post-Construction Cleaning', category: ServiceCategory.cleaning, proCount: 1),
    ServiceResult(serviceName: 'Sofa Cleaning',       category: ServiceCategory.cleaning,       proCount: 1),
    // Moving
    ServiceResult(serviceName: 'Furniture Moving',    category: ServiceCategory.movingServices, proCount: 0),
    ServiceResult(serviceName: 'Packing Service',     category: ServiceCategory.movingServices, proCount: 0),
    // Appliance Repair
    ServiceResult(serviceName: 'Washing Machine Repair', category: ServiceCategory.applianceRepair, proCount: 1),
    ServiceResult(serviceName: 'Refrigerator Repair', category: ServiceCategory.applianceRepair, proCount: 1),
    ServiceResult(serviceName: 'Oven Repair',         category: ServiceCategory.applianceRepair, proCount: 1),
  ];

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Future<List<ProfessionalModel>> searchProfessionals(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _allProfessionals
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<AreaResultModel>> searchAreas(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _allAreas
        .where((a) => a.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ServiceResult>> searchServices(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _allServices
        .where((s) => s.serviceName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ProfessionalModel>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = _allProfessionals
        .where((p) => p.serviceAreas.any(
              (a) => a.toLowerCase() == areaName.toLowerCase(),
            ))
        .toList();
    if (category != null) {
      results = results.where((p) => p.category == category).toList();
    }
    return results;
  }

  // ── Factory helper ────────────────────────────────────────────────────────

  static ProfessionalModel _pro(
    String id,
    String name,
    ServiceCategory category,
    double rating,
    int reviewCount,
    int experienceYears,
    List<String> serviceAreas,
    double startingPrice,
  ) {
    return ProfessionalModel(
      id: id,
      name: name,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      ratingBreakdown: const {},
      experienceYears: experienceYears,
      isFavorite: false,
      profileImageUrl: null,
      phone: '+962 7X XXX XXXX',
      email: '${name.toLowerCase().replaceAll(' ', '.')}@gofix.jo',
      bio: 'Experienced ${category.displayName.toLowerCase()} professional.',
      serviceAreas: serviceAreas,
      workingHours: const WorkingHours(
        schedules: [
          DaySchedule(day: 'Sun - Thu', openTime: '8:00 AM', closeTime: '6:00 PM'),
        ],
      ),
      services: [
        ServiceOffered(
          name: category.displayName,
          minPrice: startingPrice,
        ),
      ],
      documents: const [],
      isVerified: true,
      isIdentityVerified: true,
    );
  }
}

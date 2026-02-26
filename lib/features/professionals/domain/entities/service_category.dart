enum ServiceCategory {
  plumbing,
  electricalWork,
  acRepair,
  carpentry,
  painting,
  cleaning,
  movingServices,
  applianceRepair;

  String get displayName {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electricalWork:
        return 'Electrical Work';
      case ServiceCategory.acRepair:
        return 'AC Repair';
      case ServiceCategory.carpentry:
        return 'Carpentry';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.cleaning:
        return 'Cleaning';
      case ServiceCategory.movingServices:
        return 'Moving Services';
      case ServiceCategory.applianceRepair:
        return 'Appliance Repair';
    }
  }

  String get description {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'Expert solutions for leaks, pipe installations, and faucet repairs.';
      case ServiceCategory.electricalWork:
        return 'Expert solutions for wiring, circuit repairs, and light fixture installations.';
      case ServiceCategory.acRepair:
        return 'Expert solutions for unit maintenance, cooling issues, and professional cleaning.';
      case ServiceCategory.carpentry:
        return 'Expert solutions for furniture assembly, door repairs, and custom woodwork.';
      case ServiceCategory.painting:
        return 'Expert solutions for interior walls, exterior finishes, and ceiling touch-ups.';
      case ServiceCategory.cleaning:
        return 'Expert solutions for deep home cleaning, sanitization, and professional tidying.';
      case ServiceCategory.movingServices:
        return 'Expert solutions for secure packing, heavy furniture transport, and efficient unloading.';
      case ServiceCategory.applianceRepair:
        return 'Expert solutions for refrigerators, washing machines, and kitchen appliances.';
    }
  }

  String get iconAsset {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'assets/home_screen/plumbing.svg';
      case ServiceCategory.electricalWork:
        return 'assets/home_screen/electrical_services.svg';
      case ServiceCategory.acRepair:
        return 'assets/home_screen/toys.svg';
      case ServiceCategory.carpentry:
        return 'assets/home_screen/handyman.svg';
      case ServiceCategory.painting:
        return 'assets/home_screen/format_paint.svg';
      case ServiceCategory.cleaning:
        return 'assets/home_screen/cleaning_services.svg';
      case ServiceCategory.movingServices:
        return 'assets/home_screen/local_shipping.svg';
      case ServiceCategory.applianceRepair:
        return 'assets/home_screen/home_repair_service.svg';
    }
  }
}

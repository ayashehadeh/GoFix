import 'package:gp/l10n/app_localizations.dart';

/// Returns the localized service name.
/// Prefers [nameAr] from the backend when the locale is Arabic.
/// Falls back to a client-side switch-case, then the original [name].
String localizeServiceName(String name, AppLocalizations l10n, {String? nameAr}) {
  final isArabic = l10n.amLabel == 'ص';
  if (!isArabic) return name;
  if (nameAr != null && nameAr.isNotEmpty) return nameAr;

  // Legacy fallback — covers bookings created before nameAr was added
  switch (name) {
    // ── Plumbing ──────────────────────────────────────────────────────────────
    case 'Pipe Installation':           return l10n.servicePipeInstallation;
    case 'Leak Repairs':                return l10n.serviceLeakRepairs;
    case 'Water Heater Service':        return l10n.serviceWaterHeaterService;
    case 'Drain Cleaning':              return l10n.serviceDrainCleaning;
    case 'Bathroom Fixtures':           return l10n.serviceBathroomFixtures;
    case 'Faucet Repair':               return l10n.serviceFaucetRepair;
    case 'Toilet Repair':               return l10n.serviceToiletRepair;
    case 'Pipe Repair':                 return l10n.servicePipeRepair;
    case 'Water Tank Cleaning':         return l10n.serviceWaterTankCleaning;
    case 'Leak Detection':              return l10n.serviceLeakDetection;
    case 'Shower Installation':         return l10n.serviceShowerInstallation;
    case 'Sink Installation':           return l10n.serviceSinkInstallation;
    case 'Toilet Installation':         return l10n.serviceToiletInstallation;

    // ── Electrical Work ───────────────────────────────────────────────────────
    case 'Wiring Repair':               return l10n.serviceWiringRepair;
    case 'Light Fixture Installation':  return l10n.serviceLightFixtureInstallation;
    case 'Electrical Wiring':           return l10n.serviceElectricalWiring;
    case 'Outlet Installation':         return l10n.serviceOutletInstallation;
    case 'Outlet Repair':               return l10n.serviceOutletRepair;
    case 'Switch Installation':         return l10n.serviceSwitchInstallation;
    case 'Switch Repair':               return l10n.serviceSwitchRepair;
    case 'Circuit Breaker Repair':      return l10n.serviceCircuitBreakerRepair;
    case 'Electrical Panel Service':    return l10n.serviceElectricalPanelService;
    case 'Fan Installation':            return l10n.serviceFanInstallation;
    case 'Ceiling Fan Installation':    return l10n.serviceCeilingFanInstallation;
    case 'Electrical Inspection':       return l10n.serviceElectricalInspection;
    case 'Generator Installation':      return l10n.serviceGeneratorInstallation;

    // ── AC Repair ─────────────────────────────────────────────────────────────
    case 'AC Installation':             return l10n.serviceAcInstallation;
    case 'AC Maintenance':              return l10n.serviceAcMaintenance;
    case 'AC Cleaning':                 return l10n.serviceAcCleaning;
    case 'AC Repair':                   return l10n.serviceAcRepair;
    case 'AC Gas Refill':               return l10n.serviceAcGasRefill;
    case 'Split AC Installation':       return l10n.serviceSplitAcInstallation;
    case 'AC Inspection':               return l10n.serviceAcInspection;
    case 'Central AC Service':          return l10n.serviceCentralAcService;

    // ── Carpentry ─────────────────────────────────────────────────────────────
    case 'Furniture Assembly':          return l10n.serviceFurnitureAssembly;
    case 'Door Repair':                 return l10n.serviceDoorRepair;
    case 'Cabinet Installation':        return l10n.serviceCabinetInstallation;
    case 'Wood Flooring':               return l10n.serviceWoodFlooring;
    case 'Window Repair':               return l10n.serviceWindowRepair;
    case 'Shelf Installation':          return l10n.serviceShelfInstallation;
    case 'Wardrobe Assembly':           return l10n.serviceWardrobeAssembly;
    case 'Kitchen Cabinet Installation':return l10n.serviceKitchenCabinetInstallation;
    case 'Door Installation':           return l10n.serviceDoorInstallation;
    case 'Custom Woodwork':             return l10n.serviceCustomWoodwork;

    // ── Painting ──────────────────────────────────────────────────────────────
    case 'Interior Painting':           return l10n.serviceInteriorPainting;
    case 'Exterior Painting':           return l10n.serviceExteriorPainting;
    case 'Wall Painting':               return l10n.serviceWallPainting;
    case 'Ceiling Painting':            return l10n.serviceCeilingPainting;
    case 'Texture Painting':            return l10n.serviceTexturePainting;
    case 'Wallpaper Installation':      return l10n.serviceWallpaperInstallation;
    case 'Touch-up Painting':           return l10n.serviceTouchUpPainting;

    // ── Cleaning ──────────────────────────────────────────────────────────────
    case 'Deep Cleaning':               return l10n.serviceDeepCleaning;
    case 'Regular Cleaning':            return l10n.serviceRegularCleaning;
    case 'Carpet Cleaning':             return l10n.serviceCarpetCleaning;
    case 'Sofa Cleaning':               return l10n.serviceSofaCleaning;
    case 'Window Cleaning':             return l10n.serviceWindowCleaning;
    case 'Move-in Cleaning':            return l10n.serviceMoveInCleaning;
    case 'Post-Construction Cleaning':  return l10n.servicePostConstructionCleaning;
    case 'Kitchen Deep Clean':          return l10n.serviceKitchenDeepClean;
    case 'Bathroom Deep Clean':         return l10n.serviceBathroomDeepClean;

    // ── Moving Services ───────────────────────────────────────────────────────
    case 'Packing & Unpacking':         return l10n.servicePackingAndUnpacking;
    case 'Heavy Item Moving':           return l10n.serviceHeavyItemMoving;
    case 'Piano Moving':                return l10n.servicePianoMoving;
    case 'Furniture Moving':            return l10n.serviceFurnitureMoving;
    case 'House Moving':                return l10n.serviceHouseMoving;
    case 'Office Moving':               return l10n.serviceOfficeMoving;
    case 'Storage Service':             return l10n.serviceStorageService;
    case 'Loading & Unloading':         return l10n.serviceLoadingAndUnloading;

    // ── Appliance Repair ──────────────────────────────────────────────────────
    case 'Refrigerator Repair':         return l10n.serviceRefrigeratorRepair;
    case 'Washing Machine Repair':      return l10n.serviceWashingMachineRepair;
    case 'Dishwasher Repair':           return l10n.serviceDishwasherRepair;
    case 'Oven Repair':                 return l10n.serviceOvenRepair;
    case 'Microwave Repair':            return l10n.serviceMicrowaveRepair;
    case 'Dryer Repair':                return l10n.serviceDryerRepair;
    case 'Stove Repair':                return l10n.serviceStoveRepair;
    case 'Water Heater Repair':         return l10n.serviceWaterHeaterRepair;
    case 'TV Repair':                   return l10n.serviceTvRepair;

    default:                            return name;
  }
}

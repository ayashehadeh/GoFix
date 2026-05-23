import 'package:gp/l10n/app_localizations.dart';

String localizeServiceName(String name, AppLocalizations l10n) {
  switch (name) {
    case 'Pipe Installation':         return l10n.servicePipeInstallation;
    case 'Leak Repairs':              return l10n.serviceLeakRepairs;
    case 'Water Heater Service':      return l10n.serviceWaterHeaterService;
    case 'Drain Cleaning':            return l10n.serviceDrainCleaning;
    case 'Bathroom Fixtures':         return l10n.serviceBathroomFixtures;
    case 'Wiring Repair':             return l10n.serviceWiringRepair;
    case 'Light Fixture Installation':return l10n.serviceLightFixtureInstallation;
    case 'Furniture Assembly':        return l10n.serviceFurnitureAssembly;
    case 'Door Repair':               return l10n.serviceDoorRepair;
    default:                          return name;
  }
}

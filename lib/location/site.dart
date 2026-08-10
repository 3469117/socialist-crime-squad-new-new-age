import 'dart:math';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/gender.dart';
import 'package:lcs_new_age/creature/name.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/gamestate/ledger.dart';
import 'package:lcs_new_age/items/flag_type.dart';
import 'package:lcs_new_age/items/item.dart';
import 'package:lcs_new_age/items/money.dart';
import 'package:lcs_new_age/location/city.dart';
import 'package:lcs_new_age/location/compound.dart';
import 'package:lcs_new_age/location/district.dart';
import 'package:lcs_new_age/location/location.dart';
import 'package:lcs_new_age/location/location_type.dart';
import 'package:lcs_new_age/location/siege.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/politics/laws.dart';
import 'package:lcs_new_age/sitemode/sitemap.dart';
import 'package:lcs_new_age/utils/lcsrandom.dart';

part 'site.g.dart';

@JsonSerializable(ignoreUnannotated: true)
class Site extends Location {
  Site(this.type, [City? city, District? district])
    : name = type.name,
      shortName = type.shortName,
      cityId = city?.id ?? cities.firstOrNull?.id ?? -1,
      districtId = district?.id ?? districts.firstOrNull?.id ?? -1,
      id = gameState.nextSiteId++,
      mapseed = nextRngSeed {
    if (type == SiteType.homelessEncampment || type == SiteType.warehouse) {
      controller = SiteController.lcs;
    }
    if (discreet) hidden = true;
    initSiteName(this);
  }
  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
  Map<String, dynamic> toJson() => _$SiteToJson(this);
  @JsonKey()
  SiteType type;
  @JsonKey()
  Siege siege = Siege();
  @JsonKey()
  SiteController controller = SiteController.unaligned;
  @JsonKey()
  int rent = 0;
  @JsonKey()
  bool newRental = false;
  @JsonKey()
  int heat = 0;
  @JsonKey(defaultValue: 0)
  int extraHeatFromRuralMobs = 0;
  @JsonKey(defaultValue: 0)
  int extraHeatFromCorps = 0;
  @JsonKey(defaultValue: 0)
  int extraHeatFromCIA = 0;
  @JsonKey(defaultValue: 0)
  int extraHeatFromCCS = 0;

  @JsonKey(defaultValue: 0)
  int laborOrganizingProgress = 0;
  @JsonKey(defaultValue: 0)
  int laborEmployerResistance = 0;
  @JsonKey(defaultValue: 0)
  int laborRetaliationIncidents = 0;
  @JsonKey(defaultValue: 0)
  int laborWorkersFired = 0;
  @JsonKey(defaultValue: 0)
  int laborBargainingDemand = 0;
  @JsonKey(defaultValue: 0)
  int laborBargainingProgress = 0;
  @JsonKey(defaultValue: 0)
  int laborBargainingStalledRounds = 0;
  @JsonKey(defaultValue: false)
  bool laborBargainingImpasse = false;
  @JsonKey(defaultValue: 0)
  int laborContractDemand = 0;

  static const int laborDemandNone = 0;
  static const int laborDemandHigherWages = 1;
  static const int laborDemandBetterConditions = 2;
  static const int laborDemandJobSecurity = 3;
  static const int laborDemandUnionProtections = 4;

  bool get supportsLaborOrganizing => switch (type) {
        SiteType.departmentStore ||
        SiteType.carDealership ||
        SiteType.sweatshop ||
        SiteType.dirtyIndustry ||
        SiteType.nuclearPlant ||
        SiteType.corporateHQ ||
        SiteType.amRadioStation ||
        SiteType.cableNewsStation ||
        SiteType.barAndGrill ||
        SiteType.bank ||
        SiteType.insuranceOffice ||
        SiteType.nursingHome =>
          true,
        _ => false,
      };

  bool get isUnionized => laborOrganizingProgress >= 100;

  String get laborOrganizingStatus {
    if (isUnionized) return "Unionized";
    if (laborOrganizingProgress > 0) return "Organizing";
    return "Unorganized";
  }

  int get laborUnionBustStrength => switch (type) {
        SiteType.sweatshop => 6,
        SiteType.corporateHQ ||
        SiteType.bank ||
        SiteType.insuranceOffice =>
          5,
        SiteType.dirtyIndustry ||
        SiteType.nuclearPlant ||
        SiteType.departmentStore ||
        SiteType.amRadioStation ||
        SiteType.cableNewsStation ||
        SiteType.nursingHome =>
          4,
        SiteType.carDealership || SiteType.barAndGrill => 3,
        _ => 2,
      };

  String get laborEmployerResistanceStatus {
    if (isUnionized) return "Resolved";
    if (laborEmployerResistance < 25) return "Low";
    if (laborEmployerResistance < 50) return "Rising";
    if (laborEmployerResistance < 75) return "High";
    return "Severe";
  }

  void addLaborOrganizingProgress(int amount) {
    laborOrganizingProgress = min(
      100,
      max(0, laborOrganizingProgress + amount),
    );
  }

  void addLaborEmployerResistance(int amount) {
    laborEmployerResistance = min(
      100,
      max(0, laborEmployerResistance + amount),
    );
  }

  void recordLaborRetaliation({bool firedWorker = false}) {
    laborRetaliationIncidents++;
    if (firedWorker) laborWorkersFired++;
  }

  bool get hasLaborContract => laborContractDemand != laborDemandNone;

  String get laborBargainingStatus {
    if (!isUnionized) return "No Union";
    if (hasLaborContract) return "Settled";
    if (laborBargainingImpasse) return "Impasse";
    if (laborBargainingDemand != laborDemandNone) return "Bargaining";
    return "Needs Demands";
  }

  int get activeLaborDemand =>
      hasLaborContract ? laborContractDemand : laborBargainingDemand;

  String get laborDemandName => laborDemandNameFor(activeLaborDemand);

  String laborDemandNameFor(int demand) => switch (demand) {
        laborDemandHigherWages => "Higher Wages",
        laborDemandBetterConditions => "Better Conditions",
        laborDemandJobSecurity => "Job Security",
        laborDemandUnionProtections => "Union Protections",
        _ => "None",
      };

  int laborDemandDifficultyFor(int demand) => switch (demand) {
        laborDemandHigherWages => 4,
        laborDemandBetterConditions => 2,
        laborDemandJobSecurity => 4,
        laborDemandUnionProtections => 5,
        _ => 0,
      };

  String laborDemandDifficultyLabelFor(int demand) => switch (demand) {
        laborDemandHigherWages => "Hard",
        laborDemandBetterConditions => "Easier",
        laborDemandJobSecurity => "Hard",
        laborDemandUnionProtections => "Hardest",
        _ => "None",
      };

  void startLaborBargaining(int demand) {
    if (!isUnionized || hasLaborContract) return;
    if (demand < laborDemandHigherWages ||
        demand > laborDemandUnionProtections) {
      return;
    }
    laborBargainingDemand = demand;
    laborBargainingProgress = 0;
    laborBargainingStalledRounds = 0;
    laborBargainingImpasse = false;
  }

  void recordLaborBargainingSuccess(int progress) {
    laborBargainingProgress = min(
      100,
      max(0, laborBargainingProgress + progress),
    );
    laborBargainingStalledRounds = 0;
  }

  void recordLaborBargainingFailure() {
    laborBargainingStalledRounds++;
    if (laborBargainingStalledRounds >= 3) {
      laborBargainingImpasse = true;
    }
  }

  void settleLaborContract() {
    if (laborBargainingDemand == laborDemandNone) return;
    laborContractDemand = laborBargainingDemand;
    laborBargainingProgress = 100;
    laborBargainingStalledRounds = 0;
    laborBargainingImpasse = false;

    int resistanceReduction = switch (laborContractDemand) {
      laborDemandHigherWages => 5,
      laborDemandBetterConditions => 10,
      laborDemandJobSecurity => 15,
      laborDemandUnionProtections => 25,
      _ => 0,
    };
    addLaborEmployerResistance(-resistanceReduction);
  }

  int get extraHeatFromCCSTarget {
    if (!ccsActive || !lcsInPublicEye) return 0;
    int ccsReach = ccsState.index;
    if (!city.sites.any((s) => s.controller == SiteController.ccs)) {
      ccsReach -= 2;
    }
    if (ccsReach < 0) ccsReach = 0;
    int target =
        ccsReach *
        creaturesPresent.where((e) => e.isCriminal && e.isActiveLiberal).length;
    if ([
      SiteType.barAndGrill,
      SiteType.bombShelter,
      SiteType.bunker,
    ].contains(type)) {
      target *= 3;
    }
    return target;
  }

  @JsonKey()
  bool hasFlag = false;
  @JsonKey(defaultValue: 'FLAG_US')
  String flyingFlagId = 'FLAG_US';
  FlagType? get flyingFlag => hasFlag ? flagTypes[flyingFlagId] : null;
  @JsonKey(includeToJson: true, includeFromJson: true, defaultValue: false)
  bool _businessFront = false;
  bool get businessFront {
    if (type == SiteType.barAndGrill) {
      return true;
    }
    return _businessFront;
  }

  set businessFront(bool value) => _businessFront = value;
  @JsonKey()
  int closed = 0;
  bool get isClosed => closed > 0;
  @JsonKey()
  int highSecurity = 0;
  bool get hasHighSecurity => highSecurity > 0;
  @JsonKey()
  bool hidden = false;
  @JsonKey()
  bool mapped = false;
  @JsonKey()
  int id;
  @JsonKey()
  int cityId;
  @override
  City get city => cities.firstWhere((c) => c.id == cityId);
  @JsonKey()
  int districtId;
  District get district => districts.firstWhere((d) => d.id == districtId);
  @JsonKey()
  Compound compound = Compound();
  @JsonKey()
  List<Item> loot = [];
  @JsonKey()
  int mapseed;
  @JsonKey()
  List<SiteTileChange> changes = [];

  @JsonKey()
  @override
  String name;
  @JsonKey()
  String shortName;
  @JsonKey()
  String? frontName;
  @JsonKey()
  String? frontShortName;

  bool get upgradable {
    switch (type) {
      case SiteType.warehouse:
      case SiteType.barAndGrill:
      case SiteType.bombShelter:
      case SiteType.bunker:
      case SiteType.drugHouse:
        return true;
      default:
        return false;
    }
  }

  bool get discreet {
    if (type == SiteType.bombShelter || type == SiteType.bunker) {
      return true;
    }
    return false;
  }

  void rename(String name, String shortName) {
    this.name = name;
    this.shortName = shortName;
  }

  @override
  int get area => district.area;

  bool get isPartOfTheJusticeSystem =>
      type == SiteType.policeStation ||
      type == SiteType.courthouse ||
      type == SiteType.prison;
  bool get isSafehouse => controller == SiteController.lcs;

  bool get chargesRent =>
      type == SiteType.tenement ||
      type == SiteType.apartment ||
      type == SiteType.upscaleApartment;

  @override
  String getName({bool short = false, bool includeCity = false}) {
    String fullName = short
        ? (frontShortName ?? shortName)
        : (frontName ?? name);
    if (includeCity && multipleCityMode) {
      return '$fullName, ${city.getName(short: true)}';
    } else {
      return fullName;
    }
  }

  Iterable<Creature> get creaturesPresent =>
      pool.where((element) => element.locationId == idString);

  int get numberEating => creaturesPresent
      .where((e) => e.alive && e.align == Alignment.liberal)
      .length;

  int get foodDaysLeft => (compound.rations / max(numberEating, 1)).round();

  int get heatProtection {
    int protection = 15;
    if (type == SiteType.homelessEncampment) protection = 3;
    if (type == SiteType.tenement) protection = 30;
    if (type == SiteType.apartment) protection = 60;
    if (type == SiteType.upscaleApartment || discreet || businessFront) {
      protection = 80;
    }
    int flagSecrecy = flagSecrecyWhenFlying(flyingFlag);
    if (flagSecrecy > 0) protection += flagSecrecy;
    return protection.clamp(0, 95);
  }

  @override
  String get idString => "Site$id";

  @override
  void init() {
    mapseed = nextRngSeed;
    hasFlag = false;
    newRental = false;
    heat = 0;
    closed = 0;
    mapped = false;
    highSecurity = 0;
    changes.clear();
    compound = Compound();
    businessFront = false;

    initSiteName(this);
  }

  bool isDuplicateLocation() {
    return sites.any((e) => e != this && e.name == name);
  }

  /* add all items from a list to a location, and deal with money properly */
  void addLootAndProcessMoney(List<Item> loot) {
    List<Item> lootCopy = loot.toList();
    loot.clear();
    for (Item l in lootCopy) {
      if (l is Money) {
        ledger.addFunds(l.stackSize, Income.thievery);
      } else {
        // Empty squad inventory into base inventory
        this.loot.add(l);
      }
    }
  }
}

enum SiteController { lcs, ccs, unaligned }

Site? findSiteInSameCity(City? city, SiteType type) =>
    city?.sites.firstWhereOrNull((e) => e.type == type);

void initSiteName(Site loc) {
  // NOTE: make sure to keep code here matching code in updateworld_laws() in
  // monthly.cpp for when names are changed
  switch (loc.type) {
    case SiteType.policeStation:
      if (deathSquadsActive) {
        loc.rename("Death Squad HQ", "Death HQ");
      } else {
        loc.rename("Police Station", "Police");
      }
    case SiteType.courthouse:
      if (laws[Law.deathPenalty] == DeepAlignment.archConservative) {
        loc.rename("Halls of Ultimate Judgment", "Judge Hall");
      } else {
        loc.rename("Courthouse", "Courthouse");
      }
    case SiteType.fireStation:
      if (noProfanity) {
        loc.rename("Fireman HQ", "Fire HQ");
        loc.hidden = false;
      } else {
        loc.rename("Fire Station", "Fire Dept.");
        loc.hidden = true;
      }
    case SiteType.prison:
      if (laws[Law.prisons] == DeepAlignment.archConservative) {
        const adjective = ["Happy", "Cheery", "Quiet", "Green", "Nectar"];
        const noun = ["Valley", "Meadow", "Hills", "Glade", "Forest"];
        loc.name = "${adjective.random} ${noun.random} Forced Labor Camp";
        loc.shortName = "Joycamp";
      } else {
        loc.name = "${lastName(Gender.whiteMalePatriarch)} Prison";
        loc.shortName = "Prison";
      }
    case SiteType.universityHospital:
      switch (loc.cityId) {
        case 1: // Seattle
          loc.name = "UW Medical Center";
          loc.shortName = "UW Medical";
        case 2: // New York
          loc.name = "NewYork-Presbyterian Hospital";
          loc.shortName = "NYP Hospital";
        case 3: // Los Angeles
          loc.name = "LA General Medical Center";
          loc.shortName = "LA General";
        case 4: // Washington DC
          loc.name = "MedStar Washington";
          loc.shortName = "MedStar";
        default: // It is a mystery
          loc.name = "University Hospital";
          loc.shortName = "Hospital";
      }
    case SiteType.nursingHome:
      const adjective = [
        "Happy",
        "Gentle",
        "Quiet",
        "Radiant",
        "Loving",
        "Tender",
        "Joyful",
      ];
      const noun = [
        "Journey",
        "Moments",
        "Compass",
        "Touch",
        "Oasis",
        "Care",
        "Reflections",
      ];
      loc.name = "${adjective.random} ${noun.random} Nursing Home";
      loc.shortName = "NursingHome";
    case SiteType.insuranceOffice:
      const adjective = ["United", "Human", "Blue", "First", "Golden"];
      const noun = ["Cross", "Health", "Care", "Life", "Well"];
      loc.name = "${adjective.random} ${noun.random} Insurance";
      loc.shortName = "Insurance";
    case SiteType.nuclearPlant:
      if (laws[Law.nuclearPower] == DeepAlignment.eliteLiberal) {
        loc.rename("Nuclear Waste Center", "Nuclear");
      } else {
        loc.rename("Nuclear Power Plant", "Nuclear");
      }
    case SiteType.intelligenceHQ:
      if (nineteenEightyFour) {
        loc.rename("Ministry of Love", "Miniluv");
      } else {
        loc.rename("Intelligence HQ", "Int. HQ");
      }
    case SiteType.armyBase:
      if (nineteenEightyFour) {
        loc.rename("Ministry of Peace", "Minipax");
      } else {
        loc.name = "${lastName(Gender.whiteMalePatriarch)} Army Base";
        loc.shortName = "Army Base";
      }
    case SiteType.pawnShop:
      String name = lastName();
      if (laws[Law.gunControl] == DeepAlignment.eliteLiberal) {
        loc.name = "$name's Pawnshop";
      } else {
        loc.name = "$name Pawn & Gun";
      }
      loc.shortName = "Pawnshop";
    case SiteType.ceoHouse:
      if (corporateFeudalism) {
        loc.rename("CEO Castle", "CEO Castle");
      } else {
        loc.rename("CEO Mansion", "CEO House");
      }
    case SiteType.warehouse:
      do {
        loc.name = ["Abandoned ", "Forgotten ", "Old ", "Haunted "].random;
        switch (lcsRandom(10)) {
          case 0:
            loc.name += "Meat Plant";
            loc.shortName = "Meat Plant";
          case 1:
            loc.name += "Warehouse";
            loc.shortName = "Warehouse";
          case 2:
            loc.name += "Paper Mill";
            loc.shortName = "Paper Mill";
          case 3:
            loc.name += "Schoolhouse";
            loc.shortName = "School";
          case 4:
            loc.name += "Motel";
            loc.shortName = "Old Motel";
          case 5:
            loc.name += "Bus Garage";
            loc.shortName = "Bus Garage";
          case 6:
            loc.name += "Steel Plant";
            loc.shortName = "Steel Plant";
          case 7:
            loc.name += "Church";
            loc.shortName = "Old Church";
          case 8:
            loc.name += "Toy Factory";
            loc.shortName = "Toymakers";
          case 9:
            loc.name += "Train Station";
            loc.shortName = "Station";
          case 10:
            loc.name += "Auto Plant";
            loc.shortName = "Auto Plant";
          case 11:
            loc.name += "Textile Mill";
            loc.shortName = "Textile Mill";
          case 12:
            loc.name += "Cannery";
            loc.shortName = "Cannery";
          case 13:
            loc.name += "Office Building";
            loc.shortName = "Offices";
          case 14:
            loc.name += "Brewery";
            loc.shortName = "Brewery";
          case 15:
            loc.name += "Clinic";
            loc.shortName = "Old Clinic";
          case 16:
            loc.name += "Library";
            loc.shortName = "Library";
          case 17:
            loc.name += "Museum";
            loc.shortName = "Museum";
          case 18:
            loc.name += "Restaurant";
            loc.shortName = "Restaurant";
        }
      } while (loc.isDuplicateLocation());
    case SiteType.dirtyIndustry:
      switch (lcsRandom(5)) {
        case 0:
          loc.rename("Aluminum Factory", "Alum Fact");
        case 1:
          loc.rename("Plastic Factory", "Plast Fact");
        case 2:
          loc.rename("Oil Refinery", "Refinery");
        case 3:
          loc.rename("Auto Plant", "Auto Plant");
        case 4:
          loc.rename("Chemical Factory", "Chem Fact");
      }
    case SiteType.upscaleApartment:
      do {
        String name = lastName();
        loc.shortName = "Condos";
        loc.name = "$name Condominiums";
      } while (loc.isDuplicateLocation());
    case SiteType.apartment:
      do {
        String name = lastName();
        loc.shortName = "Apartment";
        loc.name = "$name Apartments";
      } while (loc.isDuplicateLocation());
    case SiteType.tenement:
      do {
        String name;
        do {
          name = lastName();
        } while (name.length > 7);
        loc.name = "$name St. Public Housing";
        loc.shortName = "Public Hsg.";
      } while (loc.isDuplicateLocation());
    case SiteType.geneticsLab:
      loc.name = "${lastName()} Genetics";
      loc.shortName = "Genetics";
    case SiteType.cosmeticsLab:
      loc.name = "${lastName()} Cosmetics";
      loc.shortName = "Cosmetics";
    case SiteType.carDealership:
      String name = firstName(Gender.whiteMalePatriarch);
      loc.name = "$name's Used Cars";
      loc.shortName = "Car Dealer";
    case SiteType.departmentStore:
      loc.name = "${lastName()} Superstore";
      loc.shortName = "Superstore";
    case SiteType.sweatshop:
      loc.name = "${lastName()} Garment Makers";
      loc.shortName = "Sweatshop";
    case SiteType.drugHouse:
      if (loc.controller == SiteController.lcs) {
        String name = loc.name.split(" ").first;
        loc.name = "$name St. Safehouse";
        loc.shortName = "Safehouse";
      } else {
        do {
          String name = lastName();
          loc.name = "$name St. ";
          if (laws[Law.drugs] == DeepAlignment.eliteLiberal) {
            switch (lcsRandom(4)) {
              case 0:
                loc.name += "Recreational Drugs Center";
                loc.shortName = "Drug Shop";
              case 1:
                loc.name += "Cannabis Lounge";
                loc.shortName = "Pot Lounge";
              case 2:
                loc.name += "Marijuana Dispensary";
                loc.shortName = "Dispensary";
            }
          } else {
            loc.name += "Drug House";
            loc.shortName = "Drug House";
          }
        } while (loc.isDuplicateLocation());
      }
    case SiteType.juiceBar:
      const adj = ["Natural", "Harmonious", "Restful", "Healthy", "New You"];
      const noun = ["Diet", "Methods", "Plan", "Orange", "Carrot"];
      loc.name = "${adj.random} ${noun.random} Juice Bar";
      loc.shortName = "Juice Bar";
    case SiteType.veganCoOp:
      const veggie = ["Asparagus", "Tofu", "Broccoli", "Radish", "Eggplant"];
      const noun = ["Forest", "Rainbow", "Garden", "Farm", "Meadow"];
      loc.name = "${veggie.random} ${noun.random} Vegan Co-op";
      loc.shortName = "Vegan";
    case SiteType.internetCafe:
      const adj = ["Open", "Urban", "Remote", "Civic", "Cloud"];
      const noun = ["Hub", "Commons", "Works", "Desk", "Collective"];
      loc.name = "${adj.random} ${noun.random} Coworking Space";
      loc.shortName = "Cowork";
    case SiteType.latteStand:
      const adj = ["Frothy", "Milky", "Caffeine", "Morning", "Evening"];
      const noun = ["Mug", "Cup", "Jolt", "Wonder", "Express"];
      loc.name = "${adj.random} ${noun.random} Coffee Kiosk";
      loc.shortName = "Coffee";
    case SiteType.publicPark:
      loc.name = "${lastName()} Park";
      loc.shortName = "Park";
    case SiteType.barAndGrill:
      if (loc.controller == SiteController.lcs) {
        loc.name = "Vegan Bar & Grill";
        loc.shortName = "Vegan Bar";
      } else {
        loc.name = "Desert Eagle Bar & Grill";
        loc.shortName = "Deagle Bar";
      }
    case SiteType.bunker:
      if (loc.controller == SiteController.lcs) {
        loc.name = "Liberation Bunker";
        loc.shortName = "Bunker";
      } else {
        loc.name = "Robert E. Lee Bunker";
        loc.shortName = "Bunker";
      }
    default:
      break;
  }
}

import 'package:lcs_new_age/basemode/blind_time_log.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/politics/laws.dart';
import 'package:lcs_new_age/utils/lcsrandom.dart';

Future<void> advanceLaborUnionLocals() async {
  int localCount = 0;
  int totalDues = 0;

  for (Site site in sites) {
    if (!site.supportsLaborOrganizing || !site.isUnionized) continue;

    site.establishLaborUnionLocal();
    int duesPercent = switch (laws[Law.labor]!) {
      DeepAlignment.archConservative => 70,
      DeepAlignment.conservative => 85,
      DeepAlignment.moderate => 100,
      DeepAlignment.liberal => 115,
      DeepAlignment.eliteLiberal => 130,
    };
    if (site.laborStrikeActive) duesPercent = duesPercent * 60 ~/ 100;

    int dues = site.laborUnionMonthlyDuesBase * duesPercent ~/ 100;
    dues = dues.clamp(25, 1000);
    int beforeFund = site.laborStrikeFund;
    site.addLaborStrikeFund(dues);
    int collected = site.laborStrikeFund - beforeFund;
    site.laborUnionDuesLastMonth = collected;
    if (collected > 0) {
      localCount++;
      totalDues += collected;
    }

    await _advanceLaborGrievances(site);
  }

  if (localCount == 0 || totalDues == 0) return;
  String localWord = localCount == 1 ? "local" : "locals";
  await showMessageOrLog(
    "$localCount union $localWord collected \$$totalDues in member dues "
    "this month. The money remains in their workplace union reserves.",
  );
}

Future<void> _advanceLaborGrievances(Site site) async {
  if (!site.hasLaborContract) return;

  if (site.hasActiveLaborGrievance) {
    site.advanceLaborGrievanceMonth();
    if (site.laborGrievanceMonthsOpen >= 3) {
      String issue = site.laborGrievanceName;
      site.loseLaborGrievance();
      await showMessageOrLog(
        "The union at ${site.name} lets its $issue grievance go unresolved. "
        "Management grows bolder and the local loses organizational strength.",
      );
    }
    return;
  }

  if (site.laborStrikeActive) return;

  int lawViolationModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => 15,
    DeepAlignment.conservative => 8,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => -5,
    DeepAlignment.eliteLiberal => -10,
  };
  int protection =
      site.hasLaborDemand(Site.laborDemandUnionProtections) ? 12 : 0;
  int violationChance = (15 +
          site.laborUnionBustStrength * 2 +
          site.laborEmployerResistance ~/ 5 +
          lawViolationModifier -
          site.laborUnionLocalStrengthForEffects ~/ 6 -
          protection)
      .clamp(0, 55);
  if (lcsRandom(100) >= violationChance) return;

  List<int> securedDemands = [
    Site.laborDemandHigherWages,
    Site.laborDemandBetterConditions,
    Site.laborDemandJobSecurity,
    Site.laborDemandUnionProtections,
  ].where(site.hasLaborDemand).toList();
  if (securedDemands.isEmpty) return;
  int demand = securedDemands[lcsRandom(securedDemands.length)];

  int detectionChance = (50 +
          site.laborUnionLocalStrengthForEffects ~/ 2 +
          (site.hasLaborDemand(Site.laborDemandUnionProtections) ? 15 : 0) -
          site.laborUnionBustStrength * 3 -
          site.laborEmployerResistance ~/ 10)
      .clamp(20, 95);

  if (lcsRandom(100) >= detectionChance) {
    site.addLaborUnionLocalStrength(-1);
    site.addLaborEmployerResistance(2);
    return;
  }

  site.startLaborGrievance(demand);
  site.addLaborEmployerResistance(2);
  await showMessageOrLog(_laborViolationMessage(site, demand));
}

String _laborViolationMessage(Site site, int demand) => switch (demand) {
      Site.laborDemandHigherWages =>
        "Stewards at ${site.name} document payroll shorting that violates the "
            "union's Higher Wages agreement. A contract grievance is now open.",
      Site.laborDemandBetterConditions =>
        "Stewards at ${site.name} document scheduling and workplace-condition "
            "violations. A Better Conditions grievance is now open.",
      Site.laborDemandJobSecurity =>
        "Management at ${site.name} disciplines a worker without the contract's "
            "just-cause protections. A Job Security grievance is now open.",
      Site.laborDemandUnionProtections =>
        "Management at ${site.name} interferes with steward access and union "
            "representation rights. A Union Protections grievance is now open.",
      _ =>
        "The union at ${site.name} documents a contract violation and opens a "
            "grievance.",
    };

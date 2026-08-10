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
    dues = dues * site.laborUnionDuesContractPercent ~/ 100;
    dues = dues.clamp(25, 1250);
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
    if (site.laborGrievanceLegalReview) {
      if (site.laborGrievanceMonthsOpen >= 3) {
        await _resolveLaborGrievanceLegalReview(site);
      }
      return;
    }

    if (site.laborGrievanceMonthsOpen >= 2) {
      site.escalateLaborGrievanceToLegalReview();
      String forum = site.laborGrievanceUsesArbitration
          ? "contract arbitration"
          : "the labor board";
      await showMessageOrLog(
        "Management at ${site.name} has not resolved the union's "
        "${site.laborGrievanceName} grievance. The case escalates to $forum. "
        "Additional grievance work can strengthen the record before a "
        "binding decision next month.",
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


Future<void> _resolveLaborGrievanceLegalReview(Site site) async {
  if (!site.hasActiveLaborGrievance || !site.laborGrievanceLegalReview) return;

  int lawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -18,
    DeepAlignment.conservative => -9,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 9,
    DeepAlignment.eliteLiberal => 18,
  };
  if (site.laborGrievanceUsesArbitration) {
    lawModifier ~/= 2;
  }

  int forumBonus = site.laborGrievanceUsesArbitration ? 12 : 0;
  int unionCase = site.laborGrievanceProgress +
      site.laborUnionLocalStrengthForEffects ~/ 2 +
      lawModifier +
      forumBonus +
      lcsRandom(30);
  int employerCase = 45 +
      site.laborUnionBustStrength * 3 +
      site.laborEmployerResistance ~/ 3 +
      lcsRandom(20);

  String issue = site.laborGrievanceName;
  bool arbitration = site.laborGrievanceUsesArbitration;
  String forum = arbitration ? "The arbitrator" : "The labor board";
  if (unionCase >= employerCase) {
    site.resolveLaborGrievance();
    await showMessageOrLog(
      "$forum rules for the union at ${site.name} on its $issue grievance. "
      "Management is ordered to remedy the contract violation, and the "
      "enforcement victory strengthens the local.",
    );
    return;
  }

  site.loseLaborGrievance();
  String reason = arbitration
      ? "The arbitrator accepts management's defense"
      : "The labor board declines to sustain the union's charge";
  await showMessageOrLog(
    "$reason at ${site.name}. The $issue grievance is lost, management grows "
    "bolder, and the local loses strength. The underlying contract term "
    "remains in force.",
  );
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

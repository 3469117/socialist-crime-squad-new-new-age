import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_actions/common_actions.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/creature_type.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/daily/activities/arrest.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/gamestate/ledger.dart';
import 'package:lcs_new_age/justice/crimes.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/politics/laws.dart';
import 'package:lcs_new_age/utils/lcsrandom.dart';

Future<void> doActivityOrganizeWorkers(Creature organizer) async {
  Site? workplace = organizer.activity.location;
  if (workplace == null ||
      !workplace.supportsLaborOrganizing ||
      workplace.controller != SiteController.unaligned) {
    organizer.activity = Activity.none();
    return;
  }

  if (workplace.isUnionized) {
    organizer.activity = Activity.none();
    return;
  }

  int progressLawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -4,
    DeepAlignment.conservative => -2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 2,
    DeepAlignment.eliteLiberal => 4,
  };

  int resistanceLawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => 3,
    DeepAlignment.conservative => 2,
    DeepAlignment.moderate => 1,
    DeepAlignment.liberal => 0,
    DeepAlignment.eliteLiberal => -1,
  };

  int persuasionRoll = organizer.skillRoll(Skill.persuasion);
  int businessSupport = organizer.skill(Skill.business) ~/ 2;
  int resistancePenalty = workplace.laborEmployerResistance ~/ 20;
  int progress =
      (persuasionRoll +
              businessSupport +
              progressLawModifier -
              resistancePenalty -
              4)
          .clamp(1, 12);

  int beforeProgress = workplace.laborOrganizingProgress;
  workplace.addLaborOrganizingProgress(progress);

  // Reaching 100 ends the drive immediately. Management does not get one
  // final counter-campaign after the workers have already won recognition.
  if (workplace.isUnionized) {
    workplace.establishLaborUnionLocal();
    organizer.train(Skill.persuasion, 10 + progress);
    organizer.train(Skill.business, 5 + progress ~/ 2);
    addjuice(organizer, 10, 100);
    await showMessage("Workers at ${workplace.name} have unionized!");
    organizer.activity = Activity.none();
    return;
  }

  int beforeResistance = workplace.laborEmployerResistance;
  int resistanceGain =
      (workplace.laborUnionBustStrength +
              resistanceLawModifier -
              organizer.skill(Skill.business) ~/ 5)
          .clamp(0, 7);
  workplace.addLaborEmployerResistance(resistanceGain);

  if (beforeResistance < 25 && workplace.laborEmployerResistance >= 25) {
    await showMessage(
      "Management at ${workplace.name} has hired union-avoidance consultants "
      "and begun mandatory anti-union meetings.",
    );
  } else if (beforeResistance < 50 &&
      workplace.laborEmployerResistance >= 50) {
    await showMessage(
      "Management at ${workplace.name} is changing schedules and leaning on "
      "supervisors to isolate union supporters.",
    );
  } else if (beforeResistance < 75 &&
      workplace.laborEmployerResistance >= 75) {
    await showMessage(
      "${workplace.name} has escalated to a full union-busting campaign.",
    );
  }

  await _resolveEmployerCounterCampaign(
    organizer,
    workplace,
    resistanceLawModifier,
  );
  await _resolveEmployerRetaliation(
    organizer,
    workplace,
    resistanceLawModifier,
  );

  if (workplace.isUnionized) {
    workplace.establishLaborUnionLocal();
    addjuice(organizer, 10, 100);
    await showMessage("Workers at ${workplace.name} have unionized!");
    organizer.activity = Activity.none();
    return;
  }

  organizer.train(Skill.persuasion, 10 + progress);
  organizer.train(Skill.business, 8 + progress ~/ 2);

  int finalProgress = workplace.laborOrganizingProgress;
  if (beforeProgress < 25 && finalProgress >= 25) {
    await showMessage(
      "${organizer.name} has built an organizing committee at "
      "${workplace.name}.",
    );
  } else if (beforeProgress < 50 && finalProgress >= 50) {
    await showMessage(
      "The organizing drive at ${workplace.name} has reached majority support.",
    );
  } else if (beforeProgress < 75 && finalProgress >= 75) {
    await showMessage(
      "Workers at ${workplace.name} are preparing to formalize their union.",
    );
  }
}

Future<void> _resolveEmployerCounterCampaign(
  Creature organizer,
  Site workplace,
  int resistanceLawModifier,
) async {
  if (workplace.laborEmployerResistance < 20) return;

  int chance =
      (workplace.laborEmployerResistance ~/ 3 +
              workplace.laborUnionBustStrength * 2 +
              resistanceLawModifier * 3 -
              organizer.skill(Skill.business))
          .clamp(0, 60);
  if (lcsRandom(100) >= chance) return;

  int employerRoll = 8 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 15 +
      resistanceLawModifier;
  int organizerRoll = organizer.skillRoll(Skill.business);
  organizer.train(Skill.business, 10);

  if (organizerRoll >= employerRoll) {
    await showMessage(
      "${organizer.name} anticipates management's anti-union campaign at "
      "${workplace.name} and keeps the drive on track.",
    );
    return;
  }

  int setback = (employerRoll - organizerRoll).clamp(2, 10);
  workplace.addLaborOrganizingProgress(-setback);

  await showMessage(
    "Management's anti-union campaign at ${workplace.name} shakes worker "
    "support. The organizing drive loses $setback percentage points.",
  );
}


Future<void> _resolveEmployerRetaliation(
  Creature organizer,
  Site workplace,
  int resistanceLawModifier,
) async {
  if (workplace.laborEmployerResistance < 35 ||
      workplace.laborOrganizingProgress < 15) {
    return;
  }

  int chance =
      (workplace.laborEmployerResistance ~/ 4 +
              workplace.laborUnionBustStrength * 2 +
              resistanceLawModifier * 4 -
              organizer.skill(Skill.business) -
              workplace.laborRetaliationIncidents * 4)
          .clamp(0, 45);
  if (lcsRandom(100) >= chance) return;

  int warningDifficulty =
      8 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 20 +
      resistanceLawModifier.clamp(0, 3);
  int businessRoll = organizer.skillRoll(Skill.business);
  organizer.train(Skill.business, 8);

  if (businessRoll >= warningDifficulty) {
    workplace.recordLaborRetaliation();
    await showMessage(
      "${organizer.name} catches management preparing retaliation at "
      "${workplace.name}. Workers document the threats before anyone is "
      "disciplined.",
    );
    workplace.addLaborEmployerResistance(-2);
    return;
  }

  Creature? sleeper = _findRetaliationTarget(workplace);
  bool firing =
      workplace.laborEmployerResistance >= 60 || lcsRandom(100) < 50;

  if (sleeper != null && firing) {
    workplace.recordLaborRetaliation(firedWorker: true);
    _fireSleeperWorker(sleeper, workplace, organizer);
    await showMessage(
      "${sleeper.name} has been fired from ${workplace.name} for suspected "
      "union activity and reports back to the SCS.",
    );
  } else if (firing) {
    workplace.recordLaborRetaliation(firedWorker: true);
    await showMessage(
      "Management at ${workplace.name} fires a worker identified as a union "
      "supporter.",
    );
  } else {
    workplace.recordLaborRetaliation();
    await showMessage(
      "Management at ${workplace.name} cuts hours and changes schedules for "
      "workers identified as union supporters.",
    );
  }

  int solidarityRoll =
      organizer.skillRoll(Skill.persuasion) +
      workplace.laborOrganizingProgress ~/ 20;
  int intimidation =
      9 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 20 +
      resistanceLawModifier.clamp(0, 3);
  organizer.train(Skill.persuasion, 10);

  if (solidarityRoll >= intimidation) {
    int solidarityGain = (solidarityRoll - intimidation + 2).clamp(2, 8);
    workplace.addLaborOrganizingProgress(solidarityGain);
    await showMessage(
      "The retaliation at ${workplace.name} backfires. Coworkers rally around "
      "the targeted workers, adding $solidarityGain percentage points of "
      "organizing support.",
    );
  } else {
    int setback =
        (intimidation - solidarityRoll + (firing ? 3 : 1)).clamp(3, 10);
    workplace.addLaborOrganizingProgress(-setback);
    await showMessage(
      "Management's retaliation at ${workplace.name} intimidates workers. "
      "The organizing drive loses $setback percentage points.",
    );
  }
}

Creature? _findRetaliationTarget(Site workplace) {
  for (Creature person in pool) {
    if (!person.sleeperAgent || person.workSite != workplace) continue;
    if (_isManagementRetaliationExempt(person)) continue;
    return person;
  }
  return null;
}

bool _isManagementRetaliationExempt(Creature person) => switch (person.type.id) {
      CreatureTypeIds.corporateCEO ||
      CreatureTypeIds.insuranceCEO ||
      CreatureTypeIds.bankManager ||
      CreatureTypeIds.corporateManager ||
      CreatureTypeIds.nursingHomeAdmin ||
      CreatureTypeIds.securityGuard ||
      CreatureTypeIds.merc ||
      CreatureTypeIds.agent =>
        true,
      _ => false,
    };

void _fireSleeperWorker(
  Creature worker,
  Site workplace,
  Creature organizer,
) {
  Site? refuge;

  for (Site site in workplace.city.sites) {
    if (site.controller == SiteController.lcs && !site.siege.underSiege) {
      refuge = site;
      break;
    }
  }

  refuge ??= organizer.base;
  if (refuge == null || refuge.siege.underSiege) {
    for (Site site in sites) {
      if (site.controller == SiteController.lcs && !site.siege.underSiege) {
        refuge = site;
        break;
      }
    }
  }

  worker.squad = null;
  worker.activity = Activity.none();
  worker.workLocation = null;
  worker.income = 0;
  worker.sleeperAgent = false;

  if (refuge != null) {
    worker.location = refuge;
    worker.base = refuge;
  } else {
    worker.location = workplace.city;
    worker.base = null;
  }
}

Future<void> doActivityNegotiateUnionContract(Creature negotiator) async {
  Site? workplace = negotiator.activity.location;
  if (workplace == null ||
      !workplace.supportsLaborOrganizing ||
      workplace.controller != SiteController.unaligned ||
      !workplace.isUnionized ||
      workplace.hasAllLaborDemands) {
    negotiator.activity = Activity.none();
    return;
  }

  if (workplace.laborBargainingDemand == Site.laborDemandNone) {
    int demand = negotiator.activity.idInt ?? Site.laborDemandNone;
    workplace.startLaborBargaining(demand);
    if (workplace.laborBargainingDemand == Site.laborDemandNone) {
      negotiator.activity = Activity.none();
      return;
    }
  }

  if (workplace.laborBargainingImpasse) {
    await showMessage(
      "Bargaining at ${workplace.name} has reached an impasse. Use Support "
      "Strike & Picket to put pressure on management.",
    );
    negotiator.activity = Activity.none();
    return;
  }

  int lawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -4,
    DeepAlignment.conservative => -2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 2,
    DeepAlignment.eliteLiberal => 4,
  };

  int demandDifficulty = workplace.laborDemandDifficultyFor(
    workplace.laborBargainingDemand,
  );
  workplace.establishLaborUnionLocal();
  int persuasionRoll = negotiator.skillRoll(Skill.persuasion);
  int businessSupport = negotiator.skill(Skill.business) ~/ 2;
  int localSupport = workplace.laborUnionLocalStrengthForEffects ~/ 20;
  int unionRoll =
      persuasionRoll + businessSupport + localSupport + lawModifier;
  int managementDifficulty =
      8 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 25 +
      demandDifficulty;
  int margin = unionRoll - managementDifficulty;

  negotiator.train(Skill.persuasion, 10);
  negotiator.train(Skill.business, 8);

  if (margin >= 0) {
    int beforeProgress = workplace.laborBargainingProgress;
    int progress = (6 + margin).clamp(5, 15);
    workplace.recordLaborBargainingSuccess(progress);
    workplace.addLaborEmployerResistance(-1);

    if (workplace.laborBargainingProgress >= 100) {
      String demand = workplace.laborDemandName;
      workplace.settleLaborContract();
      addjuice(negotiator, 10, 100);
      await showMessage(_laborSettlementMessage(workplace, demand));
      negotiator.activity = Activity.none();
      return;
    }

    int finalProgress = workplace.laborBargainingProgress;
    if (beforeProgress < 25 && finalProgress >= 25) {
      await showMessage(
        "Bargaining at ${workplace.name} has moved beyond opening positions. "
        "Management is discussing the union's ${workplace.laborDemandName} "
        "proposal in detail.",
      );
    } else if (beforeProgress < 50 && finalProgress >= 50) {
      await showMessage(
        "The union at ${workplace.name} has won tentative movement on "
        "${workplace.laborDemandName}.",
      );
    } else if (beforeProgress < 75 && finalProgress >= 75) {
      await showMessage(
        "Negotiations at ${workplace.name} are close to a settlement. Only "
        "the major contract terms remain unresolved.",
      );
    }
    return;
  }

  workplace.recordLaborBargainingFailure();
  workplace.addLaborEmployerResistance(1);
  await showMessage(
    "Management at ${workplace.name} rejects the union's "
    "${workplace.laborDemandName} proposal. This is stalled bargaining round "
    "${workplace.laborBargainingStalledRounds} of 3.",
  );

  if (workplace.laborBargainingImpasse) {
    await showMessage(
      "Talks at ${workplace.name} have reached an impasse. Management will "
      "not move without additional worker pressure.",
    );
    negotiator.activity = Activity.none();
  }
}

Future<void> doActivitySupportLaborStrike(List<Creature> organizers) async {
  if (organizers.isEmpty) return;

  Creature lead = organizers.first;
  Creature businessLead = organizers.first;
  Creature streetLead = organizers.first;
  for (Creature organizer in organizers.skip(1)) {
    if (organizer.skill(Skill.persuasion) > lead.skill(Skill.persuasion)) {
      lead = organizer;
    }
    if (organizer.skill(Skill.business) >
        businessLead.skill(Skill.business)) {
      businessLead = organizer;
    }
    if (organizer.skill(Skill.streetSmarts) >
        streetLead.skill(Skill.streetSmarts)) {
      streetLead = organizer;
    }
  }

  Site? workplace = lead.activity.location;
  if (workplace == null ||
      !workplace.supportsLaborOrganizing ||
      workplace.controller != SiteController.unaligned ||
      !workplace.isUnionized ||
      workplace.hasAllLaborDemands ||
      workplace.laborBargainingDemand == Site.laborDemandNone) {
    _clearLaborStrikeActivities(organizers);
    return;
  }

  if (!workplace.laborStrikeActive) {
    if (!workplace.canStartLaborStrike) {
      _clearLaborStrikeActivities(organizers);
      return;
    }
    workplace.startLaborStrike();
    await showMessage(
      "Workers at ${workplace.name} walk out after bargaining reaches an "
      "impasse. Picket lines form around the union's "
      "${workplace.laborDemandName} demand.",
    );
  }

  if (!workplace.laborStrikeActive) {
    _clearLaborStrikeActivities(organizers);
    return;
  }

  workplace.recordLaborStrikeDay();

  int lawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -4,
    DeepAlignment.conservative => -2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 2,
    DeepAlignment.eliteLiberal => 4,
  };
  int repressionLawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => 4,
    DeepAlignment.conservative => 2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => -2,
    DeepAlignment.eliteLiberal => -4,
  };
  int policeRepressionModifier = switch (laws[Law.policeReform]!) {
    DeepAlignment.archConservative => 4,
    DeepAlignment.conservative => 2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => -2,
    DeepAlignment.eliteLiberal => -4,
  };
  int teamBonus = (organizers.length - 1).clamp(0, 3);

  await _resolveReplacementWorkers(
    lead,
    businessLead,
    streetLead,
    workplace,
    teamBonus,
    repressionLawModifier,
  );
  await _resolveStrikeInjunction(
    lead,
    businessLead,
    workplace,
    repressionLawModifier,
  );
  _buildStrikePolicePressure(
    workplace,
    repressionLawModifier,
    policeRepressionModifier,
  );

  bool strikeSustainable = await _applyStrikeSustainability(workplace);
  if (!strikeSustainable) {
    _clearLaborStrikeActivities(organizers);
    return;
  }

  int bestBusiness = businessLead.skill(Skill.business);
  int bestStreetSmarts = streetLead.skill(Skill.streetSmarts);
  for (Creature organizer in organizers) {
    organizer.train(Skill.persuasion, 8);
    organizer.train(Skill.business, 5);
    organizer.train(Skill.streetSmarts, 6);
  }

  int persuasionRoll = lead.skillRoll(Skill.persuasion);
  int businessSupport = bestBusiness ~/ 3;
  int streetSupport = bestStreetSmarts ~/ 2;
  int picketSupport = workplace.laborPicketStrength ~/ 20;
  int solidaritySupport = workplace.laborStrikeSolidarity ~/ 20;
  int localSupport = workplace.laborUnionLocalStrengthForEffects ~/ 20;
  int hardshipPenalty = workplace.laborStrikeHardship ~/ 15;
  int replacementPenalty = workplace.laborReplacementWorkerCoverage ~/ 15;
  int injunctionPenalty = workplace.laborStrikeInjunction ? 3 : 0;
  int policePenalty = workplace.laborStrikePolicePressure ~/ 30;
  int unionRoll = persuasionRoll +
      businessSupport +
      streetSupport +
      teamBonus +
      picketSupport +
      solidaritySupport +
      localSupport +
      lawModifier -
      hardshipPenalty;
  int managementDifficulty =
      10 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 20 +
      replacementPenalty +
      injunctionPenalty +
      policePenalty;
  int margin = unionRoll - managementDifficulty;

  if (margin >= 0) {
    int beforePressure = workplace.laborStrikePressure;
    int pressureGain =
        (5 + margin + teamBonus -
                workplace.laborReplacementWorkerCoverage ~/ 25)
            .clamp(2, 15);
    int picketGain = (1 + margin ~/ 3 + teamBonus ~/ 2).clamp(1, 6);
    workplace.addLaborStrikePressure(pressureGain);
    workplace.addLaborPicketStrength(picketGain);
    workplace.addLaborStrikeSolidarity((1 + margin ~/ 4).clamp(1, 4));
    workplace.addLaborStrikeHardship(-1);
    workplace.addLaborEmployerResistance(-1);

    if (workplace.laborStrikePressure >= 100) {
      String demand = workplace.laborDemandName;
      int strikeDays = workplace.laborStrikeDays;
      workplace.settleLaborStrike();
      for (Creature organizer in organizers) {
        addjuice(organizer, 12, 150);
      }
      String dayWord = strikeDays == 1 ? "day" : "days";
      String contractProgress = workplace.hasAllLaborDemands
          ? "The union now has all four major demands under contract."
          : "The union has secured ${workplace.laborContractDemandCount} "
              "of 4 major demands.";
      await showMessage(
        "After $strikeDays $dayWord on strike, management at "
        "${workplace.name} accepts the union's $demand package. Workers "
        "ratify the settlement and return to work. $contractProgress",
      );
      _clearLaborStrikeActivities(organizers);
      return;
    }

    int finalPressure = workplace.laborStrikePressure;
    if (beforePressure < 25 && finalPressure >= 25) {
      await showMessage(
        "The strike at ${workplace.name} is disrupting normal operations. "
        "Management is beginning to feel sustained pressure.",
      );
    } else if (beforePressure < 50 && finalPressure >= 50) {
      await showMessage(
        "The picket line at ${workplace.name} is holding. The strike is now "
        "imposing serious operational costs on management.",
      );
    } else if (beforePressure < 75 && finalPressure >= 75) {
      await showMessage(
        "Management at ${workplace.name} is nearing a breaking point as the "
        "strike continues to build pressure.",
      );
    } else {
      await showMessage(
        "Pickets at ${workplace.name} hold firm. Strike pressure rises by "
        "$pressureGain points.",
      );
    }

    await _resolveStrikePoliceIntervention(
      organizers,
      streetLead,
      workplace,
      teamBonus,
      repressionLawModifier,
      policeRepressionModifier,
    );
    return;
  }

  int gap = -margin;
  int picketLoss =
      (2 + gap - teamBonus +
              workplace.laborReplacementWorkerCoverage ~/ 25 +
              workplace.laborStrikeHardship ~/ 25 +
              (workplace.laborStrikeInjunction ? 1 : 0))
          .clamp(1, 14);
  int pressureLoss =
      ((gap + 2) ~/ 3 + workplace.laborReplacementWorkerCoverage ~/ 35)
          .clamp(1, 6);
  workplace.addLaborPicketStrength(-picketLoss);
  workplace.addLaborStrikePressure(-pressureLoss);
  workplace.addLaborStrikeSolidarity(-(1 + gap ~/ 3).clamp(1, 5));
  workplace.addLaborStrikeHardship(1);
  workplace.addLaborEmployerResistance(1);

  if (workplace.laborPicketStrength <= 0 ||
      workplace.laborStrikeSolidarity <= 0 ||
      workplace.laborStrikeHardship >= 100) {
    int strikeDays = workplace.laborStrikeDays;
    bool hardshipCollapse = workplace.laborStrikeHardship >= 100;
    bool solidarityCollapse = workplace.laborStrikeSolidarity <= 0;
    workplace.defeatLaborStrike();
    String dayWord = strikeDays == 1 ? "day" : "days";
    String reason = hardshipCollapse
        ? "Worker hardship becomes unsustainable"
        : solidarityCollapse
            ? "Solidarity breaks down under sustained pressure"
            : "The picket line collapses";
    await showMessage(
      "After $strikeDays $dayWord at ${workplace.name}, $reason. Workers "
      "return without settling the demand. Bargaining can resume, but "
      "management is emboldened by the failed strike.",
    );
    _clearLaborStrikeActivities(organizers);
    return;
  }

  await showMessage(
    "Management at ${workplace.name} withstands another day of the strike. "
    "Picket strength falls by $picketLoss points and strike pressure slips "
    "by $pressureLoss.",
  );

  await _resolveStrikePoliceIntervention(
    organizers,
    streetLead,
    workplace,
    teamBonus,
    repressionLawModifier,
    policeRepressionModifier,
  );
}

Future<void> doActivityBuildUnionLocal(
  List<Creature> organizers,
) async {
  if (organizers.isEmpty) return;

  Creature lead = organizers.first;
  Creature businessLead = organizers.first;
  for (Creature organizer in organizers.skip(1)) {
    if (organizer.skill(Skill.persuasion) > lead.skill(Skill.persuasion)) {
      lead = organizer;
    }
    if (organizer.skill(Skill.business) >
        businessLead.skill(Skill.business)) {
      businessLead = organizer;
    }
  }

  Site? workplace = lead.activity.location;
  if (workplace == null ||
      !workplace.supportsLaborOrganizing ||
      workplace.controller != SiteController.unaligned ||
      !workplace.isUnionized) {
    _clearLaborStrikeActivities(organizers);
    return;
  }

  workplace.establishLaborUnionLocal();
  if (workplace.laborUnionLocalStrength >= 100) {
    _clearLaborStrikeActivities(organizers);
    return;
  }

  int lawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -2,
    DeepAlignment.conservative => -1,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 1,
    DeepAlignment.eliteLiberal => 2,
  };
  int teamBonus = (organizers.length - 1).clamp(0, 3);
  int localStrength = workplace.laborUnionLocalStrengthForEffects;
  int unionRoll = lead.skillRoll(Skill.persuasion) +
      businessLead.skill(Skill.business) ~/ 2 +
      lawModifier +
      teamBonus;
  int difficulty =
      8 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 30 +
      localStrength ~/ 25;
  int margin = unionRoll - difficulty;
  int growth = margin >= 0 ? (2 + margin ~/ 3 + teamBonus ~/ 2).clamp(2, 7) : 1;
  int beforeStrength = workplace.laborUnionLocalStrength;
  workplace.addLaborUnionLocalStrength(growth);

  for (Creature organizer in organizers) {
    organizer.train(Skill.persuasion, 6);
    organizer.train(Skill.business, 8);
  }

  int afterStrength = workplace.laborUnionLocalStrength;
  if (beforeStrength < 50 && afterStrength >= 50) {
    await showMessage(
      "The union local at ${workplace.name} has built a durable steward "
      "network and regular membership meetings.",
    );
  } else if (beforeStrength < 75 && afterStrength >= 75) {
    await showMessage(
      "The local at ${workplace.name} is now a strong workplace organization "
      "with experienced stewards and reliable member participation.",
    );
  } else if (afterStrength >= 100) {
    for (Creature organizer in organizers) {
      addjuice(organizer, 5, 100);
    }
    await showMessage(
      "The union local at ${workplace.name} has become a powerhouse. Its "
      "internal organization is as strong as it can be.",
    );
    _clearLaborStrikeActivities(organizers);
  }
}

Future<void> doActivitySupportStrikeRelief(
  List<Creature> supporters,
) async {
  if (supporters.isEmpty) return;

  Site? workplace = supporters.first.activity.location;
  if (workplace == null ||
      !workplace.supportsLaborOrganizing ||
      workplace.controller != SiteController.unaligned ||
      !workplace.laborStrikeActive) {
    _clearLaborStrikeActivities(supporters);
    return;
  }

  int requested = (supporters.length * 100).clamp(100, 500);
  int contribution = ledger.funds.clamp(0, requested);
  if (contribution > 0) {
    ledger.subtractFunds(contribution, Expense.activism);
    workplace.addLaborStrikeFund(contribution);
  }

  int solidarityGain =
      (1 + supporters.length + contribution ~/ 200).clamp(1, 8);
  int hardshipRelief =
      (supporters.length + contribution ~/ 100).clamp(1, 10);
  workplace.addLaborStrikeSolidarity(solidarityGain);
  workplace.addLaborStrikeHardship(-hardshipRelief);

  for (Creature supporter in supporters) {
    supporter.train(Skill.persuasion, 5);
    supporter.train(Skill.business, 5);
  }

  if (contribution == 0) {
    await showMessage(
      "The SCS has no cash available for strike relief at ${workplace.name}. "
      "Volunteers still organize food, rides, and mutual aid, raising worker "
      "solidarity by $solidarityGain points.",
    );
    return;
  }

  String supporterWord = supporters.length == 1 ? "Socialist" : "Socialists";
  await showMessage(
    "${supporters.length} $supporterWord provide \$$contribution in strike "
    "relief at ${workplace.name}. The union's reserve is now "
    "\$${workplace.laborStrikeFund}, hardship falls by $hardshipRelief, and "
    "solidarity rises by $solidarityGain.",
  );
}

Future<bool> _applyStrikeSustainability(Site workplace) async {
  if (!workplace.laborStrikeActive) return false;

  int dailyNeed =
      (50 +
              workplace.laborStrikeDays * 10 +
              workplace.laborReplacementWorkerCoverage +
              workplace.laborStrikePolicePressure ~/ 2 +
              workplace.laborStrikeArrests * 10)
          .clamp(50, 350);
  int reliefSpent = workplace.spendLaborStrikeFund(dailyNeed);
  int aidCoverage = reliefSpent * 100 ~/ dailyNeed;
  int beforeHardship = workplace.laborStrikeHardship;

  int hardshipGain =
      (4 +
              workplace.laborStrikeDays ~/ 4 +
              workplace.laborReplacementWorkerCoverage ~/ 25 +
              workplace.laborStrikePolicePressure ~/ 30 +
              (workplace.laborStrikeInjunction ? 1 : 0) -
              aidCoverage ~/ 20 -
              workplace.laborStrikeSolidarity ~/ 40)
          .clamp(-2, 12);
  workplace.addLaborStrikeHardship(hardshipGain);

  if (aidCoverage >= 75) {
    workplace.addLaborStrikeSolidarity(1);
  } else if (aidCoverage < 25 && workplace.laborStrikeHardship >= 50) {
    workplace.addLaborStrikeSolidarity(-2);
  } else if (workplace.laborStrikeHardship >= 75) {
    workplace.addLaborStrikeSolidarity(-1);
  }

  int afterHardship = workplace.laborStrikeHardship;
  if (beforeHardship < 25 && afterHardship >= 25) {
    await showMessage(
      "The strike at ${workplace.name} is beginning to strain household "
      "budgets. Strike relief can keep hardship from undermining the line.",
    );
  } else if (beforeHardship < 50 && afterHardship >= 50) {
    await showMessage(
      "Workers at ${workplace.name} are under serious financial strain. "
      "Without a stronger relief fund, solidarity will become harder to "
      "maintain.",
    );
  } else if (beforeHardship < 75 && afterHardship >= 75) {
    await showMessage(
      "Hardship at ${workplace.name} is reaching crisis levels. Families are "
      "running out of room to absorb another week without pay.",
    );
  }

  if (workplace.laborStrikeHardship >= 100 ||
      workplace.laborStrikeSolidarity <= 0) {
    int strikeDays = workplace.laborStrikeDays;
    bool hardshipCollapse = workplace.laborStrikeHardship >= 100;
    workplace.defeatLaborStrike();
    String dayWord = strikeDays == 1 ? "day" : "days";
    String reason = hardshipCollapse
        ? "worker hardship becomes unsustainable"
        : "solidarity finally breaks under the pressure";
    await showMessage(
      "After $strikeDays $dayWord at ${workplace.name}, $reason. The strike "
      "ends without settling the demand, though the union survives and can "
      "return to bargaining.",
    );
    return false;
  }

  return true;
}

Future<void> _resolveReplacementWorkers(
  Creature lead,
  Creature businessLead,
  Creature streetLead,
  Site workplace,
  int teamBonus,
  int repressionLawModifier,
) async {
  if (!workplace.laborStrikeActive ||
      workplace.laborStrikeDays < 2 ||
      workplace.laborReplacementWorkerCoverage >= 100) {
    return;
  }

  int contractProtection =
      workplace.hasLaborDemand(Site.laborDemandUnionProtections) ? 12 : 0;
  int chance =
      (12 +
              workplace.laborUnionBustStrength * 4 +
              workplace.laborEmployerResistance ~/ 4 +
              repressionLawModifier.clamp(0, 4) * 4 +
              workplace.laborReplacementWorkerCoverage ~/ 6 -
              workplace.laborPicketStrength ~/ 3 -
              businessLead.skill(Skill.business) -
              workplace.laborUnionLocalStrengthForEffects ~/ 10 -
              contractProtection)
          .clamp(0, 65);
  if (lcsRandom(100) >= chance) return;

  int unionRoll = lead.skillRoll(Skill.persuasion) +
      streetLead.skill(Skill.streetSmarts) ~/ 2 +
      teamBonus +
      workplace.laborPicketStrength ~/ 15 +
      workplace.laborUnionLocalStrengthForEffects ~/ 20;
  int employerDifficulty =
      10 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 20 +
      repressionLawModifier.clamp(0, 4) +
      workplace.laborReplacementWorkerCoverage ~/ 20;
  lead.train(Skill.persuasion, 6);
  streetLead.train(Skill.streetSmarts, 6);

  if (unionRoll >= employerDifficulty) {
    int reduction = (2 + (unionRoll - employerDifficulty) ~/ 2).clamp(2, 8);
    int beforeCoverage = workplace.laborReplacementWorkerCoverage;
    workplace.addLaborReplacementWorkerCoverage(-reduction);
    if (beforeCoverage > 0) {
      await showMessage(
        "Union outreach at ${workplace.name} turns replacement workers away "
        "from the struck jobs. Scab coverage falls to "
        "${workplace.laborReplacementWorkerCoverage}%.",
      );
    } else {
      await showMessage(
        "Management at ${workplace.name} tries to recruit replacement "
        "workers, but the picket line and union outreach keep the jobs empty.",
      );
    }
    return;
  }

  int gain = (8 + (employerDifficulty - unionRoll) * 2).clamp(8, 22);
  int beforeCoverage = workplace.laborReplacementWorkerCoverage;
  workplace.addLaborReplacementWorkerCoverage(gain);
  int added = workplace.laborReplacementWorkerCoverage - beforeCoverage;
  await showMessage(
    "Management at ${workplace.name} brings in replacement workers. Scab "
    "coverage rises by $added points to "
    "${workplace.laborReplacementWorkerCoverage}%, reducing the strike's "
    "economic leverage.",
  );
}

Future<void> _resolveStrikeInjunction(
  Creature lead,
  Creature businessLead,
  Site workplace,
  int repressionLawModifier,
) async {
  if (!workplace.laborStrikeActive ||
      workplace.laborStrikeDays < 3 ||
      workplace.laborStrikeInjunction) {
    return;
  }

  int baseChance = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => 25,
    DeepAlignment.conservative => 15,
    DeepAlignment.moderate => 7,
    DeepAlignment.liberal => 2,
    DeepAlignment.eliteLiberal => 0,
  };
  if (baseChance == 0) return;

  int contractProtection =
      workplace.hasLaborDemand(Site.laborDemandUnionProtections) ? 10 : 0;
  int chance =
      (baseChance +
              workplace.laborUnionBustStrength * 2 +
              workplace.laborEmployerResistance ~/ 10 -
              businessLead.skill(Skill.business) * 2 -
              workplace.laborUnionLocalStrengthForEffects ~/ 10 -
              contractProtection)
          .clamp(0, 55);
  if (lcsRandom(100) >= chance) return;

  int defenseRoll = businessLead.skillRoll(Skill.business) +
      lead.skill(Skill.persuasion) ~/ 3 +
      workplace.laborUnionLocalStrengthForEffects ~/ 25;
  int difficulty =
      11 +
      workplace.laborUnionBustStrength +
      workplace.laborEmployerResistance ~/ 25 +
      repressionLawModifier.clamp(0, 4);
  businessLead.train(Skill.business, 8);

  if (defenseRoll >= difficulty) {
    await showMessage(
      "${businessLead.name} spots management's legal strategy at "
      "${workplace.name} early. The union's attorneys beat back a requested "
      "strike injunction.",
    );
    return;
  }

  workplace.laborStrikeInjunction = true;
  workplace.addLaborStrikePolicePressure(
    20 + repressionLawModifier.clamp(0, 4) * 3,
  );
  workplace.addLaborPicketStrength(-5);
  await showMessage(
    "Management at ${workplace.name} obtains a strike injunction. The court "
    "restricts picketing, weakens the line, and increases the risk of police "
    "intervention.",
  );
}

void _buildStrikePolicePressure(
  Site workplace,
  int repressionLawModifier,
  int policeRepressionModifier,
) {
  if (!workplace.laborStrikeActive) return;

  int pressureGain = 0;
  if (workplace.laborStrikeInjunction) pressureGain += 6;
  pressureGain += workplace.laborReplacementWorkerCoverage ~/ 25;
  pressureGain +=
      (repressionLawModifier + policeRepressionModifier).clamp(0, 8);
  if (workplace.hasLaborDemand(Site.laborDemandUnionProtections)) {
    pressureGain -= 2;
  }
  workplace.addLaborStrikePolicePressure(pressureGain.clamp(0, 12));
}

Future<void> _resolveStrikePoliceIntervention(
  List<Creature> organizers,
  Creature streetLead,
  Site workplace,
  int teamBonus,
  int repressionLawModifier,
  int policeRepressionModifier,
) async {
  if (!workplace.laborStrikeActive ||
      workplace.laborStrikePolicePressure < 20) {
    return;
  }

  int contractProtection =
      workplace.hasLaborDemand(Site.laborDemandUnionProtections) ? 10 : 0;
  int chance =
      (workplace.laborStrikePolicePressure ~/ 3 +
              (workplace.laborStrikeInjunction ? 15 : 0) +
              policeRepressionModifier.clamp(0, 4) * 4 +
              repressionLawModifier.clamp(0, 4) * 2 -
              streetLead.skill(Skill.streetSmarts) * 2 -
              workplace.laborPicketStrength ~/ 10 -
              contractProtection)
          .clamp(0, 50);
  if (lcsRandom(100) >= chance) return;

  int streetRoll = streetLead.skillRoll(Skill.streetSmarts) + teamBonus;
  int difficulty =
      10 +
      workplace.laborStrikePolicePressure ~/ 15 +
      (workplace.laborStrikeInjunction ? 3 : 0) +
      policeRepressionModifier.clamp(0, 4);
  streetLead.train(Skill.streetSmarts, 8);

  if (streetRoll >= difficulty) {
    workplace.addLaborStrikePolicePressure(-10);
    await showMessage(
      "Police arrive at the ${workplace.name} picket, but "
      "${streetLead.name} keeps the line disciplined and de-escalates the "
      "confrontation.",
    );
    return;
  }

  Creature target = organizers[lcsRandom(organizers.length)];
  workplace.recordLaborStrikeArrest();
  workplace.addLaborStrikePolicePressure(5);
  workplace.addLaborEmployerResistance(1);
  criminalize(target, Crime.disturbingThePeace);
  await showMessage(
    "Police move against the ${workplace.name} picket under pressure from "
    "management. ${target.name} is singled out for arrest.",
  );

  // Strike support is a daily activity, so the organizer normally still has
  // their safehouse as their stored location. Temporarily place them at the
  // workplace so the normal chase system uses the strike's actual district.
  // If they escape, restore their prior location; if captured, the chase
  // system moves them elsewhere and that result is preserved.
  String? originalLocationId = target.locationId;
  target.location = workplace;
  await attemptArrest(
    target,
    "supporting the strike at ${workplace.name}",
  );
  if (target.location == workplace) {
    target.locationId = originalLocationId;
  }
}

void _clearLaborStrikeActivities(List<Creature> organizers) {
  for (Creature organizer in organizers) {
    organizer.activity = Activity.none();
  }
}

String _laborSettlementMessage(Site workplace, String demand) {
  String terms = switch (workplace.laborContractDemand) {
    Site.laborDemandHigherWages =>
      "Management agrees to meaningful wage increases and a binding pay "
          "schedule.",
    Site.laborDemandBetterConditions =>
      "Management accepts enforceable improvements to scheduling and working "
          "conditions.",
    Site.laborDemandJobSecurity =>
      "Management accepts just-cause discipline and stronger protections "
          "against arbitrary firings.",
    Site.laborDemandUnionProtections =>
      "Management accepts durable union recognition, steward access, and "
          "anti-retaliation protections.",
    _ => "The union secures a collective bargaining agreement.",
  };
  String contractProgress = workplace.hasAllLaborDemands
      ? "The union's comprehensive contract now secures all four major "
          "demands."
      : "The union has secured ${workplace.laborContractDemandCount} of 4 "
          "major demands and can bargain for the rest.";
  return "Workers at ${workplace.name} ratify $demand as part of their "
      "contract. $terms $contractProgress";
}

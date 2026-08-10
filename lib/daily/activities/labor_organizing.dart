import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_actions/common_actions.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/creature_type.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
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
      workplace.hasLaborContract) {
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
      "Bargaining at ${workplace.name} has reached an impasse. The workers "
      "need a pressure campaign before negotiations can continue.",
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
  int persuasionRoll = negotiator.skillRoll(Skill.persuasion);
  int businessSupport = negotiator.skill(Skill.business) ~/ 2;
  int unionRoll = persuasionRoll + businessSupport + lawModifier;
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
  return "Workers at ${workplace.name} ratify a contract centered on "
      "$demand. $terms";
}

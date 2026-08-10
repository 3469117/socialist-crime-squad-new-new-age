import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_actions/common_actions.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/creature/creature.dart';
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

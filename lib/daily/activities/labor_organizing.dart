import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_actions/common_actions.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/politics/laws.dart';

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

  int lawModifier = switch (laws[Law.labor]!) {
    DeepAlignment.archConservative => -4,
    DeepAlignment.conservative => -2,
    DeepAlignment.moderate => 0,
    DeepAlignment.liberal => 2,
    DeepAlignment.eliteLiberal => 4,
  };

  int persuasionRoll = organizer.skillRoll(Skill.persuasion);
  int businessSupport = organizer.skill(Skill.business) ~/ 2;
  int progress = (persuasionRoll + businessSupport + lawModifier - 4)
    .clamp(1, 12);

  int before = workplace.laborOrganizingProgress;
  workplace.addLaborOrganizingProgress(progress);

  organizer.train(Skill.persuasion, 10 + progress);
  organizer.train(Skill.business, 5 + progress ~/ 2);

  if (before < 25 && workplace.laborOrganizingProgress >= 25) {
    await showMessage(
      "${organizer.name} has built an organizing committee at "
      "${workplace.name}.",
    );
  } else if (before < 50 && workplace.laborOrganizingProgress >= 50) {
    await showMessage(
      "The organizing drive at ${workplace.name} has reached majority support.",
    );
  } else if (before < 75 && workplace.laborOrganizingProgress >= 75) {
    await showMessage(
      "Workers at ${workplace.name} are preparing to formalize their union.",
    );
  }

  if (workplace.isUnionized) {
    addjuice(organizer, 10, 100);
    await showMessage("Workers at ${workplace.name} have unionized!");
    organizer.activity = Activity.none();
  }
}

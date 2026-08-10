import 'dart:math';

import 'package:collection/collection.dart';
import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/items/loot.dart';
import 'package:lcs_new_age/items/loot_type.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/newspaper/guardian_state.dart';
import 'package:lcs_new_age/newspaper/guardian_story.dart';
import 'package:lcs_new_age/newspaper/news_story.dart';
import 'package:lcs_new_age/politics/views.dart';

const int guardianStoryQueueLimit = 12;

void discoverGuardianStoryLeads() {
  if (gameState.guardianStories.length >= guardianStoryQueueLimit) return;

  Set<String> existingKeys =
      gameState.guardianStories.map((story) => story.sourceKey).toSet();

  _discoverDocumentLeads(existingKeys);
  _discoverLaborLeads(existingKeys);
  _discoverRecentNewsLeads(existingKeys);
}

void _addGuardianLead(
  Set<String> existingKeys, {
  required String sourceKey,
  required String title,
  required String sourceDetail,
  required GuardianLeadSource source,
  required GuardianBeat beat,
  View? primaryIssue,
  String? evidenceTypeId,
}) {
  if (gameState.guardianStories.length >= guardianStoryQueueLimit) return;
  if (!existingKeys.add(sourceKey)) return;

  gameState.guardianStories.add(
    GuardianStory(
      id: gameState.nextGuardianStoryId++,
      sourceKey: sourceKey,
      title: title,
      sourceDetail: sourceDetail,
      source: source,
      beat: beat,
      primaryIssue: primaryIssue,
      evidenceTypeId: evidenceTypeId,
    ),
  );
}

void _discoverDocumentLeads(Set<String> existingKeys) {
  int added = 0;
  for (Site site in gameState.sites.where(
    (site) => site.controller == SiteController.lcs,
  )) {
    for (Loot loot in site.loot.whereType<Loot>()) {
      _EvidenceLead? profile = _evidenceLeadFor(loot.type.idName);
      if (profile == null) continue;
      int before = gameState.guardianStories.length;
      _addGuardianLead(
        existingKeys,
        sourceKey: "evidence:${loot.type.idName}",
        title: profile.title,
        sourceDetail: profile.detail,
        source: GuardianLeadSource.documents,
        beat: profile.beat,
        primaryIssue: profile.issue,
        evidenceTypeId: loot.type.idName,
      );
      if (gameState.guardianStories.length > before) added++;
      if (added >= 3 ||
          gameState.guardianStories.length >= guardianStoryQueueLimit) {
        return;
      }
    }
  }
}

void _discoverLaborLeads(Set<String> existingKeys) {
  int added = 0;
  for (Site site in gameState.sites) {
    if (site.hasActiveLaborGrievance) {
      int grievanceSequence =
          site.laborGrievancesWon + site.laborGrievancesLost;
      int before = gameState.guardianStories.length;
      _addGuardianLead(
        existingKeys,
        sourceKey:
            "labor:grievance:${site.id}:${site.laborGrievanceDemand}:"
            "$grievanceSequence",
        title: "${site.name}: ${site.laborGrievanceShortName} grievance",
        sourceDetail:
            "Workers at ${site.name} report a contract grievance over "
            "${site.laborGrievanceName}.",
        source: GuardianLeadSource.labor,
        beat: GuardianBeat.laborEconomy,
        primaryIssue: _laborDemandIssue(site.laborGrievanceDemand),
      );
      if (gameState.guardianStories.length > before) added++;
    }

    if (site.laborRetaliationIncidents > 0) {
      int before = gameState.guardianStories.length;
      String firingDetail = site.laborWorkersFired > 0
          ? " ${site.laborWorkersFired} worker firings have been recorded."
          : "";
      _addGuardianLead(
        existingKeys,
        sourceKey:
            "labor:retaliation:${site.id}:${site.laborRetaliationIncidents}",
        title: "${site.name}: Union retaliation allegations",
        sourceDetail:
            "Workers at ${site.name} report management retaliation during "
            "organizing.$firingDetail",
        source: GuardianLeadSource.labor,
        beat: GuardianBeat.laborEconomy,
        primaryIssue: View.corporateCulture,
      );
      if (gameState.guardianStories.length > before) added++;
    }

    if (site.laborStrikeActive) {
      int before = gameState.guardianStories.length;
      _addGuardianLead(
        existingKeys,
        sourceKey:
            "labor:strike:${site.id}:${site.laborContractDemandMask}:"
            "${site.laborBargainingDemand}",
        title: "Strike at ${site.name}",
        sourceDetail:
            "Workers at ${site.name} are striking over "
            "${site.laborDemandNameFor(site.laborBargainingDemand)}.",
        source: GuardianLeadSource.labor,
        beat: GuardianBeat.laborEconomy,
        primaryIssue: View.sweatshops,
      );
      if (gameState.guardianStories.length > before) added++;
    }

    if (added >= 3 ||
        gameState.guardianStories.length >= guardianStoryQueueLimit) {
      return;
    }
  }
}

void _discoverRecentNewsLeads(Set<String> existingKeys) {
  int added = 0;
  DateTime now = gameState.date;

  for (NewsStory story in gameState.newsArchive.reversed.take(30)) {
    int age = now.difference(story.date).inDays;
    if (age < 0 || age > 7) continue;
    if (story.publicationName == Publication.liberalGuardian.name) continue;

    GuardianLeadSource? source = _sourceForNewsStory(story.type);
    if (source == null) continue;

    View? issue = _primaryIssueForNewsStory(story);
    GuardianBeat beat = issue == null
        ? _defaultBeatForSource(source)
        : GuardianBeat.forIssue(issue);

    String title = story.headline.trim();
    if (title.isEmpty) title = _fallbackNewsLeadTitle(story.type);

    int before = gameState.guardianStories.length;
    _addGuardianLead(
      existingKeys,
      sourceKey:
          "news:${story.date.toIso8601String()}:${story.type.name}:"
          "${story.locId}:${story.publicationName}:${story.priority}",
      title: title,
      sourceDetail:
          "A recent ${story.displayPublicationName} report raises questions "
          "worth independent follow-up.",
      source: source,
      beat: beat,
      primaryIssue: issue,
    );
    if (gameState.guardianStories.length > before) added++;

    if (added >= 4 ||
        gameState.guardianStories.length >= guardianStoryQueueLimit) {
      return;
    }
  }
}

Future<void> doActivityInvestigateGuardianStory(List<Creature> people) async {
  if (people.isEmpty) return;

  int? storyId = people.first.activity.idInt;
  GuardianStory? story = gameState.guardianStories.firstWhereOrNull(
    (story) => story.id == storyId,
  );

  if (story == null || story.ready) {
    for (Creature person in people) {
      person.activity = Activity.none();
    }
    return;
  }

  GuardianStoryStage beforeStage = story.stage;
  Skill supportSkill = story.supportSkill;

  Creature leadReporter = people.reduce(
    (a, b) => a.skill(Skill.writing) >= b.skill(Skill.writing) ? a : b,
  );
  int writingRoll = leadReporter.skillRoll(Skill.writing);
  int support = people.map((p) => p.skill(supportSkill)).reduce(max);
  int streetSmarts =
      people.map((p) => p.skill(Skill.streetSmarts)).reduce(max);
  int institutionBonus = gameState.guardianCredibility ~/ 20 +
      gameState.guardianEditorialCapacity ~/ 25;
  int teamBonus = min(4, people.length - 1);

  int progress = (writingRoll +
          support ~/ 2 +
          streetSmarts ~/ 3 +
          institutionBonus +
          teamBonus +
          story.source.investigationModifier -
          8)
      .clamp(1, 15);

  story.addProgress(progress);

  for (Creature person in people) {
    person.train(Skill.writing, 4);
    person.train(supportSkill, 2);
    if (supportSkill != Skill.streetSmarts) {
      person.train(Skill.streetSmarts, 1);
    }
  }

  if (beforeStage.index < GuardianStoryStage.verified.index &&
      story.stage.index >= GuardianStoryStage.verified.index) {
    gameState.guardianCredibility =
        (gameState.guardianCredibility + 1).clamp(0, 100);
    await showMessage(
      "The Socialist Guardian independently verifies the core facts behind "
      "\"${story.title}\".",
    );
  }

  if (beforeStage != GuardianStoryStage.ready && story.ready) {
    gameState.guardianEditorialCapacity =
        (gameState.guardianEditorialCapacity + 1).clamp(0, 100);
    await showMessage(
      "\"${story.title}\" is fully reported and ready for publication.",
    );
    for (Creature person in people) {
      person.activity = Activity.none();
    }
  }
}

GuardianLeadSource? _sourceForNewsStory(NewsStories type) => switch (type) {
      NewsStories.squadSiteAction ||
      NewsStories.squadEscapedSiege ||
      NewsStories.squadFledAttack ||
      NewsStories.squadDefended ||
      NewsStories.squadBrokeSiege ||
      NewsStories.squadKilledInSiegeAttack ||
      NewsStories.squadKilledInSiegeEscape ||
      NewsStories.squadKilledInSiteAction ||
      NewsStories.carTheft ||
      NewsStories.kidnapReport => GuardianLeadSource.scsAction,
      NewsStories.ccsSiteAction ||
      NewsStories.ccsDefended ||
      NewsStories.ccsKilledInSiegeAttack ||
      NewsStories.ccsKilledInSiteAction ||
      NewsStories.ccsNoBackers ||
      NewsStories.ccsDefeated => GuardianLeadSource.fcsAction,
      NewsStories.arrestGoneWrong ||
      NewsStories.raidCorpsesFound ||
      NewsStories.raidGunsFound ||
      NewsStories.hostageRescued ||
      NewsStories.hostageEscapes => GuardianLeadSource.police,
      NewsStories.presidentImpeached ||
      NewsStories.presidentBelievedDead ||
      NewsStories.presidentFoundDead ||
      NewsStories.presidentFound ||
      NewsStories.presidentKidnapped ||
      NewsStories.presidentMissing ||
      NewsStories.presidentAssassinated => GuardianLeadSource.politics,
      NewsStories.majorEvent || NewsStories.massacre =>
        GuardianLeadSource.publicEvent,
    };

View? _primaryIssueForNewsStory(NewsStory story) {
  if (story.view != null && View.issues.contains(story.view)) return story.view;

  View? strongestIssue;
  double strongestEffect = -1;
  for (MapEntry<View, double> entry in story.effects.entries) {
    if (!View.issues.contains(entry.key)) continue;
    double magnitude = entry.value.abs();
    if (magnitude <= strongestEffect) continue;
    strongestEffect = magnitude;
    strongestIssue = entry.key;
  }
  return strongestIssue;
}

GuardianBeat _defaultBeatForSource(GuardianLeadSource source) => switch (source) {
      GuardianLeadSource.documents => GuardianBeat.general,
      GuardianLeadSource.labor => GuardianBeat.laborEconomy,
      GuardianLeadSource.police => GuardianBeat.justicePolicing,
      GuardianLeadSource.politics => GuardianBeat.rightsDemocracy,
      GuardianLeadSource.scsAction => GuardianBeat.general,
      GuardianLeadSource.fcsAction => GuardianBeat.rightsDemocracy,
      GuardianLeadSource.publicEvent => GuardianBeat.general,
    };

String _fallbackNewsLeadTitle(NewsStories type) => switch (type) {
      NewsStories.squadSiteAction => "Questions after an SCS operation",
      NewsStories.squadEscapedSiege => "Inside an SCS siege escape",
      NewsStories.squadFledAttack => "Attack on an SCS safehouse",
      NewsStories.squadDefended => "SCS safehouse defense",
      NewsStories.squadBrokeSiege => "How an SCS siege ended",
      NewsStories.squadKilledInSiegeAttack ||
      NewsStories.squadKilledInSiegeEscape ||
      NewsStories.squadKilledInSiteAction => "Deaths tied to an SCS operation",
      NewsStories.ccsSiteAction => "FCS activity under scrutiny",
      NewsStories.ccsDefended => "Inside an FCS confrontation",
      NewsStories.ccsKilledInSiegeAttack ||
      NewsStories.ccsKilledInSiteAction => "Deaths tied to FCS activity",
      NewsStories.carTheft => "Vehicle theft raises wider questions",
      NewsStories.massacre => "Aftermath of a mass-casualty event",
      NewsStories.kidnapReport => "Kidnapping case demands scrutiny",
      NewsStories.arrestGoneWrong => "Questions over a police arrest",
      NewsStories.raidCorpsesFound => "Bodies discovered after a raid",
      NewsStories.raidGunsFound => "Weapons discovered after a raid",
      NewsStories.hostageRescued => "Hostage rescue under review",
      NewsStories.hostageEscapes => "Hostage escape raises questions",
      NewsStories.ccsNoBackers => "FCS network loses political backing",
      NewsStories.ccsDefeated => "What the FCS defeat means",
      NewsStories.presidentImpeached => "Presidential impeachment examined",
      NewsStories.presidentBelievedDead ||
      NewsStories.presidentFoundDead => "Presidential death under scrutiny",
      NewsStories.presidentFound => "President found after disappearance",
      NewsStories.presidentKidnapped => "Presidential kidnapping examined",
      NewsStories.presidentMissing => "Questions around a missing president",
      NewsStories.presidentAssassinated => "Presidential assassination examined",
      NewsStories.majorEvent => "A national story needs deeper reporting",
    };

View _laborDemandIssue(int demand) => switch (demand) {
      Site.laborDemandHigherWages => View.ceoSalary,
      Site.laborDemandBetterConditions => View.sweatshops,
      Site.laborDemandJobSecurity => View.corporateCulture,
      Site.laborDemandUnionProtections => View.freeSpeech,
      _ => View.corporateCulture,
    };

_EvidenceLead? _evidenceLeadFor(String id) => switch (id) {
      LootTypeIds.amRadioFiles => const _EvidenceLead(
          "How outrage media gets engineered",
          "Internal records document coordinated ideological messaging.",
          GuardianBeat.mediaCulture,
          View.amRadio,
        ),
      LootTypeIds.cableNewsFiles => const _EvidenceLead(
          "Inside a legacy newsroom's editorial pressure",
          "Internal records point to systematic pressure on news coverage.",
          GuardianBeat.mediaCulture,
          View.cableNews,
        ),
      LootTypeIds.ccsBackerList => const _EvidenceLead(
          "Tracing the FCS political network",
          "Documents identify institutional backers connected to the FCS.",
          GuardianBeat.rightsDemocracy,
          View.civilRights,
        ),
      LootTypeIds.ceoTaxPapers => const _EvidenceLead(
          "Executive tax practices under scrutiny",
          "Tax records raise questions about executive wealth and avoidance.",
          GuardianBeat.laborEconomy,
          View.taxes,
        ),
      LootTypeIds.corpFiles => const _EvidenceLead(
          "Internal corporate records raise corruption questions",
          "Corporate documents point to misconduct hidden from the public.",
          GuardianBeat.laborEconomy,
          View.corporateCulture,
        ),
      LootTypeIds.intHqDisk || LootTypeIds.secretDocuments =>
        const _EvidenceLead(
          "Inside the national security apparatus",
          "Secret records reveal activity hidden behind national-security claims.",
          GuardianBeat.securityForeign,
          View.intelligence,
        ),
      LootTypeIds.judgeFiles => const _EvidenceLead(
          "Judicial ethics questions surface",
          "Private records raise questions about judicial conduct.",
          GuardianBeat.rightsDemocracy,
          View.justices,
        ),
      LootTypeIds.policeRecords => const _EvidenceLead(
          "Internal police records reveal misconduct",
          "Police documents contain evidence that warrants independent review.",
          GuardianBeat.justicePolicing,
          View.policeBehavior,
        ),
      LootTypeIds.prisonFiles => const _EvidenceLead(
          "Inside prison conditions",
          "Internal prison records document practices hidden from public view.",
          GuardianBeat.justicePolicing,
          View.prisons,
        ),
      LootTypeIds.researchFiles => const _EvidenceLead(
          "Research practices hidden from public view",
          "Internal research records raise ethical and scientific questions.",
          GuardianBeat.scienceClimate,
          View.animalResearch,
        ),
      LootTypeIds.landlordPapers => const _EvidenceLead(
          "Landlord records reveal tenant abuses",
          "Property-management records document alleged misconduct toward tenants.",
          GuardianBeat.healthHousing,
          View.housing,
        ),
      LootTypeIds.insuranceFraudEvidence => const _EvidenceLead(
          "Insurance records raise coverage-fraud questions",
          "Internal insurance documents point to practices affecting patient care.",
          GuardianBeat.healthHousing,
          View.healthcare,
        ),
      LootTypeIds.elderAbuseEvidence => const _EvidenceLead(
          "Records expose elder-care failures",
          "Internal care-facility documents point to systemic mistreatment.",
          GuardianBeat.healthHousing,
          View.retirement,
        ),
      _ => null,
    };

class _EvidenceLead {
  const _EvidenceLead(this.title, this.detail, this.beat, this.issue);

  final String title;
  final String detail;
  final GuardianBeat beat;
  final View issue;
}

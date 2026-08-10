import 'dart:math';

import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/newspaper/guardian_state.dart';

void doActivityWriteGuardian(List<Creature> people) {
  if (people.isEmpty) return;

  int teamQuality = 0;
  double capacityFactor = _guardianCapacityFactor(people.length);
  double multiplier = _guardianPublishingMultiplier();

  for (Creature p in people) {
    GuardianBeat beat = GuardianBeat.fromId(p.activity.idString);
    int quality = p.skillRoll(Skill.writing) +
        p.skill(Skill.law) +
        p.skill(Skill.science) +
        p.skill(Skill.religion) +
        p.skill(Skill.business) -
        5;
    teamQuality += max(0, quality);
    int influence = (quality * capacityFactor * multiplier).round();
    politics.addBackgroundInfluence(beat.pickIssue(), influence);
    p.train(Skill.writing, 5);
  }

  _developGuardianFromPublishing(teamQuality, people.length);
}

void doActivityStreamGuardian(List<Creature> people) {
  if (people.isEmpty) return;

  int teamQuality = 0;
  double capacityFactor = _guardianCapacityFactor(people.length);
  double multiplier = _guardianStreamingMultiplier();

  for (Creature p in people) {
    GuardianBeat beat = GuardianBeat.fromId(p.activity.idString);
    int quality = p.skillRoll(Skill.persuasion) +
        p.skill(Skill.law) +
        p.skill(Skill.science) +
        p.skill(Skill.religion) +
        p.skill(Skill.business) -
        5;
    teamQuality += max(0, quality);
    int influence = (quality * capacityFactor * multiplier).round();
    politics.addBackgroundInfluence(beat.pickIssue(), influence);
    p.train(Skill.persuasion, 5);
  }

  _developGuardianFromStreaming(teamQuality, people.length);
}

double _guardianCapacityFactor(int activeStaff) {
  int fullStrengthStaff = 2 + gameState.guardianEditorialCapacity ~/ 20;
  if (activeStaff <= fullStrengthStaff) return 1;
  return (fullStrengthStaff / activeStaff).clamp(0.55, 1);
}

double _guardianPublishingMultiplier() =>
    0.95 +
    gameState.guardianCredibility * 0.006 +
    gameState.guardianEditorialCapacity * 0.003 +
    gameState.guardianReach * 0.0015;

double _guardianStreamingMultiplier() =>
    1.15 +
    gameState.guardianReach * 0.006 +
    gameState.guardianEditorialCapacity * 0.002 +
    gameState.guardianCredibility * 0.001;

void _developGuardianFromPublishing(int teamQuality, int staffCount) {
  if (teamQuality <= 0) return;

  int credibilityGain = (1 + teamQuality ~/ 50).clamp(1, 3);
  int capacityGain = teamQuality >= 20 ? (staffCount >= 3 ? 2 : 1) : 0;
  int reachGain = teamQuality >= 45 ? 1 : 0;

  gameState.guardianCredibility =
      (gameState.guardianCredibility + credibilityGain).clamp(0, 100);
  gameState.guardianEditorialCapacity =
      (gameState.guardianEditorialCapacity + capacityGain).clamp(0, 100);
  gameState.guardianReach =
      (gameState.guardianReach + reachGain).clamp(0, 100);
}

void _developGuardianFromStreaming(int teamQuality, int staffCount) {
  if (teamQuality <= 0) return;

  int reachGain = (1 + teamQuality ~/ 40).clamp(1, 4);
  int capacityGain = teamQuality >= 25 ? (staffCount >= 4 ? 2 : 1) : 0;
  int credibilityGain = teamQuality >= 65 ? 1 : 0;

  gameState.guardianReach =
      (gameState.guardianReach + reachGain).clamp(0, 100);
  gameState.guardianEditorialCapacity =
      (gameState.guardianEditorialCapacity + capacityGain).clamp(0, 100);
  gameState.guardianCredibility =
      (gameState.guardianCredibility + credibilityGain).clamp(0, 100);
}

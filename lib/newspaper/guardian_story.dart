import 'package:json_annotation/json_annotation.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/newspaper/guardian_state.dart';
import 'package:lcs_new_age/politics/views.dart';

part 'guardian_story.g.dart';

enum GuardianStoryStage {
  lead("Lead"),
  investigating("Investigating"),
  verified("Verified"),
  ready("Ready");

  const GuardianStoryStage(this.label);

  final String label;
}

enum GuardianLeadSource {
  documents("Documents", "Docs", 4),
  labor("Labor", "Labor", 2),
  police("Police", "Police", 0),
  politics("Politics", "Politics", 0),
  scsAction("SCS Action", "SCS", -2),
  fcsAction("FCS Action", "FCS", -1),
  publicEvent("Public Event", "Public", -1);

  const GuardianLeadSource(
    this.label,
    this.shortLabel,
    this.investigationModifier,
  );

  final String label;
  final String shortLabel;
  final int investigationModifier;
}

@JsonSerializable()
class GuardianStory {
  GuardianStory({
    required this.id,
    required this.sourceKey,
    required this.title,
    required this.sourceDetail,
    required this.source,
    required this.beat,
    this.primaryIssue,
    this.evidenceTypeId,
    this.investigationProgress = 0,
  });

  factory GuardianStory.fromJson(Map<String, dynamic> json) =>
      _$GuardianStoryFromJson(json);

  Map<String, dynamic> toJson() => _$GuardianStoryToJson(this);

  final int id;

  @JsonKey(defaultValue: "")
  String sourceKey;

  @JsonKey(defaultValue: "Untitled Guardian lead")
  String title;

  @JsonKey(defaultValue: "")
  String sourceDetail;

  @JsonKey(defaultValue: GuardianLeadSource.publicEvent)
  GuardianLeadSource source;

  @JsonKey(defaultValue: GuardianBeat.general)
  GuardianBeat beat;

  View? primaryIssue;

  String? evidenceTypeId;

  @JsonKey(defaultValue: 0)
  int investigationProgress;

  GuardianStoryStage get stage {
    if (investigationProgress >= 100) return GuardianStoryStage.ready;
    if (investigationProgress >= 70) return GuardianStoryStage.verified;
    if (investigationProgress > 0) return GuardianStoryStage.investigating;
    return GuardianStoryStage.lead;
  }

  bool get ready => stage == GuardianStoryStage.ready;

  String get progressLabel => "$investigationProgress%";

  String get shortTitle =>
      title.length <= 30 ? title : "${title.substring(0, 27).trim()}...";

  Skill get supportSkill => switch (beat) {
        GuardianBeat.general => Skill.streetSmarts,
        GuardianBeat.laborEconomy => Skill.business,
        GuardianBeat.rightsDemocracy => Skill.law,
        GuardianBeat.justicePolicing => Skill.law,
        GuardianBeat.scienceClimate => Skill.science,
        GuardianBeat.healthHousing => Skill.science,
        GuardianBeat.mediaCulture => Skill.business,
        GuardianBeat.securityForeign => Skill.law,
      };

  void addProgress(int amount) {
    investigationProgress =
        (investigationProgress + amount).clamp(0, 100);
  }
}

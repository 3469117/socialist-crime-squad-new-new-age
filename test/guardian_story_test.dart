import 'package:flutter_test/flutter_test.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/newspaper/guardian_state.dart';
import 'package:lcs_new_age/newspaper/guardian_story.dart';
import 'package:lcs_new_age/politics/views.dart';

void main() {
  GuardianStory makeStory({int progress = 0}) => GuardianStory(
        id: 1,
        sourceKey: 'test:story',
        title: 'Test investigation',
        sourceDetail: 'A test lead.',
        source: GuardianLeadSource.documents,
        beat: GuardianBeat.justicePolicing,
        primaryIssue: View.policeBehavior,
        investigationProgress: progress,
      );

  test('Guardian story progress follows the newsroom pipeline', () {
    GuardianStory story = makeStory();
    expect(story.stage, GuardianStoryStage.lead);

    story.addProgress(1);
    expect(story.stage, GuardianStoryStage.investigating);

    story.investigationProgress = 69;
    expect(story.stage, GuardianStoryStage.investigating);

    story.addProgress(1);
    expect(story.stage, GuardianStoryStage.verified);

    story.investigationProgress = 99;
    story.addProgress(1);
    expect(story.stage, GuardianStoryStage.ready);
    expect(story.ready, isTrue);
  });

  test('Guardian story progress is clamped to the valid range', () {
    GuardianStory story = makeStory(progress: 95);
    story.addProgress(20);
    expect(story.investigationProgress, 100);

    story.addProgress(-150);
    expect(story.investigationProgress, 0);
    expect(story.stage, GuardianStoryStage.lead);
  });

  test('Investigation support skill follows the editorial beat', () {
    expect(makeStory().supportSkill, Skill.law);

    GuardianStory laborStory = GuardianStory(
      id: 2,
      sourceKey: 'test:labor',
      title: 'Labor story',
      sourceDetail: 'Labor lead',
      source: GuardianLeadSource.labor,
      beat: GuardianBeat.laborEconomy,
    );
    expect(laborStory.supportSkill, Skill.business);
  });
}

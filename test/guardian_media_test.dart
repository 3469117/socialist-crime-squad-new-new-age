import 'package:flutter_test/flutter_test.dart';
import 'package:lcs_new_age/newspaper/guardian_state.dart';
import 'package:lcs_new_age/politics/views.dart';

void main() {
  test('Guardian beats always contain reportable issues', () {
    for (final beat in GuardianBeat.values) {
      expect(beat.issues, isNotEmpty, reason: '${beat.name} has no issues');
      expect(beat.issues.every(View.issues.contains), isTrue);
    }
  });

  test('Unknown and legacy Guardian beat ids fall back to general assignment', () {
    expect(GuardianBeat.fromId(null), GuardianBeat.general);
    expect(GuardianBeat.fromId('legacy-or-unknown'), GuardianBeat.general);
  });

  test('Guardian issues map back to a specialist beat', () {
    expect(GuardianBeat.forIssue(View.policeBehavior),
        GuardianBeat.justicePolicing);
    expect(GuardianBeat.forIssue(View.pollution), GuardianBeat.scienceClimate);
    expect(GuardianBeat.forIssue(View.taxes), GuardianBeat.laborEconomy);
  });
}

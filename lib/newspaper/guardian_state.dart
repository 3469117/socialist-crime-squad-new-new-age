import 'package:lcs_new_age/politics/views.dart';
import 'package:lcs_new_age/utils/lcsrandom.dart';

enum GuardianBeat {
  general(
    "General Assignment",
    "General",
    "Any major political issue",
  ),
  laborEconomy(
    "Labor & Economy",
    "Labor/Econ",
    "Labor, inequality, corporate power",
  ),
  rightsDemocracy(
    "Rights & Democracy",
    "Rights/Dem.",
    "Civil rights, equality, speech, courts",
  ),
  justicePolicing(
    "Justice & Policing",
    "Justice",
    "Police, prisons, punishment, surveillance",
  ),
  scienceClimate(
    "Science & Climate",
    "Science",
    "Climate, energy, research, technology",
  ),
  healthHousing(
    "Health & Social Policy",
    "Social Policy",
    "Healthcare, housing, retirement",
  ),
  mediaCulture(
    "Media & Culture",
    "Media",
    "Legacy media, algorithms, speech",
  ),
  securityForeign(
    "Security & Foreign Policy",
    "Security",
    "Military, intelligence, civil liberties",
  );

  const GuardianBeat(this.label, this.shortLabel, this.summary);

  final String label;
  final String shortLabel;
  final String summary;

  List<View> get issues => switch (this) {
        GuardianBeat.general => View.issues,
        GuardianBeat.laborEconomy => const [
            View.taxes,
            View.sweatshops,
            View.corporateCulture,
            View.ceoSalary,
            View.housing,
            View.retirement,
          ],
        GuardianBeat.rightsDemocracy => const [
            View.lgbtRights,
            View.womensRights,
            View.civilRights,
            View.immigration,
            View.freeSpeech,
            View.justices,
          ],
        GuardianBeat.justicePolicing => const [
            View.policeBehavior,
            View.prisons,
            View.deathPenalty,
            View.drugs,
            View.gunControl,
            View.torture,
            View.intelligence,
          ],
        GuardianBeat.scienceClimate => const [
            View.nuclearPower,
            View.animalResearch,
            View.genetics,
            View.pollution,
          ],
        GuardianBeat.healthHousing => const [
            View.healthcare,
            View.housing,
            View.retirement,
            View.drugs,
          ],
        GuardianBeat.mediaCulture => const [
            View.amRadio,
            View.cableNews,
            View.freeSpeech,
            View.civilRights,
          ],
        GuardianBeat.securityForeign => const [
            View.military,
            View.intelligence,
            View.torture,
            View.immigration,
            View.freeSpeech,
          ],
      };

  View pickIssue() => issues[lcsRandom(issues.length)];

  static GuardianBeat forIssue(View issue) {
    if (issue == View.healthcare ||
        issue == View.housing ||
        issue == View.retirement) {
      return GuardianBeat.healthHousing;
    }
    for (GuardianBeat beat in GuardianBeat.values) {
      if (beat == GuardianBeat.general) continue;
      if (beat.issues.contains(issue)) return beat;
    }
    return GuardianBeat.general;
  }

  static GuardianBeat fromId(String? id) => GuardianBeat.values.firstWhere(
        (beat) => beat.name == id,
        orElse: () => GuardianBeat.general,
      );
}

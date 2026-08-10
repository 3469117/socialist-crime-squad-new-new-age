import 'package:lcs_new_age/basemode/blind_time_log.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/politics/laws.dart';

Future<void> advanceLaborUnionLocals() async {
  int localCount = 0;
  int totalDues = 0;

  for (Site site in sites) {
    if (!site.supportsLaborOrganizing || !site.isUnionized) continue;

    site.establishLaborUnionLocal();
    int duesPercent = switch (laws[Law.labor]!) {
      DeepAlignment.archConservative => 70,
      DeepAlignment.conservative => 85,
      DeepAlignment.moderate => 100,
      DeepAlignment.liberal => 115,
      DeepAlignment.eliteLiberal => 130,
    };
    if (site.laborStrikeActive) duesPercent = duesPercent * 60 ~/ 100;

    int dues = site.laborUnionMonthlyDuesBase * duesPercent ~/ 100;
    dues = dues.clamp(25, 1000);
    int beforeFund = site.laborStrikeFund;
    site.addLaborStrikeFund(dues);
    int collected = site.laborStrikeFund - beforeFund;
    site.laborUnionDuesLastMonth = collected;
    if (collected > 0) {
      localCount++;
      totalDues += collected;
    }
  }

  if (localCount == 0 || totalDues == 0) return;
  String localWord = localCount == 1 ? "local" : "locals";
  await showMessageOrLog(
    "$localCount union $localWord collected \$$totalDues in member dues "
    "this month. The money remains in their workplace union reserves.",
  );
}

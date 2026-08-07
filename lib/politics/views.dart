import 'package:json_annotation/json_annotation.dart';

enum View {
  // political issues
  lgbtRights("LGBTQ+ Equality"),
  deathPenalty("Death Penalty"),
  taxes("Wealth & Taxation"),
  nuclearPower("Energy Policy"),
  animalResearch("Science & Research Ethics"),
  policeBehavior("Policing & Public Safety"),
  torture("Torture"),
  intelligence("Surveillance & Intelligence"),
  freeSpeech("Speech & Protest"),
  genetics("AI & Biotech"),
  justices("Courts & Judicial Power"),
  gunControl("Firearms Policy"),
  sweatshops("Labor Power"),
  pollution("Climate & Environment"),
  corporateCulture("Corporate Power"),
  ceoSalary("Wealth Inequality"),
  womensRights("Reproductive & Gender Rights"),
  civilRights("Civil Rights"),
  drugs("Drug Policy"),
  immigration("Immigration & Citizenship"),
  military("Military & Security"),
  prisons("Prisons & Justice"),
  housing("Housing"),
  healthcare("Healthcare"),
  retirement("Social Security & Retirement"),
  // media
  amRadio("Algorithmic Media"),
  cableNews("Legacy Media"),
  // crime squads
  lcsKnown("SCS Known"),
  lcsLiked("SCS Liked"),
  @JsonValue("ccsLiked")
  ccsHated("FCS Hated");

  const View(this.label);

  static final Iterable<View> all = View.values.where(
    (v) => ![View.torture].contains(v),
  );

  static final List<View> issues = [
    lgbtRights,
    deathPenalty,
    taxes,
    nuclearPower,
    animalResearch,
    policeBehavior,
    torture,
    intelligence,
    freeSpeech,
    genetics,
    justices,
    gunControl,
    sweatshops,
    pollution,
    corporateCulture,
    ceoSalary,
    womensRights,
    civilRights,
    drugs,
    immigration,
    military,
    prisons,
    housing,
    healthcare,
    retirement,
    amRadio,
    cableNews,
  ];

  final String label;
}

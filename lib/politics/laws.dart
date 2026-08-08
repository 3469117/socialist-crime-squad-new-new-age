import 'package:collection/collection.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/politics/alignment.dart';

enum Law {
  abortion("Reproductive Autonomy", [
    "Abortion and contraception are treated as crimes against the state.",
    "Abortion is broadly criminalized and providers face severe penalties.",
    "Access is sharply restricted and varies by state.",
    "A patchwork of state protections and restrictions remains in place.",
    "Federal protections secure broad reproductive choice.",
    "Universal public healthcare guarantees reproductive care nationwide.",
    "Reproductive care is free, universal, and insulated from political interference.",
  ]),
  animalRights("Animal Welfare", [
    "Industrial agriculture and research operate with almost no welfare limits.",
    "Animal welfare rules are weak and rarely enforced.",
    "Basic federal welfare standards exist with major exemptions.",
    "Conventional animal welfare regulation is enforced.",
    "Factory farming and research face strict welfare requirements.",
    "Non-human animals receive broad legal protections and habitat guarantees.",
    "Human industry has been reorganized around coexistence with other species.",
  ]),
  policeReform("Policing & Public Safety", [
    "Political policing, militarized raids, and mass surveillance define public safety.",
    "Police powers are expansive and accountability is minimal.",
    "Reform exists mostly as policy guidance with limited enforcement.",
    "Civilian oversight and conventional constitutional limits constrain police.",
    "Police are demilitarized and independent oversight has real enforcement power.",
    "Public safety funding is shifted heavily toward prevention, services, and community response.",
    "Most coercive policing has been replaced by non-carceral community safety institutions.",
  ]),
  privacy("Privacy & Surveillance", [
    "Government and corporate databases are integrated into a pervasive surveillance system.",
    "Mass data collection is routine and warrants provide little practical protection.",
    "Privacy rights exist but broad surveillance authorities remain.",
    "Warrants and sectoral privacy laws provide conventional safeguards.",
    "Strong national privacy law limits government and commercial data collection.",
    "Individuals control most personal data and mass surveillance is prohibited.",
    "Large institutions may retain personal data only when strictly necessary and explicitly consented to.",
  ]),
  deathPenalty("Capital Punishment", [
    "The death penalty is expanded to political and nonviolent offenses.",
    "Executions are common and available for a wide range of crimes.",
    "Capital punishment remains active in many jurisdictions.",
    "The death penalty is legal but uncommon and heavily reviewed.",
    "Most jurisdictions have abolished capital punishment.",
    "Capital punishment is abolished nationwide.",
    "Punishment is organized entirely around restitution, rehabilitation, and public safety.",
  ]),
  nuclearPower("Energy Policy", [
    "Energy policy is subordinated to politically connected fossil and extraction interests.",
    "Fossil expansion dominates and clean-energy regulation is rolled back.",
    "The energy system remains fossil-heavy with selective investment in alternatives.",
    "A mixed energy strategy gradually expands low-carbon generation.",
    "A rapid clean-energy buildout is backed by federal industrial policy.",
    "Public investment drives a near-zero-carbon grid with abundant firm clean power.",
    "Energy is treated as a universal public utility powered almost entirely by zero-carbon sources.",
  ]),
  pollution("Climate & Environment", [
    "Environmental enforcement has collapsed and climate damage is treated as an acceptable cost.",
    "Major polluters face few constraints and climate policy is dismantled.",
    "Environmental rules exist but are weak, fragmented, and easily delayed.",
    "Conventional federal environmental regulation limits major pollution.",
    "Aggressive emissions limits and climate adaptation programs are funded nationwide.",
    "A Green New Deal-scale mobilization rapidly decarbonizes industry and transportation.",
    "The economy operates within strict ecological limits and large-scale restoration is underway.",
  ]),
  labor("Labor Power", [
    "Independent unions are suppressed and employers may impose compulsory labor conditions.",
    "Union organizing is heavily restricted and strikes face severe penalties.",
    "Collective bargaining survives but employer power dominates most workplaces.",
    "Workers retain conventional organizing, bargaining, and wage protections.",
    "Card-check, sectoral bargaining, and strong strike protections shift power toward workers.",
    "Unions and worker councils share substantial control over major workplaces.",
    "Most firms are worker-owned and productive assets are governed democratically.",
  ]),
  lgbtRights("LGBTQ+ Equality", [
    "The state criminalizes queer and transgender public life.",
    "LGBTQ+ rights are broadly rolled back and state discrimination is explicit.",
    "Federal protections are narrow while state treatment varies sharply.",
    "Marriage equality and baseline nondiscrimination protections remain national policy.",
    "Comprehensive civil-rights protections cover gender identity and sexual orientation.",
    "Healthcare, family law, education, and public accommodations provide full substantive equality.",
    "Legal institutions no longer privilege fixed gender or family structures.",
  ]),
  corporate("Corporate & Worker Ownership", [
    "Political and corporate power are fused into an oligarchic patronage system.",
    "Dominant firms shape law with little antitrust or labor restraint.",
    "Large corporations remain politically powerful despite conventional regulation.",
    "Regulated capitalism remains the dominant economic model.",
    "Aggressive antitrust, public options, and codetermination constrain corporate power.",
    "Key infrastructure and natural monopolies are publicly or cooperatively owned.",
    "Worker-owned cooperatives and democratic public enterprises dominate the economy.",
  ]),
  freeSpeech("Speech & Protest", [
    "Opposition speech, protest, and organizing can be criminalized as threats to state order.",
    "Broad public-order laws chill protest and politically disfavored speech.",
    "Formal speech rights remain but protest restrictions and platform power narrow practical access.",
    "Conventional First Amendment protections and protest rules remain in force.",
    "Anti-SLAPP law, whistleblower protection, and protest rights receive strong federal protection.",
    "Workers, journalists, organizers, and dissidents receive exceptionally broad expressive protections.",
    "Political participation and access to mass communication are treated as universal civic rights.",
  ]),
  flagBurning("Symbolic Protest", [
    "Desecrating state symbols is treated as a major political crime.",
    "Flag desecration carries serious criminal penalties.",
    "Symbolic protest may be restricted under broad public-order laws.",
    "Flag burning is protected political expression subject to ordinary safety laws.",
    "Courts strongly protect provocative symbolic protest.",
    "Government may not privilege patriotic expression over dissent.",
    "National symbols are treated as cultural artifacts rather than objects of legal reverence.",
  ]),
  gunControl("Firearms Policy", [
    "Political militias and favored paramilitary groups enjoy privileged access to weapons.",
    "Civilian access to military-style weapons is broad and regulation is minimal.",
    "Federal regulation is limited while state policy varies widely.",
    "Background checks and conventional ownership rules define the national compromise.",
    "Licensing, safe-storage rules, and restrictions on high-risk weapons are national policy.",
    "Public carry and most private transfers require strict licensing and training.",
    "Civilian firearms are rare outside tightly regulated sporting and occupational use.",
  ]),
  taxes("Wealth & Taxation", [
    "Tax policy openly transfers wealth upward and shields political patrons.",
    "Capital income and large fortunes receive extensive preferential treatment.",
    "The tax code remains regressive in practice despite nominal progressivity.",
    "A conventional progressive tax system funds a mixed welfare state.",
    "High incomes, capital gains, inheritances, and large fortunes face steep progressive taxes.",
    "Extreme private fortunes are prevented through taxation and social ownership.",
    "Basic goods are universally provided and money plays only a limited role in access to necessities.",
  ]),
  genderEquality("Gender Equality", [
    "Law explicitly subordinates women and gender minorities to patriarchal authority.",
    "Workplace, family, and healthcare rules heavily reinforce traditional gender hierarchy.",
    "Formal equality exists with major gaps in pay, care work, and legal protection.",
    "Conventional nondiscrimination law provides baseline formal equality.",
    "Pay equity, family leave, childcare, and anti-discrimination enforcement substantially narrow gender inequality.",
    "Public institutions actively remove structural barriers tied to gender.",
    "Gender has almost no effect on legal status, economic opportunity, or access to care.",
  ]),
  civilRights("Civil Rights", [
    "The state openly enforces political and racial hierarchy.",
    "Civil-rights enforcement is dismantled and discriminatory state policy expands.",
    "Formal protections remain but enforcement is weak and unequal outcomes are entrenched.",
    "Baseline civil-rights law prohibits overt discrimination.",
    "Federal enforcement aggressively targets discrimination in housing, employment, voting, and education.",
    "Large-scale reparative and anti-segregation policies address structural inequality.",
    "Public institutions are designed around substantive equality rather than formally neutral access alone.",
  ]),
  drugs("Drug Policy", [
    "Drug enforcement is used as a sweeping instrument of political and social control.",
    "Possession and low-level distribution receive severe criminal penalties.",
    "The drug war remains active despite selective state-level legalization.",
    "Cannabis legalization and conventional criminal enforcement coexist.",
    "Most possession is decriminalized and harm-reduction programs are widely available.",
    "Drug markets are regulated with treatment prioritized over incarceration.",
    "Substance use is handled almost entirely as a public-health issue with universal treatment access.",
  ]),
  immigration("Immigration & Citizenship", [
    "Mass detention, removal, and denaturalization are central tools of state policy.",
    "Immigration enforcement is militarized and legal migration is sharply restricted.",
    "A restrictive border regime coexists with limited humanitarian and employment pathways.",
    "Conventional border enforcement, asylum, and legal immigration remain in place.",
    "Broad legalization, asylum access, and due-process protections substantially expand migration rights.",
    "Migration is broadly legal and citizenship is easy to obtain.",
    "Freedom of movement is treated as a basic right and citizenship carries few exclusionary privileges.",
  ]),
  elections("Democracy & Elections", [
    "Competitive elections have effectively ended and opposition activity is criminalized.",
    "Election administration is subordinated to the ruling coalition and outcomes can be manipulated.",
    "Partisan control, voter restrictions, and money distort formally competitive elections.",
    "Competitive elections operate under the existing two-party constitutional system.",
    "Automatic registration, public financing, independent administration, and ranked-choice voting expand participation.",
    "Proportional representation and strong voting rights create a durable multiparty democracy.",
    "National institutions are extensively democratized with proportional representation and participatory governance.",
  ]),
  military("Military & Security", [
    "The military and federal security apparatus are routinely used for domestic political coercion.",
    "Military spending and domestic security powers expand with weak civilian constraint.",
    "The United States maintains an enormous global military footprint and growing security budgets.",
    "Conventional U.S. defense policy and alliance commitments remain intact.",
    "Military spending is reduced while diplomacy, resilience, and civilian agencies receive more resources.",
    "The armed forces are substantially smaller and focused on territorial defense and disaster response.",
    "International security is organized around demilitarized collective institutions rather than national military dominance.",
  ]),
  prisons("Prisons & Justice", [
    "Political detention, forced labor, and abusive confinement are normalized.",
    "Mass incarceration expands and prisoner protections are weak.",
    "Harsh sentencing and overcrowding remain common despite selective reforms.",
    "Prisons operate under conventional constitutional and administrative safeguards.",
    "Sentences are shorter, prison conditions improve, and diversion programs expand.",
    "Rehabilitation, restorative justice, and community supervision replace much incarceration.",
    "Confinement is rare and reserved for immediate safety needs under restorative institutions.",
  ]),
  torture("State Interrogation", [
    "Torture and coercive interrogation are openly authorized against political enemies.",
    "Coercive interrogation is tolerated in national-security and policing contexts.",
    "Abusive practices persist behind secrecy and weak accountability.",
    "Law formally prohibits torture with conventional oversight and enforcement gaps.",
    "Independent inspectors and criminal penalties strongly enforce the torture ban.",
    "All detention and interrogation are subject to transparent human-rights monitoring.",
    "Coercive interrogation has been replaced by evidence-based, rights-preserving investigative practice.",
  ]),
  housing("Housing", [
    "Housing access is treated almost entirely as a privilege of wealth and political favor.",
    "Tenant protections are dismantled and homelessness is increasingly criminalized.",
    "Housing supply is market-led with weak tenant protections and limited subsidy.",
    "Market housing, zoning reform, vouchers, and local tenant rules coexist.",
    "Rent stabilization, social housing, and tenant unions become major parts of housing policy.",
    "Large-scale public and cooperative housing guarantees deeply affordable homes.",
    "Housing is effectively decommodified and permanent shelter is guaranteed as a social right.",
  ]),
  healthcare("Healthcare", [
    "Healthcare access is explicitly stratified by wealth, employment, and political status.",
    "Public coverage is cut back while private insurers dominate access to care.",
    "A fragmented insurance system leaves major gaps in cost and coverage.",
    "The mixed public-private healthcare system remains the national baseline.",
    "A strong public option and broad federal benefits sharply reduce uninsured and underinsured care.",
    "Universal single-payer healthcare covers all residents.",
    "Comprehensive healthcare, including dental, vision, mental health, and long-term care, is universally free at point of use.",
  ]),
  retirement("Social Security & Retirement", [
    "Public retirement programs are dismantled and old-age poverty is widespread.",
    "Social Security is partially privatized and benefits are sharply reduced.",
    "Benefits lag living costs and private savings determine retirement security.",
    "Social Security remains the baseline public retirement guarantee.",
    "Benefits expand and payroll financing is broadened to higher incomes.",
    "A generous universal pension guarantees a secure retirement independent of private savings.",
    "Universal social income makes retirement security independent of age, employment history, or accumulated wealth.",
  ]);

  const Law(this.label, this.description);
  final String label;
  final List<String> description;
  static Iterable<Law> get all => Law.values.whereNot(
    (l) => [Law.flagBurning, Law.torture, Law.elections].contains(l),
  );
}

String billName(Law l, bool liberal) {
  switch (l) {
    case Law.animalRights:
      if (liberal) {
        return "Protect Animal Welfare";
      } else {
        return "Deregulate Animal Research";
      }
    case Law.policeReform:
      if (liberal) {
        return "Stop Police Misconduct";
      } else {
        return "Expand Law Enforcement";
      }
    case Law.privacy:
      if (liberal) {
        return "Protect Individual Privacy";
      } else {
        return "Deregulate Infotech Industry";
      }
    case Law.deathPenalty:
      if (liberal) {
        return "Stop Barbaric Executions";
      } else {
        return "Expand Capital Punishment";
      }
    case Law.nuclearPower:
      if (liberal) {
        return "Promote Green Energy";
      } else {
        return "Promote Nuclear Power";
      }
    case Law.pollution:
      if (liberal) {
        return "Protect our Environment";
      } else {
        return "Deregulate Manufacturing";
      }
    case Law.labor:
      if (liberal) {
        return "Protect Workers' Rights";
      } else {
        return "Restrict Corrupt Union Organizing";
      }
    case Law.lgbtRights:
      if (liberal) {
        return "Protect LGBTQ+ Rights";
      } else {
        return "Save Children from Gender Ideology";
      }
    case Law.corporate:
      if (liberal) {
        return "Stop Corporate Criminals";
      } else {
        return "Lower Corporate Tax Rates";
      }
    case Law.freeSpeech:
      if (liberal) {
        return "Protect Free Speech";
      } else {
        return "Save Children from Harmful Speech";
      }
    case Law.taxes:
      if (liberal) {
        return "Raise Taxes on Higher Incomes";
      } else {
        return "Flatten the Tax Structure";
      }
    case Law.flagBurning:
      if (liberal) {
        return "Limit Prohibitions on Flag Burning";
      } else {
        return "Protect the Symbol of Our Nation";
      }
    case Law.gunControl:
      if (liberal) {
        return "Restrict Access to Guns";
      } else {
        return "Protect our Second Amendment Rights";
      }
    case Law.genderEquality:
      if (liberal) {
        return "Promote Gender Equality";
      } else {
        return "Stop Feminist Overreach";
      }
    case Law.abortion:
      if (liberal) {
        return "Strengthen Abortion Rights";
      } else {
        return "Protect the Unborn Child";
      }
    case Law.civilRights:
      if (liberal) {
        return "Promote Racial Equality";
      } else {
        return "Stop Reverse Discrimination";
      }
    case Law.drugs:
      if (liberal) {
        return "Repeal Oppressive Drug Laws";
      } else {
        return "Fight Drug Trafficking";
      }
    case Law.immigration:
      if (liberal) {
        return "Protect Immigrant Rights";
      } else {
        return "Protect our Borders";
      }
    case Law.elections:
      if (liberal) {
        return "Ban Dark Money in Elections";
      } else {
        return "Expand Unlimited Campaign Spending";
      }
    case Law.military:
      if (liberal) {
        return "Regulate Defense Industries";
      } else {
        return "Subsidize Defense Industries";
      }
    case Law.torture:
      if (liberal) {
        return "Ban Torture Techniques";
      } else {
        return "Permit New Interrogation Tactics";
      }
    case Law.prisons:
      if (liberal) {
        if (laws[Law.prisons] == DeepAlignment.liberal) {
          return "Focus Prisons on Rehabilitation";
        } else {
          return "Improve Prison Conditions";
        }
      } else {
        return "Enhance Prison Security";
      }
    case Law.housing:
      if (liberal) {
        return "Promote Affordable Housing";
      } else {
        return "Deregulate Housing Markets";
      }
    case Law.healthcare:
      if (liberal) {
        return "Improve Healthcare Access";
      } else {
        return "Defund Healthcare Programs";
      }
    case Law.retirement:
      if (liberal) {
        return "Guarantee Retirement Benefits";
      } else {
        return "Cut Social Security Benefits";
      }
  }
}

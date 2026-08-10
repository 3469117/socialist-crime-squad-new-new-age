import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/engine/engine.dart';
import 'package:lcs_new_age/utils/colors.dart';

void _body(String s) {
  setColor(lightGray);
  addparagraph(3, 1, s);
}

void _head(String s) => mvaddstrc(1, 1, lightGreen, s);

void _footer() =>
    addOptionText(console.y + 1, 1, "any key", "Press any key to continue.");

Future<void> helpOnActivity(ActivityType type) async {
  erase();
  switch (type) {
    case ActivityType.communityService:
      _head("=== Community Service ===");
      _body("Community service is a safe way to improve public opinion of the "
          "SCS, assuming anyone has heard of you and cares what you're doing. "
          "Planting trees and handing out food to the homeless is not going to "
          "get you into the news and make you a household name if you're not "
          "giving people another reason to care.\n\n"
          "The other power community service has is that it can forge civilians "
          "into activists, steadily increasing Juice up to a maximum of 10.");
    case ActivityType.trouble:
      _head("=== Socialist Disobedience ===");
      _body("Socialist Disobedience is an occasionally illegal "
          "form of Socialist Activism which has a modest Socialistizing effect on "
          "Public Opinion on a handful of issues. Although not without risk, "
          "it is not as dangerous as some other activities, and Socialists who "
          "are caught will usually face only small amounts of jail time.\n\n"
          "Socialist Disobedience can be used to gain up to 50 juice.\n\n"
          "Art and Street Smarts are the most important skills for this "
          "activity, and will improve the impact on public opinion. Street "
          "Smarts will also reduce the chance of being hassled by the cops "
          "or jumped by vigilantes.");
    case ActivityType.graffiti:
      _head("=== Graffiti ===");
      _body("Spraying political graffiti is a misdemeanor, carrying with it "
          "relatively short jail sentences. Socialists with low art will spread "
          "SCS tags around town, increasing public awareness of the Socialist "
          "Crime Squad. Socialists with greater Art skills will occasionally work on "
          "politically charged murals that can influence public opinion on "
          "various issues. The size of this impact is not large, however.\n\n"
          "Your artists will put their own names out there and gain in street "
          "credibility, gaining juice over time. Tagging caps out at 50 "
          "juice, while murals by very skilled artists can potentially raise "
          "Socialists to higher levels, if they're good enough.\n\n"
          "Art and Street Smarts are the most important skills for this "
          "activity. Art will make murals more frequent and more effective, "
          "while Street Smarts is essential for avoiding the cops.\n\n"
          "Socialists need to equip spraypaint to do graffiti. Those without "
          "will spend the first day buying some.");
    case ActivityType.hacking:
      _head("=== Hacking ===");
      _body("Hacking is a highly illegal form of Socialist Activism, which has "
          "a Socialistizing effect on public opinion and can be used to "
          "collect secret documents to publish in the Socialist Guardian.  "
          "Although there is no chance of the cops showing up mid-hack, "
          "the heat your hackers bring onto their safehouse can be very "
          "significant, and may lead to your bases being raided.\n\n"
          "Computers is necessary for both making a successful hacking attempt "
          "and avoiding the crime being traced back to your hackers.\n\n"
          "Due to its high risk, hacking can increase Juice up to a cap of 200.");
    case ActivityType.organizeWorkers:
      _head("=== Organize Workers ===");
      _body("Organize Workers sends a Socialist into a local private-sector "
          "workplace to build worker support for a union. Each successful day "
          "adds progress to that specific workplace. At 100%, the workplace "
          "becomes unionized and stays that way.\n\n"
          "Persuasion is the primary skill for organizing. Business knowledge "
          "also helps an organizer understand management, workplace structure, "
          "and the economic arguments workers will face. Both skills improve "
          "through organizing work.\n\n"
          "National labor law affects how quickly a drive can advance. "
          "Reactionary and Fascist labor law makes organizing harder, while "
          "Socialist labor law makes it easier.\n\n"
          "Management now reacts to an organizing drive. Employer resistance "
          "rises at different rates depending on the workplace and labor-law "
          "environment. Resistance slows daily organizing progress and can "
          "trigger anti-union campaigns that push worker support backward. "
          "Business skill helps anticipate and counter those tactics.\n\n"
          "At higher resistance, management may retaliate directly against "
          "union supporters through discipline, reduced hours, or firings. "
          "Retaliation can intimidate workers and reduce support, but a skilled "
          "organizer can turn an unjust firing into a solidarity surge. Sleeper "
          "agents who work at the targeted site can be personally fired and "
          "forced to report back to the SCS.\n\n"
          "At 100%, the organizing drive ends and the union is recognized. "
          "Use Negotiate Union Contract to choose demands and bargain for a "
          "first agreement.");
    case ActivityType.negotiateUnionContract:
      _head("=== Negotiate Union Contract ===");
      _body("A unionized workplace can bargain for all four major contract "
          "demands: Higher Wages, Better Conditions, Job Security, and Union "
          "Protections. Demands are cumulative rather than mutually exclusive. "
          "After settling one demand, return to Negotiate Union Contract and "
          "choose any demand the union has not yet secured.\n\n"
          "Persuasion drives the negotiating roll, while Business contributes "
          "support by helping the negotiator read management's position. "
          "Labor law, the employer's union-busting strength, and remaining "
          "employer resistance all affect the difficulty of reaching a deal.\n\n"
          "Successful rounds build bargaining progress toward 100%. Failed "
          "rounds stall the talks. Three stalled rounds in a row create a "
          "formal impasse, ending ordinary negotiations until the workers can "
          "apply additional pressure.\n\n"
          "Each settlement permanently adds that demand to the workplace's "
          "collective bargaining agreement and reduces employer resistance. "
          "Once all four demands are secured, the contract is complete. At an "
          "impasse, use Support Strike & Picket to escalate the dispute.");
    case ActivityType.supportLaborStrike:
      _head("=== Support Strike & Picket ===");
      _body("A strike becomes available only after a unionized workplace "
          "reaches a formal bargaining impasse. Supporting the strike starts "
          "the walkout if necessary and helps workers maintain a picket line "
          "while building economic pressure on management.\n\n"
          "Persuasion is the primary skill for keeping workers and supporters "
          "united. Street Smarts helps run an effective public picket, while "
          "Business helps the SCS understand management's strategy. Multiple "
          "Socialists can support the same strike for a modest team bonus.\n\n"
          "Labor law, employer resistance, the workplace's union-busting "
          "strength, and current picket strength all affect each day's "
          "contest. Successful days strengthen the line and build strike "
          "pressure. Failed days weaken the picket and can give some pressure "
          "back to management.\n\n"
          "At 100% strike pressure, management accepts the union's current "
          "demand and adds it to the contract. The union can then bargain for "
          "any remaining demands. If picket strength falls to zero first, the "
          "strike is defeated: workers return without settling that demand, "
          "bargaining progress falls, and management "
          "resistance increases. Negotiations can then resume and may produce "
          "another impasse later.\n\n"
          "Management can now escalate an active strike by recruiting "
          "replacement workers. Replacement-worker coverage reduces the "
          "strike's economic leverage and makes bad strike days more costly. "
          "Strong pickets, Persuasion, Street Smarts, and additional SCS "
          "supporters can keep replacements from crossing the line.\n\n"
          "After a strike has lasted several days, management may also seek a "
          "court injunction. Business helps organizers anticipate the legal "
          "attack. An injunction weakens the picket and raises police pressure. "
          "Labor law strongly affects whether this tactic succeeds. A union "
          "that has already secured Union Protections is harder to attack with "
          "replacement workers, injunctions, and police escalation.\n\n"
          "Police pressure builds when courts restrict the strike, replacement "
          "workers create confrontation, or labor and police law favor "
          "repression. Street Smarts can de-escalate police intervention. On a "
          "failed check, an SCS strike supporter can be singled out for arrest "
          "and must face the normal police chase/arrest system.\n\n"
          "Long strikes now create worker hardship. Each strike day consumes "
          "money from the workplace's strike-relief reserve; uncovered needs, "
          "replacement workers, injunctions, police pressure, and time all "
          "increase hardship. High hardship weakens the picket and can break "
          "solidarity. At maximum hardship or zero solidarity, the strike "
          "collapses even if the picket still has strength. Use Provide Strike "
          "Relief to contribute SCS funds and mutual-aid support.");
    case ActivityType.supportStrikeRelief:
      _head("=== Provide Strike Relief ===");
      _body("Provide Strike Relief assigns Socialists to sustain workers "
          "during an active strike. Each assigned Socialist can commit up to "
          "\$100 per day from the SCS treasury, with a maximum daily "
          "contribution of \$500 to the same workplace. Contributions become "
          "a persistent workplace strike fund and are recorded as activism "
          "expenses.\n\n"
          "The strike fund is automatically drawn down as each strike day "
          "creates household needs. Longer strikes, replacement-worker "
          "coverage, police pressure, and arrests make daily support more "
          "expensive. A well-funded reserve can slow or even reverse hardship. "
          "Unspent money remains in the union's reserve for a later strike.\n\n"
          "Relief work also organizes food, rides, childcare, and mutual aid. "
          "It therefore reduces hardship immediately and raises worker "
          "solidarity even when the SCS treasury is empty. Persuasion and "
          "Business improve through the work.");
    case ActivityType.buildUnionLocal:
      _head("=== Build Union Local ===");
      _body("A recognized union persists between bargaining rounds and "
          "strikes. Build Union Local develops that permanent workplace "
          "organization: stewards, membership meetings, communications, "
          "dues collection, and the internal habits needed to act "
          "collectively.\n\n"
          "Every new local begins with a basic level of organization. "
          "Persuasion and Business help Socialists strengthen it, while "
          "hostile labor law and employer resistance make development "
          "harder. Multiple Socialists can work on the same local for a "
          "small team bonus.\n\n"
          "Local strength is persistent. Stronger locals collect more "
          "member dues each month, bargain more effectively, begin "
          "strikes with stronger pickets and solidarity, and are harder "
          "to undermine with replacement workers or injunctions. A "
          "settled contract strengthens the local; a defeated strike can "
          "weaken it without destroying the union.\n\n"
          "Monthly dues go directly into that workplace union local's "
          "reserve, not the SCS treasury. The reserve is the same fund "
          "used automatically to support workers during a strike.");
    case ActivityType.writeGuardian:
      _head("=== Publish for the Socialist Guardian ===");
      _body("The Socialist Guardian is the SCS's independent media platform. "
          "It publishes reporting, leaks, commentary, and live video through a "
          "modern digital feed.\n\n"
          "Publishing for the Socialist Guardian puts stories onto the platform.  "
          "That's fine. It's is a safe but slow way to influence public "
          "opinion on a wide variety of issues. It costs nothing to throw "
          "posts and analysis into the feed, but it will take a long time "
          "to make any real difference.\n\n"
          "For a 4x more effective version of this activity, consider setting up "
          "a streaming room in an abandoned warehouse to produce live video "
          "streaming.\n\n"
          "The greatest power of the Socialist Guardian comes when you publish "
          "a special edition. This requires you to have collected "
          "some secret documents to leak. Once you've dug something up, "
          "you'll get the opportunity to run a special edition at the end of "
          "the month. You don't NEED to have "
          "anyone write or stream regularly to publish a special edition, but "
          "there isn't much point without them. Writers are better than "
          "streamers for maximizing the impact of a special edition.");
    case ActivityType.streamGuardian:
      _head("=== Livestream for the Socialist Guardian ===");
      _body("The Socialist Guardian is the SCS's independent media platform. "
          "It publishes reporting, leaks, commentary, and live video through a "
          "modern digital feed.\n\n"
          "Livestreaming for the Socialist Guardian uses the platform to produce "
          "live video where you engage directly with the audience while "
          "debating issues. It's four times as effective as writing articles, "
          "but you'll still need to defang the Fascist Media Machine "
          "before your message can really cut through the propaganda.\n\n"
          "The greatest power of the Socialist Guardian comes when you publish "
          "a special edition. This requires you to have collected "
          "some secret documents to leak. Once you've dug something up, "
          "you'll get the opportunity to run a special edition at the end of "
          "the month. You don't NEED to have "
          "anyone write or stream regularly to publish a special edition, but "
          "there isn't much point without them. Writers are better than "
          "streamers for maximizing the impact of a special edition.");
    case ActivityType.donations:
      _head("=== Solicit Donations ===");
      _body("Soliciting donations is a safe way to raise funds for the SCS.  "
          "It is much more lucrative when the public is very Fascist, "
          "because it's not about how many people agree with you, it's about "
          "how willing the Socialists you hit up are to donate to an extremist "
          "cause.\n\n"
          "This really doesn't do much if the public is Socialist. They're "
          "donating to politicians or whatever instead.\n\n"
          "Persuasion and Street Smarts are essential when soliciting "
          "donations. Also, try wearing a suit. For some reason, people give "
          "more money if you look trustworthy, and trustworthy means rich. "
          "Honestly disgusting, but that's the system.");
    case ActivityType.sellTshirts:
      _head("=== Sell Clothing ===");
      _body("Selling Clothing is a safe way to raise funds for the SCS. It is "
          "more lucrative when the public is very Fascist, because it's "
          "not about how many people have your back, it's about how radical "
          "and edgy your merch is. You're just not cool enough for your merch "
          "to take off in Socialist society. This is less important than it is "
          "if you're just soliciting donations though. If your fashion isn't "
          "counterculture anymore, you can always just sell Che Guevara "
          "prints to hipsters who think undermining capitalism is buying "
          "a t-shirt.\n\n"
          "Tailoring and Business will improve revenues.");
    case ActivityType.sellMusic:
      _head("=== Perform Music ===");
      _body("Performing Music is a safe way to raise funds for the SCS. It is "
          "more lucrative when the public is very Fascist, because it's "
          "not about how many people have your back, it's about how radical "
          "and edgy your music is. You're just not cool enough for your music "
          "to turn heads in Socialist society. This is less important than it "
          "is if you're just soliciting donations though. If protest songs "
          "don't hit like they used to, you can always just play covers of "
          "John Lennon's \"Imagine\".\n\n"
          "Music and Business will improve revenues. Make sure to equip a "
          "guitar. Drumming on buckets makes a lot less money.");
    case ActivityType.sellArt:
      _head("=== Sell Art ===");
      _body("Selling Art is a safe way to raise funds for the SCS. It is more "
          "lucrative when the public is very Fascist, because it's not "
          "about how many people have your back, it's about how radical and "
          "edgy your art is. You're just not cool enough for your art to draw "
          "big buyers in Socialist society. This is less important than it "
          "is if you're just soliciting donations though. If rebel art goes "
          "out of style, you can always just draw people's fursonas.\n\n"
          "Art and Business will improve revenues.");
    case ActivityType.sellDrugs:
      _head("=== Selling Weed Brownies ===");
      _body("Selling Brownies on the street is an illegal but rewarding "
          "way to make money. Money earned is based on the activist's "
          "Persuasion, Street Smarts, and Business. It is significantly more "
          "lucrative when drug laws are very Fascist, but so are the "
          "risks.\n\n"
          "Street Smarts is essential for avoiding the cops. If you're "
          "busted, the consequences can vary greatly depending on drug laws.");
    case ActivityType.prostitution:
      _head("=== Prostitution ===");
      _body("Prostitution is an illegal but rewarding way to make money. "
          "The amount of money is based primarily on Seduction, but also "
          "on Street Smarts and Business.\n\n"
          "Sometimes your clients will be cops. Some of those cops are "
          "out to get you. Street Smarts is essential to avoid this.\n\n"
          "You are very vulnerable while doing this activity. If you get "
          "caught in a police sting, you won't have a chance to fight your "
          "way or out or run, you're going straight to the lockup.");
    case ActivityType.ccfraud:
      _head("=== Credit Card Fraud ===");
      _body("Credit Card Fraud is an illegal but rewarding way to make money.  "
          "The more computer skill you bring to the table, the more money "
          "you will make. Computer skill helps protect you from getting "
          "caught, but the bigger paydays from high skill offset this by "
          "exposing you to increased law enforcement scrutiny.\n\n"
          "Your hackers will work together, and assigning many people to "
          "Credit Card Fraud will have diminishing returns.\n\n"
          "You do this from your hacker den, so the suits won't arrest you "
          "in the middle of the act, even if they figure out what you're "
          "doing. Charges will instead accumulate and bring heat down on the "
          "safehouse, eventually leading to a police raid.");
    case ActivityType.stealCars:
      _head("=== Stealing Cars ===");
      _body("Stealing a car will have the Socialist attempt to steal a car from "
          "the street. If successful, the car will be added to your garage.  "
          "Street Smarts determines the chances of finding a specific type of "
          "car, Security determines the chances of jimmying the lock or hotwiring "
          "the car. Strength is used to smash open the car window if you "
          "want to take that route.\n\n"
          "If you run into the The Viper, understand that it's just some silly "
          "aftermarket car alarm with a proximity sensor and a voice module. "
          "The car is not actually venomous, it does not have fangs, the snake "
          "isn't real and it can't hurt you. You can disable the annoying "
          "voice module once you get the engine started.\n\n"
          "It's the cops you have to worry about. Unfortunately, cops love car "
          "alarms and broken windows.");
    case ActivityType.bury:
      _head("=== Corpse Disposal ===");
      _body("Bodies piling up generates a lot of heat. Taking some time to "
          "get rid of them is important to keeping the cops off your back.\n\n"
          "Street Smarts helps to avoid any police attention.");
    case ActivityType.clinic:
      _head("=== Get To The Hospital ===");
      _body("Injuries can be healed slowly at home, but for anything serious "
          "you're going to need professional care. This activity hauls a "
          "Socialist off to get medical attention.");
    case ActivityType.makeClothing:
      _head("=== Make Clothing or Armor ===");
      _body("Tailoring skill is used to make clothing and armor. The first "
          "step is choosing a disguise, and then you select how much armor "
          "you want to integrate into the kit, which may affect the cost and "
          "difficulty of crafting the kit. Most disguises can only support "
          "wearing well-concealed soft armor underneath, but "
          "some clothes allow you to add hard armor over the top without "
          "looking out of place. Obvious displays of heavier armor are "
          "generally only allowed when crafting police and military "
          "disguises.\n\n"
          "Wearing darker colored clothing also helps with stealth. Don't "
          "think about that too much, it just works.");
    case ActivityType.wheelchair:
      _head("=== Get a Wheelchair ===");
      _body("Wheelchairs are used to help the disabled get around. If you "
          "have this option available, you need one.");
    case ActivityType.recruiting:
      _head("=== Recruit ===");
      _body("Recruiting is a safe way to meet people of a specific job.  Not "
          "all jobs are available in the recruiting interface, but many "
          "valuable, important, or just iconic jobs are.");
    case ActivityType.study:
      _head("=== Practice ===");
      _body(
          "Practicing is slower than taking classes, but it's free and has no "
          "cap on how much you can learn. People with higher skill caps "
          "will learn faster.");
    case ActivityType.takeClass:
      _head("=== Take Classes ===");
      _body("Taking a class is faster than practicing, but it costs money and "
          "has a cap on how much you can learn. People with higher skill "
          "caps will learn faster.");
    case ActivityType.teachFighting:
    case ActivityType.teachCovert:
    case ActivityType.teachLiberalArts:
      _head("=== Teaching ===");
      _body("Teaching is a way to pass on your skills to others. Every SCS "
          "member in the city who has something to learn will attend your "
          "class, and you will teach them all.\n\n"
          "Expenses scale with the number of students and skills being "
          "taught, up to a point, and then the rate of learning will slow.\n\n"
          "The Teaching skill will greatly speed up the learning process, "
          "and teachers more proficient in a skill will also teach it faster.  "
          "Teachers can only teach what they know, so if you want to reach "
          "higher levels, you'll need to improve the teacher's skills.");
    case ActivityType.none:
      _head("=== Laying Low ===");
      _body("Doing nothing is a safe way to avoid trouble. It is not a "
          "particularly effective way to change the world.\n\n"
          "Socialists who hang out at the safehouse will still pitch in and "
          "do some laundry and mending as needed.");
    case ActivityType.visit:
      _head("=== Site Visit ===");
      _body("Socialists acting with their squad to visit a location will not "
          "be able to do anything else that day.");
    case ActivityType.interrogation:
      _head("=== Interrogation ===");
      _body("You're trying to do what? Yeah, I don't know. Interrogating "
          "people you locked up in a back room sounds like *cop shit*. You're "
          "on your own for this one.");
    default:
      _head("=== Unknown Activity ===");
      _body("This activity is not yet documented.");
  }
  _footer();
  await getKey();
}

Future<void> helpOnSitemode() async {
  erase();
  _head("=== Direct Action ===");
  _body("You are taking direct action against the Fascist Menace.\n\n"
      "If you commit enough crimes, the media will usually report on your "
      "actions. This is generally a good thing. The more crimes you commit, "
      "and the more media attention you can attract, the greater the potential "
      "positive impact on public opinion.\n\n"
      "If you start causing trouble, people may call the cops or other "
      "reinforcements. Getting out quickly is safer than an occupation.\n\n"
      "Killing anyone during direct action will draw a lot of heat and cause "
      "the news coverage to skew hostile to the SCS. Frequent negative "
      "media coverage will eventually alienate everyone against you, limiting "
      "your ability to influence public opinion in the future. Mix up your "
      "tactics to maintain positive sentiment toward your squad.");
  _footer();
  await getKey();
}

import 'dart:math';

/// Enumeration of notification types supported by SkillTwin.
enum NotificationCategory {
  morningTaskReminder,
  endOfDayTrolling,
  backlogRoast,
  streakSaver,
  milestoneCelebration,
}

/// A structured notification message with title and body template.
class NotificationTemplate {
  final String title;
  final String body;

  const NotificationTemplate({
    required this.title,
    required this.body,
  });

  /// Supported dynamic placeholders:
  ///
  /// {topic}   -> Active/pending topic title
  /// {backlog} -> Number of backlogged topics
  /// {mins}    -> Daily study commitment in minutes
  /// {streak}  -> Consecutive active days
  String format(
    String text, {
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) {
    return text
        .replaceAll('{topic}', topic ?? "today's topic")
        .replaceAll('{backlog}', (backlog ?? 1).toString())
        .replaceAll('{mins}', (mins ?? 30).toString())
        .replaceAll('{streak}', (streak ?? 1).toString());
  }

  String formattedTitle({
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) =>
      format(
        title,
        topic: topic,
        backlog: backlog,
        mins: mins,
        streak: streak,
      );

  String formattedBody({
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) =>
      format(
        body,
        topic: topic,
        backlog: backlog,
        mins: mins,
        streak: streak,
      );
}

/// Central repository of all SkillTwin notification messages.
///
/// Tone:
/// - Funny
/// - Brutally honest
/// - Developer/student culture
/// - Slightly chaotic
/// - Motivating without sounding like a corporate HR email
///
/// The goal:
/// User sees notification -> laughs -> opens SkillTwin.
class NotificationMessages {
  NotificationMessages._();

  // ===========================================================================
  // 1. MORNING / DAYTIME REMINDERS
  // ===========================================================================

  static const List<NotificationTemplate> morningTaskReminders = [
    NotificationTemplate(
      title: "☀️ Good morning, unemployed CEO",
      body:
          "Your company has one employee and he's currently avoiding '{topic}'. Spend {mins} mins on it.",
    ),

    NotificationTemplate(
      title: "☕ Coffee won't learn '{topic}' for you",
      body:
          "Unfortunately, neither will your future self. Do {mins} mins now and pretend you're disciplined.",
    ),

    NotificationTemplate(
      title: "🧠 Your brain has entered the chat",
      body:
          "It would like to remind you that '{topic}' still exists. Your brain has requested {mins} minutes of education.",
    ),

    NotificationTemplate(
      title: "🚨 Productivity has been detected",
      body:
          "Don't panic. It's just a notification. You still have time to study '{topic}' before you inevitably open YouTube.",
    ),

    NotificationTemplate(
      title: "📚 Today's side quest has arrived",
      body:
          "'{topic}' is waiting. Reward: knowledge. XP: probably. Dopamine: questionable. Do {mins} mins.",
    ),

    NotificationTemplate(
      title: "🎯 One tiny problem",
      body:
          "You have goals. '{topic}' is between you and those goals. Sadly, ignoring it does not count as problem solving.",
    ),

    NotificationTemplate(
      title: "🗿 Be the person you pretend to be on LinkedIn",
      body:
          "Today you're apparently a 'passionate software engineer'. Very passionate. Very engineer. Now study '{topic}'.",
    ),

    NotificationTemplate(
      title: "💻 GitHub won't fill itself",
      body:
          "Another empty contribution graph is staring at you. Spend {mins} mins on '{topic}' before committing emotional damage.",
    ),

    NotificationTemplate(
      title: "🧑‍💻 Main character moment",
      body:
          "This is where you stop scrolling and study '{topic}'. Cinematic music is optional.",
    ),

    NotificationTemplate(
      title: "📈 Character development opportunity",
      body:
          "You could remain exactly as you are, or spend {mins} mins mastering '{topic}'. Choose your lore.",
    ),

    NotificationTemplate(
      title: "👀 We need to talk about '{topic}'",
      body:
          "It's been sitting there quietly. Judging you. Open SkillTwin and give it {mins} minutes.",
    ),

    NotificationTemplate(
      title: "🧘 Your future self requests a favour",
      body:
          "Please study '{topic}' today so I don't have to learn it the night before the interview. Thanks. — Future You",
    ),

    NotificationTemplate(
      title: "⚔️ Today's boss battle: '{topic}'",
      body:
          "HP: Unknown. Difficulty: Probably fine. Your excuse: Already expired. Spend {mins} mins and fight.",
    ),

    NotificationTemplate(
      title: "🥷 Sneaky productivity attack",
      body:
          "We're going to study '{topic}' for {mins} minutes before your brain realizes what's happening.",
    ),

    NotificationTemplate(
      title: "📢 PUBLIC ANNOUNCEMENT",
      body:
          "The government has declared '{topic}' mandatory for absolutely nobody. Unfortunately, your goals have.",
    ),

    NotificationTemplate(
      title: "🧠 Brain DLC available",
      body:
          "New knowledge pack: '{topic}'. Installation time: {mins} mins. No restart required.",
    ),

    NotificationTemplate(
      title: "💀 You said 'I'll do it later'",
      body:
          "Hello. It's later. '{topic}' is still waiting. This is your intervention.",
    ),

    NotificationTemplate(
      title: "📖 Open the app. Trust me.",
      body:
          "You don't need motivation. You need {mins} minutes and slightly less nonsense. Start '{topic}'.",
    ),

    NotificationTemplate(
      title: "🎮 IRL XP available",
      body:
          "Complete {mins} mins of '{topic}' and gain absolutely zero Fortnite skins. But you WILL get smarter.",
    ),

    NotificationTemplate(
      title: "🫵 Yes, you.",
      body:
          "The one reading this notification instead of studying '{topic}'. You have been identified. {mins} minutes. Go.",
    ),
  ];

  // ===========================================================================
  // 2. END-OF-DAY TROLLING
  // ===========================================================================

  static const List<NotificationTemplate> endOfDayTrolling = [
    NotificationTemplate(
      title: "💀 And the award for procrastination goes to...",
      body:
          "YOU! 🏆 '{topic}' received 0 minutes of attention today. Legendary performance.",
    ),

    NotificationTemplate(
      title: "📱 Screen Time: 6h 42m",
      body:
          "Study Time: absolutely classified. '{topic}' is filing a missing-person report.",
    ),

    NotificationTemplate(
      title: "🤡 'I'll start tomorrow' — Episode 847",
      body:
          "Critics are calling it 'the longest-running series in your life'. '{topic}' remains unfinished.",
    ),

    NotificationTemplate(
      title: "🚨 We checked. You didn't study.",
      body:
          "Don't worry, we're not angry. We're just disappointed. Very, very entertained. '{topic}' is still pending.",
    ),

    NotificationTemplate(
      title: "🪦 RIP today's productivity",
      body:
          "Cause of death: 'just one more reel'. Victim: your study plan. '{topic}' remains alive somehow.",
    ),

    NotificationTemplate(
      title: "👨‍⚖️ You have been summoned",
      body:
          "Court of Academic Accountability. Charge: avoiding '{topic}' all day. Sentence: {mins} minutes of studying.",
    ),

    NotificationTemplate(
      title: "📉 Your productivity graph called",
      body:
          "It said 'bro what happened?' '{topic}' is still untouched. We recommend immediate intervention.",
    ),

    NotificationTemplate(
      title: "💅 Oh, you're 'busy'?",
      body:
          "Interesting. You had time to check your phone 93 times but not {mins} minutes for '{topic}'. Fascinating.",
    ),

    NotificationTemplate(
      title: "🧑‍💻 Stack Overflow can't save you from this",
      body:
          "There is no Stack Overflow answer for 'How do I magically know '{topic}' without studying it?' Sorry.",
    ),

    NotificationTemplate(
      title: "🔥 Your roadmap is cooking",
      body:
          "Unfortunately, it's burning. '{topic}' is still pending. Please turn down the procrastination.",
    ),

    NotificationTemplate(
      title: "🫠 Bro...",
      body:
          "You really looked at '{topic}' this morning and said 'not today'. It's 9 PM. It remembers.",
    ),

    NotificationTemplate(
      title: "🎪 Welcome to the Circus",
      body:
          "Tonight's main act: You avoiding '{topic}' while telling everyone you're 'working on yourself'.",
    ),

    NotificationTemplate(
      title: "📞 Hello, this is your future",
      body:
          "I'm calling to ask why you left '{topic}' for tomorrow. Please stop making my life difficult.",
    ),

    NotificationTemplate(
      title: "🧠 Your Cognitive Twin is concerned",
      body:
          "It has learned more about your procrastination patterns than about '{topic}'. That's impressive, honestly.",
    ),

    NotificationTemplate(
      title: "🚪 '{topic}' has left the chat",
      body:
          "It waited all day. You never came. It has now gone to live with someone who actually studies.",
    ),

    NotificationTemplate(
      title: "💻 Production bug detected",
      body:
          "Cause: Developer did not learn '{topic}'. Fix: spend {mins} minutes learning it. Deploy immediately.",
    ),

    NotificationTemplate(
      title: "🧍 Your excuses are getting promoted",
      body:
          "They're now Senior Excuse Engineers. Meanwhile '{topic}' is still waiting for a junior developer.",
    ),

    NotificationTemplate(
      title: "🌚 It's giving 'I'll do it tomorrow'",
      body:
          "Tomorrow has already filed a complaint. It has enough of your unfinished work. '{topic}' is still pending.",
    ),

    NotificationTemplate(
      title: "🚮 Today's plan has entered the trash",
      body:
          "But don't worry! You can recover it with {mins} minutes on '{topic}'. Redemption arc starts now.",
    ),

    NotificationTemplate(
      title: "😐 So... about today.",
      body:
          "We had a plan. You had a plan. '{topic}' had a plan. Only one of you showed up.",
    ),
  ];

  // ===========================================================================
  // 3. BACKLOG ROASTS
  // ===========================================================================

  static const List<NotificationTemplate> backlogRoasts = [
    NotificationTemplate(
      title: "🚨 BACKLOG JUMPSCARE",
      body:
          "You currently have {backlog} topics waiting. They have formed a union.",
    ),

    NotificationTemplate(
      title: "🗿 Your backlog has become self-aware",
      body:
          "{backlog} topics are sitting there wondering why you created a roadmap in the first place.",
    ),

    NotificationTemplate(
      title: "📚 Congratulations! You invented homework.",
      body:
          "You now have {backlog} backlogged topics. Nobody assigned them. You did this to yourself.",
    ),

    NotificationTemplate(
      title: "🏗️ Technical debt detected",
      body:
          "Your codebase isn't the only thing accumulating debt. {backlog} topics are currently living rent-free in your brain.",
    ),

    NotificationTemplate(
      title: "📈 Your backlog is doing better than you",
      body:
          "It has consistently grown every day. {backlog} topics and counting. That's called scalability.",
    ),

    NotificationTemplate(
      title: "🧹 Backlog cleaning day",
      body:
          "Your study plan currently looks like your Downloads folder. {backlog} topics are waiting for cleanup.",
    ),

    NotificationTemplate(
      title: "🎰 Backlog Roulette",
      body:
          "{backlog} topics are overdue. Pick one. Any one. Please. We're begging.",
    ),

    NotificationTemplate(
      title: "🫡 Soldier, your backlog needs you",
      body:
          "{backlog} topics remain behind enemy lines. Deploy yourself immediately.",
    ),

    NotificationTemplate(
      title: "💀 The backlog is multiplying",
      body:
          "Yesterday it was smaller. Today it's {backlog}. At this rate, your roadmap needs its own database.",
    ),

    NotificationTemplate(
      title: "🧾 Invoice from your procrastination",
      body:
          "Amount due: {backlog} topics. Late fee: existential dread. Payment method: studying.",
    ),

    NotificationTemplate(
      title: "🏃 You can't outrun the backlog",
      body:
          "You can ignore {backlog} topics, but unfortunately they know where you live. Metaphorically.",
    ),

    NotificationTemplate(
      title: "🧠 Brain storage: 98% full",
      body:
          "{backlog} pending topics are taking up RAM. Clear some cache. Study something.",
    ),

    NotificationTemplate(
      title: "📦 Amazon delivery incoming",
      body:
          "Your order of {backlog} unfinished topics has arrived. Unfortunately, you ordered them yourself.",
    ),

    NotificationTemplate(
      title: "👹 The backlog boss has spawned",
      body:
          "Phase 1: {backlog} topics. Phase 2: regret. Phase 3: you suddenly study for 6 hours at 2 AM.",
    ),
  ];

  // ===========================================================================
  // 4. STREAK SAVERS
  // ===========================================================================

  static const List<NotificationTemplate> streakSavers = [
    NotificationTemplate(
      title: "🔥 BRO YOUR STREAK",
      body:
          "Your {streak}-day streak is standing outside the hospital room like 'PLEASE DON'T DO THIS TO ME'.",
    ),

    NotificationTemplate(
      title: "🚨 STREAK EMERGENCY 🚨",
      body:
          "Your {streak}-day streak has approximately 0.0001 HP left. Complete something. ANYTHING.",
    ),

    NotificationTemplate(
      title: "🫀 Your streak has a heartbeat",
      body:
          "Current condition: unstable. Treatment: one tiny study session. Side effects: becoming smarter.",
    ),

    NotificationTemplate(
      title: "🔥 Save the streak, legend",
      body:
          "You didn't maintain {streak} days just to let today's laziness delete the lore.",
    ),

    NotificationTemplate(
      title: "💀 Your streak is writing its will",
      body:
          "It has {streak} beautiful days to its name. Please don't make us attend its funeral tonight.",
    ),

    NotificationTemplate(
      title: "🧯 FIRE DEPARTMENT ALERT",
      body:
          "Your {streak}-day streak is on fire. Not in the good way. Open SkillTwin and extinguish the problem.",
    ),

    NotificationTemplate(
      title: "🫵 Don't fumble this",
      body:
          "{streak} days. That's how long you've been showing up. One session tonight keeps the story going.",
    ),

    NotificationTemplate(
      title: "⏰ The streak goblin is approaching",
      body:
          "It wants your {streak}-day streak. You have one job: study something before the day ends.",
    ),

    NotificationTemplate(
      title: "📉 Streak.exe is crashing",
      body:
          "Error 404: Today's study session not found. Your {streak}-day streak requires immediate debugging.",
    ),

    NotificationTemplate(
      title: "🧙 Ancient prophecy update",
      body:
          "The prophecy says: 'A person with a {streak}-day streak shall not lose it because they couldn't spare 10 minutes.'",
    ),
  ];

  // ===========================================================================
  // 5. MILESTONE CELEBRATIONS
  // ===========================================================================

  static const List<NotificationTemplate> milestoneCelebrations = [
    NotificationTemplate(
      title: "🏆 HOLY SH*T YOU DID IT",
      body:
          "'{topic}' has officially been defeated. Your brain has received +1 intelligence.",
    ),

    NotificationTemplate(
      title: "🧠 Brain.exe updated successfully",
      body:
          "'{topic}' has been installed. Please do not uninstall it by forgetting everything tomorrow.",
    ),

    NotificationTemplate(
      title: "🔥 LOOK WHO'S ACTUALLY CONSISTENT",
      body:
          "You completed '{topic}'. We were prepared to roast you. Unfortunately, you have defeated us.",
    ),

    NotificationTemplate(
      title: "🎉 Character development detected",
      body:
          "You actually finished '{topic}'. Somewhere, your future self just did a tiny victory dance.",
    ),

    NotificationTemplate(
      title: "📈 STOCK PRICE OF YOU: 📈",
      body:
          "You mastered '{topic}'. Investor confidence is up. Your mom would probably approve.",
    ),

    NotificationTemplate(
      title: "🫡 Respectfully... W",
      body:
          "'{topic}' is done. No excuses. No procrastination. Just pure execution. Rare footage.",
    ),

    NotificationTemplate(
      title: "💻 Commit successful",
      body:
          "feat(brain): mastered '{topic}'. Tests passed. Ego slightly increased.",
    ),

    NotificationTemplate(
      title: "🎮 Achievement Unlocked",
      body:
          "🏅 '{topic}' defeated. XP gained. Confidence +5. Procrastination -1.",
    ),

    NotificationTemplate(
      title: "🚨 UNEXPECTED EVENT",
      body:
          "You did exactly what you said you were going to do. Scientists are investigating.",
    ),

    NotificationTemplate(
      title: "🗿 Absolute cinema",
      body:
          "You showed up. You learned '{topic}'. You finished. This is what character development looks like.",
    ),

    NotificationTemplate(
      title: "👑 You dropped this",
      body:
          "👑 You completed '{topic}'. Pick up your crown and continue pretending this was always the plan.",
    ),

    NotificationTemplate(
      title: "📢 BREAKING NEWS",
      body:
          "Local student actually follows their roadmap. More at 9. '{topic}' has been mastered.",
    ),

    NotificationTemplate(
      title: "🤯 Wait... you actually studied?",
      body:
          "We genuinely weren't expecting that. '{topic}' is complete. We're proud. Don't get emotional.",
    ),

    NotificationTemplate(
      title: "🧪 Experiment successful",
      body:
          "Hypothesis: you can become good at '{topic}'. Result: apparently yes.",
    ),
  ];

  // ===========================================================================
  // UTILITY SELECTOR
  // ===========================================================================

  static final Random _rng = Random();

  /// Returns a randomized notification for the requested category.
  static ({String title, String body}) getRandomMessage(
    NotificationCategory category, {
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) {
    late final List<NotificationTemplate> pool;

    switch (category) {
      case NotificationCategory.morningTaskReminder:
        pool = morningTaskReminders;
        break;

      case NotificationCategory.endOfDayTrolling:
        pool = endOfDayTrolling;
        break;

      case NotificationCategory.backlogRoast:
        pool = backlogRoasts;
        break;

      case NotificationCategory.streakSaver:
        pool = streakSavers;
        break;

      case NotificationCategory.milestoneCelebration:
        pool = milestoneCelebrations;
        break;
    }

    final template = pool[_rng.nextInt(pool.length)];

    return (
      title: template.formattedTitle(
        topic: topic,
        backlog: backlog,
        mins: mins,
        streak: streak,
      ),
      body: template.formattedBody(
        topic: topic,
        backlog: backlog,
        mins: mins,
        streak: streak,
      ),
    );
  }
}
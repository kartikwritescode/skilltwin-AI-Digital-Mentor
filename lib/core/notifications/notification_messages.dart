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

  /// Formats the template by replacing dynamic placeholders:
  /// - {topic}: Active or pending topic title
  /// - {backlog}: Number of backlogged topics
  /// - {mins}: Daily study commitment in minutes
  /// - {streak}: Consecutive active days
  String format(String text, {
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) {
    return text
        .replaceAll('{topic}', topic ?? 'today\'s topic')
        .replaceAll('{backlog}', (backlog ?? 1).toString())
        .replaceAll('{mins}', (mins ?? 30).toString())
        .replaceAll('{streak}', (streak ?? 1).toString());
  }

  String formattedTitle({String? topic, int? backlog, int? mins, int? streak}) =>
      format(title, topic: topic, backlog: backlog, mins: mins, streak: streak);

  String formattedBody({String? topic, int? backlog, int? mins, int? streak}) =>
      format(body, topic: topic, backlog: backlog, mins: mins, streak: streak);
}

/// Central, easily editable repository of all SkillTwin notification messages.
/// Edit, add, or customize your trolling and reminder messages here!
class NotificationMessages {
  NotificationMessages._();

  // ---------------------------------------------------------------------------
  // 1. Morning & Daytime Pending Task Reminders
  // ---------------------------------------------------------------------------
  static const List<NotificationTemplate> morningTaskReminders = [
    NotificationTemplate(
      title: "☕ Coffee is hot, {topic} is waiting",
      body: "Knock out {mins} mins on '{topic}' now so you don't have to panic at 11:59 PM like you always do.",
    ),
    NotificationTemplate(
      title: "🚀 Top 1% engineers do this daily",
      body: "The other 99% are scrolling Instagram reels. Spend {mins} mins on '{topic}' and stay dangerous.",
    ),
    NotificationTemplate(
      title: "🎯 Today's Mission: {topic}",
      body: "Your cognitive twin is prepped. 20 focused minutes today keeps the imposter syndrome away.",
    ),
    NotificationTemplate(
      title: "🧠 Your brain called...",
      body: "It said feed me '{topic}' before you fry it with 4 hours of short-form videos today.",
    ),
    NotificationTemplate(
      title: "⏰ Daily Deliberate Practice Alert",
      body: "Milestone '{topic}' is ready. Get in, test your concepts, get out with verified mastery.",
    ),
    NotificationTemplate(
      title: "☀️ Good morning! Quick question:",
      body: "Are we mastering '{topic}' today, or are we making excuses again? Let's get to work.",
    ),
  ];

  // ---------------------------------------------------------------------------
  // 2. End-Of-Day Trolling & Slacking Roasts (Fired at 9:00 PM if task incomplete)
  // ---------------------------------------------------------------------------
  static const List<NotificationTemplate> endOfDayTrolling = [
    NotificationTemplate(
      title: "💀 Your future senior engineer salary just cried",
      body: "Screen time today: 5 hours. Time spent on '{topic}': 0 mins. Open the app and fix your life.",
    ),
    NotificationTemplate(
      title: "📉 Breaking News: You're slacking again",
      body: "Did you really think I wouldn't notice you dodging '{topic}' all day? 15 minutes. Right now.",
    ),
    NotificationTemplate(
      title: "👀 Even your Wi-Fi is disappointed in you",
      body: "You've been on your phone for hours, yet '{topic}' sits untouched. The bar was on the floor and you brought a shovel.",
    ),
    NotificationTemplate(
      title: "🚨 Day 4 of 'I will start tomorrow'",
      body: "Spoiler alert bestie: tomorrow never comes. '{topic}' is still pending. Don't go to bed a quitter.",
    ),
    NotificationTemplate(
      title: "🤡 Nice excuse, but '{topic}' isn't going to learn itself",
      body: "A bug in production is laughing at you right now because you skipped your practice today. Squash it.",
    ),
    NotificationTemplate(
      title: "🪦 RIP to your study goals (unless you open this)",
      body: "Your AI Twin is filing an emotional neglect report. Give it 10 minutes on '{topic}' before midnight.",
    ),
    NotificationTemplate(
      title: "💅 Oh, so you're too 'busy' today?",
      body: "We saw you check WhatsApp 47 times today. You have {mins} minutes for '{topic}'. Get in here.",
    ),
  ];

  // ---------------------------------------------------------------------------
  // 3. Backlog Shame & Catch-Up Roasts (When learner is behind schedule)
  // ---------------------------------------------------------------------------
  static const List<NotificationTemplate> backlogRoasts = [
    NotificationTemplate(
      title: "⚠️ Warning: Technical Debt in your Brain",
      body: "You have {backlog} backlogged topics piling up like laundry on that one chair. Time for a catch-up sprint!",
    ),
    NotificationTemplate(
      title: "📉 Your deadline didn't move, but you did...",
      body: "You are {backlog} topics behind schedule. The deadline is looming. Complete 1 topic today to stop the bleeding.",
    ),
    NotificationTemplate(
      title: "🎪 The Backlog Circus is in town",
      body: "{backlog} topics delayed! Don't let your roadmap turn into an abandoned New Year's resolution.",
    ),
    NotificationTemplate(
      title: "🔥 Emergency Backlog Notice",
      body: "Procrastination won today, but tomorrow is redemption. Clear your {backlog} backlogs before they multiply!",
    ),
  ];

  // ---------------------------------------------------------------------------
  // 4. Streak Saver Emergencies (Late evening)
  // ---------------------------------------------------------------------------
  static const List<NotificationTemplate> streakSavers = [
    NotificationTemplate(
      title: "🔥 Your {streak}-day streak is on life support!",
      body: "Answer 1 practice challenge right now to save your streak from painful extinction. Clock is ticking!",
    ),
    NotificationTemplate(
      title: "⏳ 2 hours left before streak reset",
      body: "Don't let your {streak}-day streak flatline in the dark. Open SkillTwin and prove your knowledge!",
    ),
  ];

  // ---------------------------------------------------------------------------
  // 5. Milestone Celebrations
  // ---------------------------------------------------------------------------
  static const List<NotificationTemplate> milestoneCelebrations = [
    NotificationTemplate(
      title: "🎉 Look at you being all disciplined!",
      body: "You mastered '{topic}' today! We love to see actual follow-through. Rest up, champ.",
    ),
    NotificationTemplate(
      title: "⚡ Concept Mastered!",
      body: "Boom! Another building block secured for your Cognitive Twin. That's how senior engineers are built.",
    ),
  ];

  // ---------------------------------------------------------------------------
  // Utility Selector
  // ---------------------------------------------------------------------------

  static final Random _rng = Random();

  /// Gets a randomized message for the given category with tokens populated.
  static ({String title, String body}) getRandomMessage(
    NotificationCategory category, {
    String? topic,
    int? backlog,
    int? mins,
    int? streak,
  }) {
    List<NotificationTemplate> pool;

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
      title: template.formattedTitle(topic: topic, backlog: backlog, mins: mins, streak: streak),
      body: template.formattedBody(topic: topic, backlog: backlog, mins: mins, streak: streak),
    );
  }
}

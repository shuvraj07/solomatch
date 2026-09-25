import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';

/// Static information pages. The Terms and Privacy text are starting
/// templates: have them reviewed before publishing the app.
enum InfoPage {
  guidelines(
    'Community guidelines',
    '''
SoloMatch is about playing football with people you've never met. Keep it safe and fun for everyone.

• Show up. If you can't make it, leave the match early so someone else can play.
• Play fair. No violent tackles, no fighting, respect the referee or organizer's calls.
• Be respectful in chat and in person. No harassment, hate, threats or discrimination.
• Be honest about your skill level and position.
• Organizers: describe the venue, time and price accurately, and don't cancel at the last minute without a good reason.
• Meet at public venues. Tell a friend where you're going.
• Payments are made directly at the venue. SoloMatch never asks for your bank or card details.

Report anyone who breaks these guidelines from their profile or the match page. Repeated or serious violations lead to removal.''',
  ),
  terms('Terms of use', '''
These terms are a starting template and must be reviewed before the app is published.

1. You must be at least 16 years old to use SoloMatch.
2. You are responsible for the information you post and for your conduct at matches.
3. Matches are organized by users, not by SoloMatch. SoloMatch is not responsible for injuries, venue issues, payments or disputes between users.
4. We may remove content or suspend accounts that break the Community guidelines.
5. You can delete your account at any time in Settings.'''),
  privacy(
    'Privacy policy',
    '''
This policy is a starting template and must be reviewed before the app is published.

What we store: your account email, the football profile you create (name, username, photo, city, positions, skill, availability), the matches you create or join, your messages, ratings and reports.

Who can see it: other signed-in players see your public football profile, matches and ratings. Your email and date of birth are never shown. You can hide your city in Settings → Privacy.

Notifications: we store your device's push token to send notifications. You can turn categories off in Settings.

Deleting your account removes your profile and personal data. Match history, messages and ratings you gave stay, shown as "Deleted player".''',
  ),
  help('Help', '''
How do I join a match? Open it from Home and tap Request to Join. The organizer accepts or declines.

How do I leave? Open the match and tap Leave match (before kick-off).

Why can't I request a match? It may be full, cancelled, already started, or the organizer may have blocked you.

Notifications not arriving? Check Settings → Notifications in the app and allow notifications for SoloMatch in your phone settings.

Something else? Report a problem from a player's profile or a match page.''');

  const InfoPage(this.title, this.body);

  final String title;
  final String body;
}

class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({super.key, required this.page});

  final InfoPage page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(page.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(page.body, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

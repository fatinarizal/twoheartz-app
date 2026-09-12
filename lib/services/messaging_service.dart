import 'package:url_launcher/url_launcher.dart';
import '../models/guest_model.dart';

class InvitationMessagingService {
  static Future<void> sendEmailInvitation(GuestModel guest) async {
    final String subject = "Wedding Invitation: You're Invited!";
    final String body = '''
Hi ${guest.guestName},

We would be honored by your presence as we celebrate our wedding day!

Event Details:
- Date: Saturday, 12th December
- Location: Grand Ballroom, Kuala Lumpur

Please confirm your attendance by visiting our digital card link:
https://2heartz.app/rsvp

Warm regards,
2HEARTZ
''';

    final Uri uri = Uri(
      scheme: 'mailto',
      path: guest.email,
      queryParameters: {'subject': subject, 'body': body},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> sendWhatsAppInvitation(GuestModel guest) async {
    final String msg = '''
✨ *WALIMATULURUS INVITATION* ✨

Dear ${guest.guestName},

We cordially invite you to celebrate our wedding day! 💕

📅 *Date:* Saturday, 12th December
📍 *Venue:* Grand Ballroom, Kuala Lumpur
🔗 *RSVP & Digital Card:* https://2heartz.app/rsvp

We look forward to celebrating with you!
''';

    final Uri uri = Uri.parse("https://wa.me/${guest.phoneNumber}?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
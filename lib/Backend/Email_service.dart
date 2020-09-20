import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Send emails to my dev address
///
/// [type] can either be 'Critical' or 'Feedback'
Future sendIt(String subject, String body, String type) async{
  String username = 'lolzgoat@gmail.com';//TODO: replace this ASAP
  String password = '1234developer.com';

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.  
  
  // Create our message.
  final message = Message()
    ..from = Address(username, type)
    ..recipients.add(username) // Send to itself
    ..subject = subject
    ..text = '[version number here]\n\n\n' + body;//TODO: fill in version number

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  } 
}

main() async{
  await sendIt('Critical', 'Update time, youtube has changed naming conventions!', 'update');
  await sendIt('Feedback', 'Love your app Kingsley', 'Suggestion');
}
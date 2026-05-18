import 'package:intl/intl.dart';

class FormatageDate {
  String formatted(int timeStamp) {
    DateTime postTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    DateTime now = DateTime.now();
    DateFormat format;
    if (now.difference(postTime).inDays > 0) {
      format = DateFormat.yMd();
    } else {
      format = DateFormat.Hm();
    }
    return format.format(postTime).toString();
  }
}

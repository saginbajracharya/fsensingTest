import 'package:timezone/timezone.dart' as tz;

final nepallocation = tz.getLocation('Asia/Kathmandu');
final japanlocation = tz.getLocation('Asia/Tokyo');

final nepalDate = tz.TZDateTime.now(nepallocation);

getCurrentTimeofJapan(){
  final japanTime = tz.TZDateTime.now(japanlocation).toString();
  return japanTime.toString();
}

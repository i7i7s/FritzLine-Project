import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'pay_channel';
  static const _channelName = 'Payment';
  static const _channelDesc = 'Payment notifications';

  Future<NotificationService> init() async {
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: initAndroid);
    await _plugin.initialize(init);
    if (Platform.isAndroid) {
      await Permission.notification.request();
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    return this;
  }

  Future<void> showPaymentSuccess() async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _plugin.show(id, 'Pembayaran Berhasil', 'Terima kasih, transaksi kamu sukses.', details, payload: 'payment_success');
  }
}

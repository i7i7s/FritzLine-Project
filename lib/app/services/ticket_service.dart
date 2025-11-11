import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TicketService extends GetxService {
  late Box _ticketBox;

  final allMyTickets = <Map<String, dynamic>>[].obs;

  Future<TicketService> init() async {
    _ticketBox = await Hive.openBox('my_tickets');
    _loadTicketsFromHive();
    return this;
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> originalMap) {
    return originalMap.map((key, value) {
      final newKey = key.toString();
      dynamic newValue = value;

      if (value is Map) {
        newValue = _convertMap(value);
      } else if (value is List) {
        newValue = value.map((item) {
          if (item is Map) {
            return _convertMap(item);
          }
          return item;
        }).toList();
      }

      return MapEntry(newKey, newValue);
    });
  }

  void _loadTicketsFromHive() {
    final ticketsFromHive = _ticketBox.values.toList();
    allMyTickets.value = ticketsFromHive.map((ticket) {
      if (ticket is Map) {
        return _convertMap(ticket);
      }
      return <String, dynamic>{};
    }).toList();
  }

  Future<void> saveNewTicket(Map<String, dynamic> newTicket) async {
    await _ticketBox.add(newTicket);
    allMyTickets.add(newTicket);
  }
}

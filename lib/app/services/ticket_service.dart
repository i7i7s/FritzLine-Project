import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_service.dart';

class TicketService extends GetxService {
  late Box _ticketBox;
  final authService = Get.find<AuthService>();

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

  String? _getCurrentUserId() {
    return authService.currentUser.value?.email;
  }

  void _loadTicketsFromHive() {
    final currentUserId = _getCurrentUserId();


    if (currentUserId == null) {
      allMyTickets.value = [];
      return;
    }

    final ticketsFromHive = _ticketBox.values.toList();

    final filteredTickets = ticketsFromHive
        .map((ticket) {
          if (ticket is Map) {
            return _convertMap(ticket);
          }
          return <String, dynamic>{};
        })
        .where((ticket) {
          if (!ticket.containsKey('userId') || ticket['userId'] == null) {
            return false;
          }

          final ticketUserId = ticket['userId'];
          final matches = ticketUserId == currentUserId;

          if (!matches) {
          } else {
          }

          return matches;
        })
        .toList();

    allMyTickets.value = filteredTickets;
  }

  Future<void> saveNewTicket(Map<String, dynamic> newTicket) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      return;
    }

    newTicket['userId'] = currentUserId;


    await _ticketBox.add(newTicket);
    allMyTickets.add(newTicket);

  }

  Future<void> deleteTicket(int index) async {
    if (index >= 0 && index < allMyTickets.length) {
      final ticketToDelete = allMyTickets[index];
      final bookingCode = ticketToDelete['bookingCode'];

      for (var i = 0; i < _ticketBox.length; i++) {
        final ticket = _ticketBox.getAt(i);
        if (ticket is Map && ticket['bookingCode'] == bookingCode) {
          await _ticketBox.deleteAt(i);
          break;
        }
      }

      allMyTickets.removeAt(index);
    }
  }

  Future<void> clearAllTickets() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    var keysToDelete = <int>[];
    for (var i = 0; i < _ticketBox.length; i++) {
      final ticket = _ticketBox.getAt(i);
      if (ticket is Map && ticket['userId'] == currentUserId) {
        keysToDelete.add(i);
      }
    }

    for (var i = keysToDelete.length - 1; i >= 0; i--) {
      await _ticketBox.deleteAt(keysToDelete[i]);
    }

    allMyTickets.clear();
  }

  void reloadTickets() {
    _loadTicketsFromHive();
  }

  Future<void> cleanupOldTicketsWithoutUserId() async {
    var keysToDelete = <int>[];
    for (var i = 0; i < _ticketBox.length; i++) {
      final ticket = _ticketBox.getAt(i);
      if (ticket is Map &&
          (!ticket.containsKey('userId') || ticket['userId'] == null)) {
        keysToDelete.add(i);
      }
    }

    for (var i = keysToDelete.length - 1; i >= 0; i--) {
      await _ticketBox.deleteAt(keysToDelete[i]);
    }

    _loadTicketsFromHive();

    if (keysToDelete.isNotEmpty) {
    }
  }
}

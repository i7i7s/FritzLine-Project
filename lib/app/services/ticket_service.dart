import 'package:get/get.dart';

class TicketService extends GetxService {
  final allMyTickets = <Map<String, dynamic>>[].obs;

  void saveNewTicket(Map<String, dynamic> newTicket) {
    allMyTickets.add(newTicket);
  }
}
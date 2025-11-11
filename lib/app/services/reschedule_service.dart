import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/reschedule_request.dart';
import '../models/user.dart';
import 'auth_service.dart';

class RescheduleService extends GetxService {
  late Box<RescheduleRequest> _rescheduleBox;
  final authService = Get.find<AuthService>();

  // Reschedule fee rules (percentage of original ticket price)
  static const Map<String, double> RESCHEDULE_FEES = {
    'H-7+': 0.10, // 10% fee if rescheduled 7+ days before
    'H-3_to_H-6': 0.20, // 20% fee if rescheduled 3-6 days before
    'H-1_to_H-2': 0.30, // 30% fee if rescheduled 1-2 days before
    'H-0': 0.50, // 50% fee on departure day
  };

  Future<RescheduleService> init() async {
    _rescheduleBox = await Hive.openBox<RescheduleRequest>('rescheduleRequests');
    return this;
  }

  // Calculate reschedule fee based on days before departure
  Map<String, dynamic> calculateRescheduleFee({
    required DateTime originalTravelDate,
    required double originalAmount,
    double newTicketPrice = 0,
    DateTime? requestDate,
  }) {
    requestDate ??= DateTime.now();
    
    // Calculate days before original departure
    int daysBeforeDeparture = originalTravelDate.difference(requestDate).inDays;
    
    double feePercentage;
    String ruleApplied;
    
    if (daysBeforeDeparture >= 7) {
      feePercentage = RESCHEDULE_FEES['H-7+']!;
      ruleApplied = 'H-7+ (7 hari atau lebih)';
    } else if (daysBeforeDeparture >= 3) {
      feePercentage = RESCHEDULE_FEES['H-3_to_H-6']!;
      ruleApplied = 'H-3 sampai H-6 (3-6 hari)';
    } else if (daysBeforeDeparture >= 1) {
      feePercentage = RESCHEDULE_FEES['H-1_to_H-2']!;
      ruleApplied = 'H-1 sampai H-2 (1-2 hari)';
    } else if (daysBeforeDeparture == 0) {
      feePercentage = RESCHEDULE_FEES['H-0']!;
      ruleApplied = 'H-0 (Hari keberangkatan)';
    } else {
      return {
        'canReschedule': false,
        'reason': 'Tidak dapat reschedule setelah keberangkatan',
      };
    }
    
    double rescheduleFee = originalAmount * feePercentage;
    double additionalCharge = newTicketPrice > originalAmount 
        ? newTicketPrice - originalAmount 
        : 0;
    double totalCharge = rescheduleFee + additionalCharge;
    double refundAmount = newTicketPrice < originalAmount 
        ? originalAmount - newTicketPrice - rescheduleFee
        : 0;
    
    return {
      'daysBeforeDeparture': daysBeforeDeparture,
      'feePercentage': feePercentage,
      'rescheduleFee': rescheduleFee,
      'additionalCharge': additionalCharge,
      'totalCharge': totalCharge,
      'refundAmount': refundAmount,
      'ruleApplied': ruleApplied,
      'canReschedule': true,
    };
  }

  // Create reschedule request
  Future<RescheduleRequest> createRescheduleRequest({
    required String originalTicketId,
    required String originalTrainId,
    required String originalTrainName,
    required DateTime originalTravelDate,
    required String originalDeparture,
    required String originalArrival,
    required String reason,
    required double originalAmount,
    String? newTrainId,
    String? newTrainName,
    DateTime? newTravelDate,
    String? newSeatNumber,
    double newTicketPrice = 0,
  }) async {
    try {
      // Calculate reschedule fee
      var calculation = calculateRescheduleFee(
        originalTravelDate: originalTravelDate,
        originalAmount: originalAmount,
        newTicketPrice: newTicketPrice,
      );

      if (!calculation['canReschedule']) {
        throw Exception(calculation['reason']);
      }

      // Generate request ID
      String requestId = 'RSC${DateTime.now().millisecondsSinceEpoch}';

      // Create reschedule request
      RescheduleRequest request = RescheduleRequest(
        requestId: requestId,
        originalTicketId: originalTicketId,
        originalTrainId: originalTrainId,
        originalTrainName: originalTrainName,
        originalTravelDate: originalTravelDate,
        originalDeparture: originalDeparture,
        originalArrival: originalArrival,
        newTrainId: newTrainId,
        newTrainName: newTrainName,
        newTravelDate: newTravelDate,
        newSeatNumber: newSeatNumber,
        requestDate: DateTime.now(),
        reason: reason,
        originalAmount: originalAmount,
        rescheduleFee: calculation['rescheduleFee'],
        additionalCharge: calculation['additionalCharge'],
        totalCharge: calculation['totalCharge'],
        daysBeforeDeparture: calculation['daysBeforeDeparture'],
        status: 'pending',
      );

      // Save to Hive
      await _rescheduleBox.add(request);

      return request;
    } catch (e) {
      throw Exception('Gagal membuat reschedule request: $e');
    }
  }

  // Get all reschedule requests for current user
  List<RescheduleRequest> getUserRescheduleRequests() {
    User? user = authService.currentUser.value;
    if (user == null) return [];

    return _rescheduleBox.values.toList()
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
  }

  // Get reschedule request by ID
  RescheduleRequest? getRescheduleRequestById(String requestId) {
    try {
      return _rescheduleBox.values.firstWhere(
        (request) => request.requestId == requestId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get reschedule request by ticket ID
  RescheduleRequest? getRescheduleRequestByTicketId(String ticketId) {
    try {
      return _rescheduleBox.values.firstWhere(
        (request) => request.originalTicketId == ticketId,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if ticket already has reschedule request
  bool hasRescheduleRequest(String ticketId) {
    return _rescheduleBox.values.any(
      (request) => request.originalTicketId == ticketId && 
                   (request.status == 'pending' || request.status == 'approved')
    );
  }

  // Update reschedule request
  Future<void> updateRescheduleRequest({
    required String requestId,
    String? newTrainId,
    String? newTrainName,
    DateTime? newTravelDate,
    String? newSeatNumber,
    double? additionalCharge,
    double? totalCharge,
  }) async {
    try {
      RescheduleRequest? request = getRescheduleRequestById(requestId);
      if (request != null) {
        if (newTrainId != null) request.newTrainId = newTrainId;
        if (newTrainName != null) request.newTrainName = newTrainName;
        if (newTravelDate != null) request.newTravelDate = newTravelDate;
        if (newSeatNumber != null) request.newSeatNumber = newSeatNumber;
        if (additionalCharge != null) request.additionalCharge = additionalCharge;
        if (totalCharge != null) request.totalCharge = totalCharge;
        await request.save();
      }
    } catch (e) {
      throw Exception('Gagal update reschedule request: $e');
    }
  }

  // Update reschedule status
  Future<void> updateRescheduleStatus({
    required String requestId,
    required String status,
    String? newTicketId,
    String? adminNotes,
  }) async {
    try {
      RescheduleRequest? request = getRescheduleRequestById(requestId);
      if (request != null) {
        request.status = status;
        request.processedDate = DateTime.now();
        request.adminNotes = adminNotes;
        if (newTicketId != null) request.newTicketId = newTicketId;
        await request.save();
      }
    } catch (e) {
      throw Exception('Gagal update status reschedule: $e');
    }
  }

  // Approve reschedule
  Future<void> approveReschedule({
    required String requestId,
    required String newTicketId,
    String? notes,
  }) async {
    await updateRescheduleStatus(
      requestId: requestId,
      status: 'approved',
      newTicketId: newTicketId,
      adminNotes: notes ?? 'Reschedule disetujui',
    );
  }

  // Reject reschedule
  Future<void> rejectReschedule(String requestId, String reason) async {
    await updateRescheduleStatus(
      requestId: requestId,
      status: 'rejected',
      adminNotes: reason,
    );
  }

  // Complete reschedule
  Future<void> completeReschedule(String requestId) async {
    await updateRescheduleStatus(
      requestId: requestId,
      status: 'completed',
      adminNotes: 'Reschedule selesai, tiket baru sudah diterbitkan',
    );
  }

  // Cancel reschedule request
  Future<bool> cancelRescheduleRequest(String requestId) async {
    try {
      RescheduleRequest? request = getRescheduleRequestById(requestId);
      if (request != null && request.status == 'pending') {
        await request.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Gagal cancel reschedule request: $e');
    }
  }

  // Get reschedule policy text
  String getReschedulePolicyText(int daysBeforeDeparture) {
    if (daysBeforeDeparture >= 7) {
      return 'Biaya reschedule 10% dari harga tiket';
    } else if (daysBeforeDeparture >= 3) {
      return 'Biaya reschedule 20% dari harga tiket';
    } else if (daysBeforeDeparture >= 1) {
      return 'Biaya reschedule 30% dari harga tiket';
    } else if (daysBeforeDeparture == 0) {
      return 'Biaya reschedule 50% dari harga tiket (hari keberangkatan)';
    } else {
      return 'Tidak dapat reschedule setelah keberangkatan';
    }
  }

  // Get reschedule statistics
  Map<String, dynamic> getRescheduleStats() {
    List<RescheduleRequest> requests = getUserRescheduleRequests();
    
    int totalRequests = requests.length;
    int pendingRequests = requests.where((r) => r.status == 'pending').length;
    int approvedRequests = requests.where((r) => r.status == 'approved').length;
    int rejectedRequests = requests.where((r) => r.status == 'rejected').length;
    int completedRequests = requests.where((r) => r.status == 'completed').length;
    
    double totalFeesPaid = requests
        .where((r) => r.status == 'completed')
        .fold(0, (sum, r) => sum + r.totalCharge);

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'approvedRequests': approvedRequests,
      'rejectedRequests': rejectedRequests,
      'completedRequests': completedRequests,
      'totalFeesPaid': totalFeesPaid,
    };
  }

  // Validate reschedule eligibility
  Map<String, dynamic> validateRescheduleEligibility({
    required DateTime originalTravelDate,
    required String ticketStatus,
  }) {
    DateTime now = DateTime.now();
    int daysBeforeDeparture = originalTravelDate.difference(now).inDays;

    bool isEligible = true;
    String reason = '';

    if (daysBeforeDeparture < 0) {
      isEligible = false;
      reason = 'Tiket sudah melewati tanggal keberangkatan';
    } else if (ticketStatus == 'cancelled') {
      isEligible = false;
      reason = 'Tiket sudah dibatalkan';
    } else if (ticketStatus == 'refunded') {
      isEligible = false;
      reason = 'Tiket sudah di-refund';
    } else if (ticketStatus == 'rescheduled') {
      isEligible = false;
      reason = 'Tiket sudah di-reschedule';
    }

    return {
      'isEligible': isEligible,
      'reason': reason,
      'daysBeforeDeparture': daysBeforeDeparture,
    };
  }

  // Get free reschedule count (for loyalty members)
  int getFreeRescheduleCount(String memberTier) {
    switch (memberTier) {
      case 'Silver':
        return 1;
      case 'Gold':
        return 2;
      case 'Platinum':
        return 3;
      default:
        return 0;
    }
  }

  // Check if user has free reschedule available
  bool hasFreeReschedule(String memberTier) {
    int allowedFree = getFreeRescheduleCount(memberTier);
    if (allowedFree == 0) return false;

    // Count completed reschedules this year
    DateTime startOfYear = DateTime(DateTime.now().year, 1, 1);
    int usedReschedules = _rescheduleBox.values
        .where((r) => 
            r.status == 'completed' && 
            r.processedDate != null &&
            r.processedDate!.isAfter(startOfYear))
        .length;

    return usedReschedules < allowedFree;
  }
}

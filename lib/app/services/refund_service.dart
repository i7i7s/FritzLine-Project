import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/refund_request.dart';
import '../models/user.dart';
import 'auth_service.dart';

class RefundService extends GetxService {
  late Box<RefundRequest> _refundBox;
  final authService = Get.find<AuthService>();

  static const Map<String, double> REFUND_RULES = {
    'H-7+': 0.90,
    'H-3_to_H-6': 0.50,
    'H-1_to_H-2': 0.25,
    'H-0': 0.00,
  };

  Future<RefundService> init() async {
    _refundBox = await Hive.openBox<RefundRequest>('refundRequests');
    return this;
  }

  Map<String, dynamic> calculateRefundAmount({
    required DateTime travelDate,
    required double originalAmount,
    DateTime? requestDate,
  }) {
    requestDate ??= DateTime.now();
    
    int daysBeforeDeparture = travelDate.difference(requestDate).inDays;
    
    double refundPercentage;
    String ruleApplied;
    
    if (daysBeforeDeparture >= 7) {
      refundPercentage = REFUND_RULES['H-7+']!;
      ruleApplied = 'H-7+ (7 hari atau lebih)';
    } else if (daysBeforeDeparture >= 3) {
      refundPercentage = REFUND_RULES['H-3_to_H-6']!;
      ruleApplied = 'H-3 sampai H-6 (3-6 hari)';
    } else if (daysBeforeDeparture >= 1) {
      refundPercentage = REFUND_RULES['H-1_to_H-2']!;
      ruleApplied = 'H-1 sampai H-2 (1-2 hari)';
    } else {
      refundPercentage = REFUND_RULES['H-0']!;
      ruleApplied = 'H-0 (Hari keberangkatan)';
    }
    
    double refundAmount = originalAmount * refundPercentage;
    double adminFee = originalAmount - refundAmount;
    
    return {
      'daysBeforeDeparture': daysBeforeDeparture,
      'refundPercentage': refundPercentage,
      'refundAmount': refundAmount,
      'adminFee': adminFee,
      'ruleApplied': ruleApplied,
      'canRefund': daysBeforeDeparture >= 0,
    };
  }

  Future<RefundRequest> createRefundRequest({
    required String ticketId,
    required String trainId,
    required String trainName,
    required DateTime travelDate,
    required String reason,
    required double originalAmount,
    String? bankAccount,
    String? bankName,
  }) async {
    try {
      var calculation = calculateRefundAmount(
        travelDate: travelDate,
        originalAmount: originalAmount,
      );

      if (!calculation['canRefund']) {
        throw Exception('Tidak dapat mengajukan refund setelah keberangkatan');
      }

      String requestId = 'REF${DateTime.now().millisecondsSinceEpoch}';

      RefundRequest request = RefundRequest(
        requestId: requestId,
        ticketId: ticketId,
        trainId: trainId,
        trainName: trainName,
        travelDate: travelDate,
        requestDate: DateTime.now(),
        reason: reason,
        originalAmount: originalAmount,
        refundAmount: calculation['refundAmount'],
        refundPercentage: calculation['refundPercentage'],
        daysBeforeDeparture: calculation['daysBeforeDeparture'],
        status: 'pending',
        bankAccount: bankAccount,
        bankName: bankName,
      );

      await _refundBox.add(request);

      return request;
    } catch (e) {
      throw Exception('Gagal membuat refund request: $e');
    }
  }

  List<RefundRequest> getUserRefundRequests() {
    User? user = authService.currentUser.value;
    if (user == null) return [];

    return _refundBox.values.toList()
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
  }

  RefundRequest? getRefundRequestById(String requestId) {
    try {
      return _refundBox.values.firstWhere(
        (request) => request.requestId == requestId,
      );
    } catch (e) {
      return null;
    }
  }

  RefundRequest? getRefundRequestByTicketId(String ticketId) {
    try {
      return _refundBox.values.firstWhere(
        (request) => request.ticketId == ticketId,
      );
    } catch (e) {
      return null;
    }
  }

  bool hasRefundRequest(String ticketId) {
    return _refundBox.values.any((request) => request.ticketId == ticketId);
  }

  Future<void> updateRefundStatus({
    required String requestId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      RefundRequest? request = getRefundRequestById(requestId);
      if (request != null) {
        request.status = status;
        request.processedDate = DateTime.now();
        request.adminNotes = adminNotes;
        await request.save();
      }
    } catch (e) {
      throw Exception('Gagal update status refund: $e');
    }
  }

  Future<void> approveRefund(String requestId, {String? notes}) async {
    await updateRefundStatus(
      requestId: requestId,
      status: 'approved',
      adminNotes: notes ?? 'Refund disetujui',
    );
  }

  Future<void> rejectRefund(String requestId, String reason) async {
    await updateRefundStatus(
      requestId: requestId,
      status: 'rejected',
      adminNotes: reason,
    );
  }

  Future<void> completeRefund(String requestId) async {
    await updateRefundStatus(
      requestId: requestId,
      status: 'completed',
      adminNotes: 'Dana sudah ditransfer ke rekening tujuan',
    );
  }

  Future<bool> cancelRefundRequest(String requestId) async {
    try {
      RefundRequest? request = getRefundRequestById(requestId);
      if (request != null && request.status == 'pending') {
        await request.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Gagal cancel refund request: $e');
    }
  }

  String getRefundPolicyText(int daysBeforeDeparture) {
    if (daysBeforeDeparture >= 7) {
      return 'Refund 90% dari harga tiket';
    } else if (daysBeforeDeparture >= 3) {
      return 'Refund 50% dari harga tiket';
    } else if (daysBeforeDeparture >= 1) {
      return 'Refund 25% dari harga tiket';
    } else if (daysBeforeDeparture == 0) {
      return 'Tidak dapat refund (hari keberangkatan)';
    } else {
      return 'Tidak dapat refund (sudah melewati keberangkatan)';
    }
  }

  Map<String, dynamic> getRefundStats() {
    List<RefundRequest> requests = getUserRefundRequests();
    
    int totalRequests = requests.length;
    int pendingRequests = requests.where((r) => r.status == 'pending').length;
    int approvedRequests = requests.where((r) => r.status == 'approved').length;
    int rejectedRequests = requests.where((r) => r.status == 'rejected').length;
    int completedRequests = requests.where((r) => r.status == 'completed').length;
    
    double totalRefunded = requests
        .where((r) => r.status == 'completed')
        .fold(0, (sum, r) => sum + r.refundAmount);

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'approvedRequests': approvedRequests,
      'rejectedRequests': rejectedRequests,
      'completedRequests': completedRequests,
      'totalRefunded': totalRefunded,
    };
  }

  Map<String, dynamic> validateRefundEligibility({
    required DateTime travelDate,
    required String ticketStatus,
  }) {
    DateTime now = DateTime.now();
    int daysBeforeDeparture = travelDate.difference(now).inDays;

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
    }

    return {
      'isEligible': isEligible,
      'reason': reason,
      'daysBeforeDeparture': daysBeforeDeparture,
    };
  }
}

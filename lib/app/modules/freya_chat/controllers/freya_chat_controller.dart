import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/chat_message.dart';
import '../../../services/freya_ai_service.dart';

class FreyaChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isModelLoading = true.obs;
  final RxString modelName = ''.obs;

  final FreyaAIService _aiService = FreyaAIService();

  @override
  void onInit() {
    super.onInit();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    isModelLoading.value = true;
    await _aiService.initialize();

    if (_aiService.isInitialized) {
      modelName.value = _aiService.modelName ?? '';

      // Load chat history from Hive
      final chatHistory = _aiService.loadChatHistory();
      if (chatHistory.isNotEmpty) {
        // Convert history to ChatMessage and add to messages (in reverse for display)
        for (var chat in chatHistory.reversed) {
          messages.insert(
            0,
            ChatMessage(
              text: chat['message'] ?? '',
              isUser: chat['isUser'] ?? false,
              timestamp:
                  DateTime.tryParse(chat['timestamp'] ?? '') ?? DateTime.now(),
            ),
          );
        }
      } else {
        // Show welcome message only if no history
        messages.insert(
          0,
          ChatMessage(
            text:
                'Hai! 👋 Aku Freya, asisten virtual FritzLine! 🚂\n\nAku bisa bantu kamu:\n• Cek jadwal & harga kereta real-time 🎫\n• Panduan booking tiket 📱\n• Rekomendasi destinasi wisata 🏝️\n• Info kuliner & budaya lokal 🍜\n• Tips travelling hemat 💰\n• Cek tiket kamu yang aktif 🎟️\n\nMau tanya apa nih? 😊',
            isUser: false,
          ),
        );
      }
    } else {
      messages.insert(
        0,
        ChatMessage(
          text:
              'Maaf, aku sedang mengalami masalah koneksi. Pastikan internet kamu aktif ya! 🔌',
          isUser: false,
        ),
      );
    }

    isModelLoading.value = false;
  }

  void clearHistory() async {
    await _aiService.clearChatHistory();
    messages.clear();
    messages.insert(
      0,
      ChatMessage(
        text:
            'Chat history sudah dihapus! ✨\n\nAku Freya siap bantu kamu lagi! Ada yang mau ditanyakan? 😊',
        isUser: false,
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.insert(0, ChatMessage(text: text, isUser: true));

    textController.clear();
    isLoading.value = true;

    try {
      final response = await _aiService.sendMessage(text);

      messages.insert(0, ChatMessage(text: response, isUser: false));
    } catch (e) {
      messages.insert(
        0,
        ChatMessage(
          text: 'Maaf, terjadi kesalahan. Coba lagi ya! 😔',
          isUser: false,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    _aiService.dispose();
    super.onClose();
  }
}

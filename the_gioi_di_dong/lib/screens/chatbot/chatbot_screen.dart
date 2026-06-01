import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
//import '../../core/constants.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const String _chatKeyPrefix = 'tgdd_chat_history';

  bool isLoading = false;

  final List<Map<String, String>> messages = [
    {
      'role': 'bot',
      'text':
          'Dạ em chào Anh/Chị 👋\nEm là trợ lý mua sắm của Thế Giới Di Động. Anh/Chị cần em hỗ trợ tư vấn sản phẩm, khuyến mãi, bảo hành hay đơn hàng ạ?',
    },
  ];

  final List<String> quickQuestions = [
    'Tư vấn laptop',
    'Tư vấn điện thoại',
    'Khuyến mãi hôm nay',
    'Chính sách bảo hành',
    'Mua trả góp',
    'Kiểm tra đơn hàng',
  ];

  @override
  void initState() {
    super.initState();
    loadChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatKey(SharedPreferences prefs) {
    final maTk = prefs.getString('maTk')?.trim();
    if (maTk != null && maTk.isNotEmpty) {
      return '${_chatKeyPrefix}_user_$maTk';
    }

    final email = prefs.getString('userEmail')?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return '${_chatKeyPrefix}_email_$email';
    }

    return '${_chatKeyPrefix}_guest';
  }

  Future<void> saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatKey = _getChatKey(prefs);

    final messagesToSave = messages
        .where((item) => item['text'] != 'Đang nhập...')
        .toList();

    final jsonString = jsonEncode(messagesToSave);
    await prefs.setString(chatKey, jsonString);
  }

  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatKey = _getChatKey(prefs);
    var jsonString = prefs.getString(chatKey);

    if (jsonString == null) {
      final oldJsonString = prefs.getString(_chatKeyPrefix);
      if (oldJsonString != null) {
        await prefs.setString(chatKey, oldJsonString);
        await prefs.remove(_chatKeyPrefix);
        jsonString = oldJsonString;
      }
    }

    if (jsonString == null) return;

    final List<dynamic> data = jsonDecode(jsonString);

    if (!mounted) return;

    setState(() {
      messages.clear();
      messages.addAll(
        data.map((item) {
          return {
            'role': item['role'].toString(),
            'text': item['text'].toString(),
          };
        }).toList(),
      );
    });

    scrollToBottom();
  }

  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatKey = _getChatKey(prefs);
    await prefs.remove(chatKey);

    setState(() {
      messages.clear();
      messages.add({
        'role': 'bot',
        'text':
            'Dạ em chào Anh/Chị 👋\nEm là trợ lý mua sắm của Thế Giới Di Động. Anh/Chị cần em hỗ trợ tư vấn sản phẩm, khuyến mãi, bảo hành hay đơn hàng ạ?',
      });
    });

    await saveChatHistory();
    scrollToBottom();
  }

  Future<void> showClearChatDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa lịch sử chat?'),
          content: const Text(
            'Anh/Chị có chắc muốn xóa toàn bộ cuộc trò chuyện với TGDĐ AI Assistant không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await clearChatHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBC05),
                foregroundColor: Colors.black,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMessage({String? quickText}) async {
    final text = quickText ?? _controller.text.trim();

    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});

      messages.add({'role': 'bot', 'text': 'Đang nhập...'});

      isLoading = true;
    });

    _controller.clear();
    scrollToBottom();

    final historyForAI = List<Map<String, String>>.from(messages);

    final reply = await GeminiService.sendMessage(
      message: text,
      history: historyForAI,
    );

    if (!mounted) return;

    setState(() {
      messages.removeLast();

      messages.add({'role': 'bot', 'text': reply});

      isLoading = false;
    });

    await saveChatHistory();
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildBotAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryThis,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.support_agent, size: 20, color: Colors.black),
    );
  }

  Widget buildMessage(Map<String, String> message) {
    final bool isUser = message['role'] == 'user';
    final bool isTyping = message['text'] == 'Đang nhập...';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 6, bottom: 6, left: 70, right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFCFEAFF),
            borderRadius: BorderRadius.circular(
              18,
            ).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(
            message['text'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildBotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primaryThis,
                borderRadius: BorderRadius.circular(
                  18,
                ).copyWith(bottomLeft: const Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isTyping
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Đang nhập...', style: TextStyle(fontSize: 15)),
                      ],
                    )
                  : Text(
                      message['text'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickQuestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickQuestions.map((question) {
          return ActionChip(
            label: Text(
              question,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            onPressed: isLoading
                ? null
                : () {
                    sendMessage(quickText: question);
                  },
          );
        }).toList(),
      ),
    );
  }

  Widget buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isLoading,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi của Anh/Chị...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFBC05),
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: isLoading ? null : () => sendMessage(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey.shade300
                      : AppColors.primaryThis,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderStatus() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryThis,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Đang trực tuyến • Hỗ trợ mua sắm 24/7',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryThis,
        elevation: 0,
        title: const Text(
          'TGDĐ AI Assistant',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: isLoading ? null : showClearChatDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          buildHeaderStatus(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          buildQuickQuestions(),
          buildInputArea(),
        ],
      ),
    );
  }
}

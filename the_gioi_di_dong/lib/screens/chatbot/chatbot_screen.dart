import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_sweep, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                'Xóa lịch sử?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Anh/Chị có chắc muốn xóa toàn bộ cuộc trò chuyện này không?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await clearChatHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xóa ngay'),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryThis,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.support_agent, size: 22, color: Colors.black),
    );
  }

  Widget buildMessage(Map<String, String> message) {
    final bool isUser = message['role'] == 'user';
    final bool isTyping = message['text'] == 'Đang nhập...';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, left: 60, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF00B0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              20,
            ).copyWith(bottomRight: const Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message['text'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildBotAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(
                  20,
                ).copyWith(bottomLeft: const Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isTyping
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryThis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Đang nhập...',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

  // Cải tiến: Cuộn ngang cho các câu hỏi nhanh
  Widget buildQuickQuestions() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: quickQuestions.map((question) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  question,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blueGrey.shade100),
                ),
                onPressed: isLoading
                    ? null
                    : () => sendMessage(quickText: question),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                  hintText: 'Nhập câu hỏi...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primaryThis,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: isLoading ? null : () => sendMessage(),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey.shade300
                      : AppColors.primaryThis,
                  shape: BoxShape.circle,
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primaryThis.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Đang trực tuyến • Hỗ trợ mua sắm 24/7',
            style: TextStyle(
              color: Colors.white,
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryThis,
        elevation: 0,
        title: const Text(
          'TGDĐ AI Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử chat',
            icon: const Icon(Icons.delete_outline, color: Colors.white),
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
              padding: const EdgeInsets.only(top: 16, bottom: 16),
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

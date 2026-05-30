import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  // 1. Hàm định dạng tiền tệ VNĐ
  static String formatCurrency(double amount) {
    // Định dạng kiểu: 23.790.000đ
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  // 2. Hàm rút gọn chuỗi dài (Tránh bị tràn UI)
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // 3. (Tùy chọn) Hàm in log đẹp ra Terminal để dễ debug
  static void printLog(String message) {
    print('💡 [APP_LOG]: $message');
  }
}

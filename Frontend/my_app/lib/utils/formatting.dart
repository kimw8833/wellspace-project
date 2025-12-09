// lib/utils/formatting.dart

/// Formatting utilities (no Flutter dependencies!)
class Formatting {
  /// Format a DateTime: yyyy-mm-dd HH:MM
  static String timestamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');

    return "${d.year}-${two(d.month)}-${two(d.day)}  "
           "${two(d.hour)}:${two(d.minute)}";
  }
}

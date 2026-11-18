import 'package:flutter/material.dart';

/// 漲跌色。台灣慣例紅漲綠跌、美股慣例綠漲紅跌 → 做成可切換（設定頁一個開關），
/// 而且**只准從 ThemeExtension 取**，不準在任何 widget 裡寫死 `Colors.red`。
///
/// 桌面小工具是 Kotlin（`android/app/src/main/kotlin/.../DquoteWidget.kt` 的
/// `RED_UP / GREEN_DOWN / FLAT`）：**同一個語意、不是同一組色值**。小工具的卡片底色是深的
/// (0xF0121A24)，那邊用亮一階的 #EF5350/#66BB6A 才看得清；紅漲綠跌由 payload 的 `red_is_up`
/// 決定，那一側不自己判斷。改這裡不會改到小工具 —— 要換色得兩邊一起想。
@immutable
class PriceColors extends ThemeExtension<PriceColors> {
  const PriceColors({required this.up, required this.down, required this.flat});

  final Color up;
  final Color down;
  final Color flat;

  Color forChange(num? change) {
    final c = change ?? 0;
    if (c > 0) return up;
    if (c < 0) return down;
    return flat;
  }

  static const twConvention = PriceColors(
    up: Color(0xFFD32F2F), // 紅漲
    down: Color(0xFF388E3C), // 綠跌
    flat: Color(0xFF757575),
  );

  static const usConvention = PriceColors(
    up: Color(0xFF388E3C),
    down: Color(0xFFD32F2F),
    flat: Color(0xFF757575),
  );

  @override
  PriceColors copyWith({Color? up, Color? down, Color? flat}) =>
      PriceColors(up: up ?? this.up, down: down ?? this.down, flat: flat ?? this.flat);

  @override
  PriceColors lerp(ThemeExtension<PriceColors>? other, double t) {
    if (other is! PriceColors) return this;
    return PriceColors(
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      flat: Color.lerp(flat, other.flat, t)!,
    );
  }
}

extension PriceColorsX on BuildContext {
  PriceColors get priceColors => Theme.of(this).extension<PriceColors>() ?? PriceColors.twConvention;
}

ThemeData buildTheme({required Brightness brightness, required bool redIsUp}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3F51B5),
    brightness: brightness,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: scheme.surfaceContainerLow,
    ),
    extensions: [redIsUp ? PriceColors.twConvention : PriceColors.usConvention],
  );
}

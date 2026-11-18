import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../generated/l10n/app_localizations.dart';

/// 自選股 → 「代號: 顯示名」清單（給 [SymbolField] 的下拉）。
/// 自己取的暱稱優先，其次才是來源給的名字 —— 與小工具/日報同一個順序。
Map<String, String> symbolOptionsOf(List<Instrument> instruments) => {
      for (final i in instruments)
        i.symbol: (i.alias != null && i.alias!.isNotEmpty) ? i.alias! : i.name,
    };

/// 「可以選、也可以打」的代號欄位。
///
/// 只做下拉不夠用：提醒常常盯**不在自選股裡**的代號（匯率、沒加自選的外資股），
/// 持股也常常是剛買還沒加自選的那档；但只能手敲又逼使用者記 `2330.TW` 這種後綴。
/// 所以留 TextField，旁邊加一顆按鈕開清單。清單是空的（自選股還沒東西）就不顯示按鈕。
class SymbolField extends StatelessWidget {
  const SymbolField({
    super.key,
    required this.controller,
    required this.options,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;

  /// 代號 → 顯示名（顯示名空白的項目在清單裡退回顯示代號）。
  final Map<String, String> options;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        suffixIcon: (enabled && options.isEmpty)
            ? null
            : IconButton(
                icon: const Icon(Icons.expand_more),
                tooltip: l.pickSymbol,
                onPressed: () async {
                  final picked = await showSymbolPicker(context, options);
                  if (picked != null) controller.text = picked;
                },
              ),
      ),
    );
  }
}

/// 清單本身。**名稱排前面、代號排下面** —— 使用者記得的是「台積電」，不是 `2330.TW`。
/// 按一下就回傳代號，呼叫端填回欄位；還是可以自己打（清單裡沒有的代號）。
Future<String?> showSymbolPicker(BuildContext context, Map<String, String> options) {
  final l = AppLocalizations.of(context)!;
  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l.pickSymbol, style: Theme.of(sheetContext).textTheme.titleMedium),
          ),
          for (final e in options.entries)
            ListTile(
              title: Text(e.value.isEmpty ? e.key : e.value),
              subtitle: Text(e.key),
              onTap: () => Navigator.pop(sheetContext, e.key),
            ),
        ],
      ),
    ),
  );
}

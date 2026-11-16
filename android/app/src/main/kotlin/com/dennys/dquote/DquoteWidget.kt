package com.dennys.dquote

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.json.JSONObject

/**
 * 桌面小工具（Jetpack Glance）。
 *
 * 資料是 Flutter 端用 home_widget 寫進 SharedPreferences（檔名 `HomeWidgetPreferences`）的
 * JSON，**契約定義在 Dart 的 `lib/core/widget_data.dart`（WidgetContract）**；欄位名稱兩邊
 * 必須一致，改一邊就要改另一邊，並更新 `test/widget_data_test.dart`。
 * SharedPreferences 檔名與欄位名這裡是手抄的：home_widget 的 `PREFERENCES` 常數是 internal，
 * App 端讀不到。它壞掉的症狀是「小工具永遠不更新」而不會報錯 —— 改完契約要上桌面看一眼數字有沒有變。
 *
 * **兩個容易踩的坑**：
 * 1. Receiver 類別名必須是 `DquoteWidget`，因為 Dart 端叫的是
 *    `HomeWidget.updateWidget(androidName: "DquoteWidget")`；對不上時不會報錯，只会永遠不更新。
 * 2. manifest 裡註冊的是 `DquoteWidgetReceiver`（Glance 要求 receiver 繼承
 *    GlanceAppWidgetReceiver），不是 `DquoteWidget` 本身。
 */
class DquoteWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val payload = WidgetData.parse(prefs.getString(WidgetData.QUOTES_KEY, null))

        provideContent {
            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(ColorProvider(Color(0xF0121A24)))
                    .padding(10.dp),
            ) {
                if (payload == null || payload.rows.isEmpty()) {
                    Text(
                        "dQuote — 尚無資料（打開 app 更新一次）",
                        style = TextStyle(color = ColorProvider(Color(0xFFB9C2CC)), fontSize = 12.sp),
                    )
                } else {
                    payload.rows.forEach { row ->
                        Row(
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(vertical = 2.dp)
                                .clickable(openQuote(context, row.symbol)),
                        ) {
                            Text(
                                row.title(),
                                maxLines = 1,
                                modifier = GlanceModifier.defaultWeight(),
                                style = TextStyle(color = ColorProvider(Color(0xFFF2F5F8)), fontSize = 13.sp),
                            )
                            Column(
                                modifier = GlanceModifier.padding(start = 6.dp),
                                horizontalAlignment = Alignment.Horizontal.End,
                            ) {
                                Text(
                                    row.price(),
                                    style = TextStyle(
                                        color = ColorProvider(row.colorValue(payload.redIsUp)),
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                    ),
                                )
                                Text(
                                    row.changeText(),
                                    style = TextStyle(
                                        color = ColorProvider(row.colorValue(payload.redIsUp)),
                                        fontSize = 10.sp,
                                    ),
                                )
                            }
                        }
                    }
                    Text(
                        "更新於 ${payload.updatedAtText()}",
                        style = TextStyle(color = ColorProvider(Color(0xFF8A94A0)), fontSize = 10.sp),
                    )
                }
            }
        }
    }

    /** 點某一列 → deep link 開到那档的走勢頁（Dart 的 `main.dart` 用 initialRouteOf 解析）。 */
    private fun openQuote(context: Context, symbol: String) = actionStartActivity(
        Intent(Intent.ACTION_VIEW, Uri.parse("dquote://quote/${Uri.encode(symbol)}"))
            .setPackage(context.packageName)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
    )

    companion object {
        /** == home_widget 的 `HomeWidgetPlugin.PREFERENCES`（internal，無法直接引用）。 */
        const val PREFERENCES = "HomeWidgetPreferences"
    }
}

class DquoteWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = DquoteWidget()
}

/**
 * 解析 Dart 寫進來的 payload。獨立成 object 是因為它是純邏輯，而且**壞掉時不能讓 widget 崩**：
 * 拿不到/解析失敗就回 null，由 UI 顯示佔位文字。
 */
object WidgetData {
    const val QUOTES_KEY = "quotes" // == WidgetContract.quotesKey

    data class Row(
        val symbol: String,
        val name: String,
        val price: Double,
        val change: Double?,
        val changePct: Double?,
        val currency: String,
        val market: String,
    ) {
        fun title(): String = name.ifBlank { symbol }

        /** 與 app 的 `quoteChangeText` 同規則：`+15.00 (+0.63%)`，匯率絕對值用 4 位小數。 */
        fun changeText(): String {
            val digits = if (market == "fx") 4 else 2
            val abs = change?.let { signed(it, digits) }
            val pct = changePct?.let { "(${signed(it, 2)}%)" }
            return listOfNotNull(abs, pct).joinToString(" ")
        }

        /** 幣別不能決定小數位：匯率（market == "fx"）的價格本身就是小數，
         *  只看 TWD 會把 USD/TWD 印成「32」。跟 Dart 的 `Market.fx` 判斷一致。 */
        fun price(): String =
            if (currency == "TWD" && market != "fx") fmt(price, 0) else fmt(price, 2)

        /** 與 app 同一組色：紅漲緑跌由 payload 的 red_is_up 決定（設定頁那個開關）。 */
        fun colorValue(redIsUp: Boolean): Color = when {
            (changePct ?: 0.0) > 0.0 -> if (redIsUp) RED_UP else GREEN_DOWN
            (changePct ?: 0.0) < 0.0 -> if (redIsUp) GREEN_DOWN else RED_UP
            else -> FLAT
        }
    }

    data class Payload(val updatedAt: Long, val rows: List<Row>, val redIsUp: Boolean) {
        fun updatedAtText(): String {
            if (updatedAt <= 0) return "—"
            val fmt = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
            return fmt.format(java.util.Date(updatedAt * 1000))
        }
    }

    // 必須用 Compose Color：ColorProvider(Int) 會被當成 @ColorRes 資源 ID，ARGB 值會讓小工具無法載入。
    private val RED_UP = Color(0xFFEF5350)
    private val GREEN_DOWN = Color(0xFF66BB6A)
    private val FLAT = Color(0xFFB0BEC5)

    fun parse(raw: String?): Payload? {
        if (raw.isNullOrBlank()) return null
        return try {
            val o = JSONObject(raw)
            val arr = o.optJSONArray("rows") ?: return null
            val list = ArrayList<Row>()
            for (i in 0 until arr.length()) {
                val r = arr.optJSONObject(i) ?: continue
                val symbol = r.optString("symbol")
                if (symbol.isEmpty()) continue
                list.add(
                    Row(
                        symbol = symbol,
                        name = r.optString("name"),
                        price = r.optDouble("price", 0.0),
                        change = if (r.isNull("chg")) null else r.optDouble("chg", 0.0),
                        changePct = if (r.isNull("chg_pct")) null else r.optDouble("chg_pct", 0.0),
                        currency = r.optString("ccy", "TWD"),
                        market = r.optString("market", "taiwan"),
                    ),
                )
            }
            Payload(o.optLong("updated_at", 0), list, o.optBoolean("red_is_up", true))
        } catch (e: Exception) {
            null
        }
    }

    private fun signed(v: Double, digits: Int): String =
        (if (v > 0) "+" else "") + fmt(v, digits)

    private fun fmt(v: Double, digits: Int): String =
        java.text.NumberFormat.getNumberInstance(java.util.Locale.US).apply {
            maximumFractionDigits = digits
            minimumFractionDigits = digits
        }.format(v)
}

package com.example.zikirmatik

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "zikrCard", ZikrAdFactory(this))
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "zikrCard")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

private class ZikrAdFactory(private val context: Context) : NativeAdFactory {
    private fun dp(value: Int) = (value * context.resources.displayMetrics.density).toInt()
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val view = NativeAdView(context)
        val green = Color.rgb(0, 41, 29)
        val gold = Color.rgb(235, 198, 109)
        view.background = GradientDrawable().apply {
            setColor(Color.rgb(244, 227, 196)); cornerRadius = dp(13).toFloat(); setStroke(dp(1), gold)
        }
        view.clipToOutline = true
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(6), dp(6), dp(8), dp(6))
        }
        view.addView(row, FrameLayout.LayoutParams(-1, -1))
        val media = MediaView(context)
        row.addView(media, LinearLayout.LayoutParams(dp(120), dp(120)))
        media.mediaContent = nativeAd.mediaContent
        view.mediaView = media
        val text = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL; gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(10), dp(12), dp(14), dp(2))
        }
        row.addView(text, LinearLayout.LayoutParams(0, -1, 1f))
        val headline = TextView(context).apply {
            this.text = nativeAd.headline; textSize = 13f; setTextColor(green)
            setTypeface(typeface, Typeface.BOLD); maxLines = 2
        }
        text.addView(headline)
        view.headlineView = headline
        val detail = TextView(context).apply {
            this.text = nativeAd.advertiser ?: nativeAd.body; textSize = 10f; setTextColor(green)
            maxLines = 2; visibility = if (this.text.isNullOrBlank()) View.GONE else View.VISIBLE
        }
        text.addView(detail)
        if (nativeAd.advertiser != null) view.advertiserView = detail else view.bodyView = detail
        val cta = Button(context).apply {
            this.text = nativeAd.callToAction; textSize = 11f; isAllCaps = false; setTextColor(green)
            setPadding(dp(6), 0, dp(6), 0); minHeight = 0; minimumHeight = 0
            background = GradientDrawable().apply { setColor(gold); cornerRadius = dp(15).toFloat() }
            visibility = if (nativeAd.callToAction == null) View.GONE else View.VISIBLE
        }
        text.addView(cta, LinearLayout.LayoutParams(-1, dp(30)).apply { topMargin = dp(7) })
        view.callToActionView = cta
        val disclosure = TextView(context).apply {
            this.text = "Ad"; textSize = 10f; setTextColor(Color.WHITE); setPadding(dp(3), 0, dp(3), 0)
            setBackgroundColor(green)
        }
        view.addView(disclosure, FrameLayout.LayoutParams(-2, -2, Gravity.TOP or Gravity.LEFT).apply {
            leftMargin = dp(7); topMargin = dp(7)
        })
        // No custom click listeners: asset clicks and AdChoices belong to the SDK.
        view.setNativeAd(nativeAd)
        return view
    }
}

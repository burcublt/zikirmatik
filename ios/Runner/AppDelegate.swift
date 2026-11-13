import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(engineBridge.pluginRegistry,
      factoryId: "zikrCard", nativeAdFactory: ZikrAdFactory())
  }
}


private class ZikrAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable: Any]? = nil) -> NativeAdView? {
    let width = (customOptions?["width"] as? NSNumber)?.doubleValue ?? 340
    let view = NativeAdView(frame: CGRect(x: 0, y: 0, width: width, height: 132))
    let green = UIColor(red: 0, green: 41/255, blue: 29/255, alpha: 1)
    let gold = UIColor(red: 235/255, green: 198/255, blue: 109/255, alpha: 1)
    view.backgroundColor = UIColor(red: 244/255, green: 227/255, blue: 196/255, alpha: 1)
    view.layer.cornerRadius = 13; view.layer.borderWidth = 1; view.layer.borderColor = gold.cgColor
    view.clipsToBounds = true
    let media = MediaView()
    media.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(media)
    NSLayoutConstraint.activate([
      media.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
      media.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      media.widthAnchor.constraint(equalToConstant: 120), media.heightAnchor.constraint(equalToConstant: 120)])
    media.mediaContent = nativeAd.mediaContent
    view.mediaView = media
    let headline = UILabel()
    headline.text = nativeAd.headline; headline.font = .systemFont(ofSize: 13, weight: .semibold)
    headline.textColor = green; headline.numberOfLines = 2
    let detail = UILabel()
    detail.text = nativeAd.advertiser ?? nativeAd.body; detail.font = .systemFont(ofSize: 10)
    detail.textColor = green; detail.numberOfLines = 2; detail.isHidden = detail.text == nil
    let cta = UIButton(type: .system)
    cta.setTitle(nativeAd.callToAction, for: .normal); cta.setTitleColor(green, for: .normal)
    cta.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
    cta.backgroundColor = gold; cta.layer.cornerRadius = 15
    cta.isHidden = nativeAd.callToAction == nil; cta.isUserInteractionEnabled = false
    cta.heightAnchor.constraint(equalToConstant: 30).isActive = true
    let stack = UIStackView(arrangedSubviews: [headline, detail, cta])
    stack.axis = .vertical; stack.spacing = 6; stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: media.trailingAnchor, constant: 10),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      stack.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 16),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -6),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    view.headlineView = headline
    if nativeAd.advertiser != nil { view.advertiserView = detail } else { view.bodyView = detail }
    view.callToActionView = cta
    let disclosure = UILabel(frame: CGRect(x: 7, y: 7, width: 22, height: 14))
    disclosure.text = "Ad"; disclosure.font = .systemFont(ofSize: 10, weight: .semibold)
    disclosure.textAlignment = .center; disclosure.textColor = .white; disclosure.backgroundColor = green
    view.addSubview(disclosure)
    view.nativeAd = nativeAd
    return view
  }
}

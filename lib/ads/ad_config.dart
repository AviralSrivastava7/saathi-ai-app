// // ═══════════════════════════════════════════════════════════
// //  📱 AD CONFIGURATION - REAL AD UNIT IDs
// //  Production-ready AdMob configuration
// // ═══════════════════════════════════════════════════════════
//
// import 'dart:io';
//
// class AdConfig {
//   // ─────────────────────────────────────────────────────────
//   //  🎯 PRODUCTION MODE - Real Ads
//   // ─────────────────────────────────────────────────────────
//   static const bool testMode = false; // Set to false for real ads
//
//   // ─────────────────────────────────────────────────────────
//   //  📱 REAL AD UNIT IDs (From AdMob Dashboard)
//   // ─────────────────────────────────────────────────────────
//
//   // Banner Ads
//   static const String _androidBannerHome = 'ca-app-pub-1532529045055697/9086995718';
//   static const String _androidBannerExercises = 'ca-app-pub-1532529045055697/5319867448';
//
//   // Interstitial Ad
//   static const String _androidInterstitial = 'ca-app-pub-1532529045055697/2186535705';
//
//   // Native Ad
//   static const String _androidNative = 'ca-app-pub-1532529045055697/2693704109';
//
//   // Rewarded Ad
//   static const String _androidRewarded = 'ca-app-pub-1532529045055697/1208505692';
//
//   // iOS Ad Units (Add your iOS IDs here when available)
//   static const String _iosBannerHome = 'ca-app-pub-1532529045055697/9086995718';
//   static const String _iosBannerExercises = 'ca-app-pub-1532529045055697/5319867448';
//   static const String _iosInterstitial = 'ca-app-pub-1532529045055697/2186535705';
//   static const String _iosNative = 'ca-app-pub-1532529045055697/2693704109';
//   static const String _iosRewarded = 'ca-app-pub-1532529045055697/1208505692';
//
//   // ─────────────────────────────────────────────────────────
//   //  🎯 PUBLIC GETTERS - Platform-specific Ad Units
//   // ─────────────────────────────────────────────────────────
//
//   /// Banner Ad for Home Screen
//   static String get bannerHomeAdUnit {
//     if (Platform.isAndroid) {
//       return _androidBannerHome;
//     } else if (Platform.isIOS) {
//       return _iosBannerHome;
//     }
//     throw UnsupportedError('Unsupported platform');
//   }
//
//   /// Banner Ad for Exercises Screen
//   static String get bannerExercisesAdUnit {
//     if (Platform.isAndroid) {
//       return _androidBannerExercises;
//     } else if (Platform.isIOS) {
//       return _iosBannerExercises;
//     }
//     throw UnsupportedError('Unsupported platform');
//   }
//
//   /// Interstitial Ad (General)
//   static String get interstitialAdUnit {
//     if (Platform.isAndroid) {
//       return _androidInterstitial;
//     } else if (Platform.isIOS) {
//       return _iosInterstitial;
//     }
//     throw UnsupportedError('Unsupported platform');
//   }
//
//   /// Native Advanced Ad (Tips List)
//   static String get nativeAdUnit {
//     if (Platform.isAndroid) {
//       return _androidNative;
//     } else if (Platform.isIOS) {
//       return _iosNative;
//     }
//     throw UnsupportedError('Unsupported platform');
//   }
//
//   /// Rewarded Ad (Premium Features)
//   static String get rewardedAdUnit {
//     if (Platform.isAndroid) {
//       return _androidRewarded;
//     } else if (Platform.isIOS) {
//       return _iosRewarded;
//     }
//     throw UnsupportedError('Unsupported platform');
//   }
//
//   // ─────────────────────────────────────────────────────────
//   //  ⚙️ AD BEHAVIOR SETTINGS
//   // ─────────────────────────────────────────────────────────
//
//   /// Show interstitial ad after every N actions
//   static const int interstitialFrequency = 3;
//
//   /// Minimum time between interstitial ads (seconds)
//   static const int minTimeBetweenInterstitials = 60;
//
//   /// Enable/disable native ads in lists
//   static const bool enableNativeAds = true;
//
//   /// Show native ad after every N list items
//   static const int nativeAdFrequency = 5;
//
//   // ─────────────────────────────────────────────────────────
//   //  📊 AD PLACEMENT NAMES (for analytics)
//   // ─────────────────────────────────────────────────────────
//
//   static const String placementHome = 'home';
//   static const String placementExercises = 'exercises';
//   static const String placementTips = 'tips';
//   static const String placementJournal = 'journal';
//   static const String placementMood = 'mood';
//
//   // ─────────────────────────────────────────────────────────
//   //  🎨 AD UI CUSTOMIZATION
//   // ─────────────────────────────────────────────────────────
//
//   /// Banner ad height
//   static const double bannerHeight = 60.0;
//
//   /// Native ad height in list
//   static const double nativeAdHeight = 120.0;
//
//   /// Ad loading timeout (milliseconds)
//   static const int adLoadTimeout = 10000;
//
//   // ─────────────────────────────────────────────────────────
//   //  🔐 PRIVACY & COMPLIANCE
//   // ─────────────────────────────────────────────────────────
//
//   /// Enable personalized ads (GDPR compliance)
//   static bool enablePersonalizedAds = true;
//
//   /// Child-directed treatment (COPPA compliance)
//   static bool isChildDirected = false;
//
//   /// Under age of consent
//   static bool isUnderAgeOfConsent = false;
//
//   // ─────────────────────────────────────────────────────────
//   //  📝 HELPER METHODS
//   // ─────────────────────────────────────────────────────────
//
//   /// Get banner ad unit based on placement
//   static String getBannerAdUnit(String placement) {
//     switch (placement) {
//       case placementHome:
//         return bannerHomeAdUnit;
//       case placementExercises:
//         return bannerExercisesAdUnit;
//       default:
//         return bannerHomeAdUnit;
//     }
//   }
//
//   /// Check if ads should be shown (can be used for premium users)
//   static bool shouldShowAds() {
//     // TODO: Check if user has premium subscription
//     // For now, always show ads
//     return true;
//   }
//
//   /// Log ad event (for debugging)
//   static void logAdEvent(String event, {Map<String, dynamic>? params}) {
//     if (testMode) {
//       print('🎯 Ad Event: $event ${params != null ? params.toString() : ''}');
//     }
//   }
// }
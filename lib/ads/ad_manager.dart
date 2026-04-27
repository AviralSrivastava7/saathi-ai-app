// // ═══════════════════════════════════════════════════════════
// //  📱 AD MANAGER - Production Ready
// //  Complete AdMob initialization and management
// // ═══════════════════════════════════════════════════════════
//
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/material.dart';
// import 'ad_config.dart';
//
// class AdManager {
//   // Singleton pattern
//   static final AdManager _instance = AdManager._internal();
//   factory AdManager() => _instance;
//   AdManager._internal();
//
//   // ─────────────────────────────────────────────────────────
//   //  📊 STATE MANAGEMENT
//   // ─────────────────────────────────────────────────────────
//
//   bool _isInitialized = false;
//   bool get isInitialized => _isInitialized;
//
//   InterstitialAd? _interstitialAd;
//   bool _isInterstitialLoading = false;
//   DateTime? _lastInterstitialShownTime;
//
//   RewardedAd? _rewardedAd;
//   bool _isRewardedLoading = false;
//
//   // ─────────────────────────────────────────────────────────
//   //  🚀 INITIALIZATION
//   // ─────────────────────────────────────────────────────────
//
//   /// Initialize AdMob SDK
//   Future<void> initialize() async {
//     if (_isInitialized) {
//       debugPrint('✅ AdMob already initialized');
//       return;
//     }
//
//     try {
//       debugPrint('🚀 Initializing AdMob...');
//
//       // Initialize Mobile Ads SDK
//       await MobileAds.instance.initialize();
//
//       // Set request configuration
//       final RequestConfiguration requestConfig = RequestConfiguration(
//         testDeviceIds: AdConfig.testMode ? ['YOUR_TEST_DEVICE_ID'] : [],
//         tagForChildDirectedTreatment:
//         AdConfig.isChildDirected ? TagForChildDirectedTreatment.yes : TagForChildDirectedTreatment.no,
//         tagForUnderAgeOfConsent:
//         AdConfig.isUnderAgeOfConsent ? TagForUnderAgeOfConsent.yes : TagForUnderAgeOfConsent.no,
//       );
//
//       MobileAds.instance.updateRequestConfiguration(requestConfig);
//
//       _isInitialized = true;
//
//       // Preload first interstitial ad
//       _loadInterstitialAd();
//
//       // Preload first rewarded ad
//       _loadRewardedAd();
//
//       debugPrint('✅ AdMob initialized successfully');
//       AdConfig.logAdEvent('AdMob_Initialized');
//
//     } catch (e) {
//       debugPrint('❌ AdMob initialization failed: $e');
//       _isInitialized = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────
//   //  📺 INTERSTITIAL AD
//   // ─────────────────────────────────────────────────────────
//
//   /// Load interstitial ad
//   void _loadInterstitialAd() {
//     if (_isInterstitialLoading || _interstitialAd != null) {
//       return;
//     }
//
//     _isInterstitialLoading = true;
//     debugPrint('⏳ Loading interstitial ad...');
//
//     InterstitialAd.load(
//       adUnitId: AdConfig.interstitialAdUnit,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Interstitial ad loaded');
//           _interstitialAd = ad;
//           _isInterstitialLoading = false;
//
//           // Set up ad events
//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdShowedFullScreenContent: (ad) {
//               debugPrint('📺 Interstitial ad showed');
//               AdConfig.logAdEvent('Interstitial_Showed');
//             },
//             onAdDismissedFullScreenContent: (ad) {
//               debugPrint('❌ Interstitial ad dismissed');
//               ad.dispose();
//               _interstitialAd = null;
//               // Load next ad
//               _loadInterstitialAd();
//               AdConfig.logAdEvent('Interstitial_Dismissed');
//             },
//             onAdFailedToShowFullScreenContent: (ad, error) {
//               debugPrint('❌ Interstitial ad failed to show: $error');
//               ad.dispose();
//               _interstitialAd = null;
//               _loadInterstitialAd();
//               AdConfig.logAdEvent('Interstitial_ShowFailed', params: {'error': error.toString()});
//             },
//           );
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint('❌ Interstitial ad failed to load: $error');
//           _isInterstitialLoading = false;
//           _interstitialAd = null;
//           AdConfig.logAdEvent('Interstitial_LoadFailed', params: {'error': error.toString()});
//
//           // Retry after delay
//           Future.delayed(const Duration(seconds: 10), () {
//             _loadInterstitialAd();
//           });
//         },
//       ),
//     );
//   }
//
//   /// Show interstitial ad
//   Future<void> showInterstitialAd({required String source}) async {
//     if (!_isInitialized || !AdConfig.shouldShowAds()) {
//       debugPrint('⚠️ Ads disabled or not initialized');
//       return;
//     }
//
//     // Check minimum time between ads
//     if (_lastInterstitialShownTime != null) {
//       final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShownTime!);
//       if (timeSinceLastAd.inSeconds < AdConfig.minTimeBetweenInterstitials) {
//         debugPrint('⏳ Too soon to show another ad');
//         return;
//       }
//     }
//
//     if (_interstitialAd == null) {
//       debugPrint('⚠️ Interstitial ad not ready, loading...');
//       _loadInterstitialAd();
//       return;
//     }
//
//     try {
//       await _interstitialAd!.show();
//       _lastInterstitialShownTime = DateTime.now();
//       AdConfig.logAdEvent('Interstitial_Shown', params: {'source': source});
//     } catch (e) {
//       debugPrint('❌ Error showing interstitial ad: $e');
//       _interstitialAd?.dispose();
//       _interstitialAd = null;
//       _loadInterstitialAd();
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────
//   //  🎁 REWARDED AD
//   // ─────────────────────────────────────────────────────────
//
//   /// Load rewarded ad
//   void _loadRewardedAd() {
//     if (_isRewardedLoading || _rewardedAd != null) {
//       return;
//     }
//
//     _isRewardedLoading = true;
//     debugPrint('⏳ Loading rewarded ad...');
//
//     RewardedAd.load(
//       adUnitId: AdConfig.rewardedAdUnit,
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Rewarded ad loaded');
//           _rewardedAd = ad;
//           _isRewardedLoading = false;
//
//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdShowedFullScreenContent: (ad) {
//               debugPrint('📺 Rewarded ad showed');
//               AdConfig.logAdEvent('Rewarded_Showed');
//             },
//             onAdDismissedFullScreenContent: (ad) {
//               debugPrint('❌ Rewarded ad dismissed');
//               ad.dispose();
//               _rewardedAd = null;
//               _loadRewardedAd();
//               AdConfig.logAdEvent('Rewarded_Dismissed');
//             },
//             onAdFailedToShowFullScreenContent: (ad, error) {
//               debugPrint('❌ Rewarded ad failed to show: $error');
//               ad.dispose();
//               _rewardedAd = null;
//               _loadRewardedAd();
//               AdConfig.logAdEvent('Rewarded_ShowFailed', params: {'error': error.toString()});
//             },
//           );
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint('❌ Rewarded ad failed to load: $error');
//           _isRewardedLoading = false;
//           _rewardedAd = null;
//           AdConfig.logAdEvent('Rewarded_LoadFailed', params: {'error': error.toString()});
//
//           // Retry after delay
//           Future.delayed(const Duration(seconds: 10), () {
//             _loadRewardedAd();
//           });
//         },
//       ),
//     );
//   }
//
//   /// Show rewarded ad
//   Future<bool> showRewardedAd({
//     required String source,
//     required Function() onRewardEarned,
//   }) async {
//     if (!_isInitialized || !AdConfig.shouldShowAds()) {
//       debugPrint('⚠️ Ads disabled or not initialized');
//       return false;
//     }
//
//     if (_rewardedAd == null) {
//       debugPrint('⚠️ Rewarded ad not ready');
//       _loadRewardedAd();
//       return false;
//     }
//
//     bool rewardEarned = false;
//
//     try {
//       await _rewardedAd!.show(
//         onUserEarnedReward: (ad, reward) {
//           debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
//           rewardEarned = true;
//           onRewardEarned();
//           AdConfig.logAdEvent('Reward_Earned', params: {
//             'source': source,
//             'amount': reward.amount,
//             'type': reward.type,
//           });
//         },
//       );
//
//       return rewardEarned;
//     } catch (e) {
//       debugPrint('❌ Error showing rewarded ad: $e');
//       _rewardedAd?.dispose();
//       _rewardedAd = null;
//       _loadRewardedAd();
//       return false;
//     }
//   }
//
//   /// Check if rewarded ad is ready
//   bool get isRewardedAdReady => _rewardedAd != null;
//
//   // ─────────────────────────────────────────────────────────
//   //  🧹 CLEANUP
//   // ─────────────────────────────────────────────────────────
//
//   /// Dispose all ads
//   void dispose() {
//     _interstitialAd?.dispose();
//     _interstitialAd = null;
//
//     _rewardedAd?.dispose();
//     _rewardedAd = null;
//
//     debugPrint('🧹 Ad Manager disposed');
//   }
// }
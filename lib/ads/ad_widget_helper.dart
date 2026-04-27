// // ═══════════════════════════════════════════════════════════
// //  📱 AD WIDGET HELPER - Production Ready
// //  Reusable ad widgets for the entire app
// // ═══════════════════════════════════════════════════════════
//
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:ui';
// import 'ad_config.dart';
// import 'ad_manager.dart';
//
// // ═══════════════════════════════════════════════════════════
// //  📺 BANNER AD WIDGET
// // ═══════════════════════════════════════════════════════════
//
// class BannerAdWidget extends StatefulWidget {
//   final String placement;
//
//   const BannerAdWidget({
//     super.key,
//     required this.placement,
//   });
//
//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }
//
// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   BannerAd? _bannerAd;
//   bool _isLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }
//
//   void _loadAd() {
//     if (!AdConfig.shouldShowAds()) return;
//
//     final adUnitId = AdConfig.getBannerAdUnit(widget.placement);
//
//     _bannerAd = BannerAd(
//       adUnitId: adUnitId,
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Banner ad loaded for ${widget.placement}');
//           if (mounted) {
//             setState(() => _isLoaded = true);
//           }
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('❌ Banner ad failed to load: $error');
//           ad.dispose();
//           _bannerAd = null;
//         },
//       ),
//     );
//
//     _bannerAd!.load();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded || _bannerAd == null) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       width: double.infinity,
//       height: AdConfig.bannerHeight,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.white.withValues(alpha: 0.1),
//             Colors.white.withValues(alpha: 0.05),
//           ],
//         ),
//         border: Border(
//           top: BorderSide(
//             color: Colors.white.withValues(alpha: 0.1),
//             width: 1,
//           ),
//         ),
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Center(
//             child: AdWidget(ad: _bannerAd!),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════
// //  📰 NATIVE AD LIST TILE
// // ═══════════════════════════════════════════════════════════
//
// class NativeAdListTile extends StatefulWidget {
//   const NativeAdListTile({super.key});
//
//   @override
//   State<NativeAdListTile> createState() => _NativeAdListTileState();
// }
//
// class _NativeAdListTileState extends State<NativeAdListTile> {
//   NativeAd? _nativeAd;
//   bool _isLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }
//
//   void _loadAd() {
//     if (!AdConfig.shouldShowAds() || !AdConfig.enableNativeAds) return;
//
//     _nativeAd = NativeAd(
//       adUnitId: AdConfig.nativeAdUnit,
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Native ad loaded');
//           if (mounted) {
//             setState(() => _isLoaded = true);
//           }
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('❌ Native ad failed to load: $error');
//           ad.dispose();
//           _nativeAd = null;
//         },
//       ),
//       nativeTemplateStyle: NativeTemplateStyle(
//         templateType: TemplateType.medium,
//         mainBackgroundColor: Colors.white.withValues(alpha: 0.05),
//         cornerRadius: 12.0,
//         callToActionTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.white,
//           backgroundColor: const Color(0xFF667EEA),
//           style: NativeTemplateFontStyle.bold,
//           size: 14.0,
//         ),
//         primaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.white,
//           backgroundColor: Colors.transparent,
//           style: NativeTemplateFontStyle.bold,
//           size: 16.0,
//         ),
//         secondaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.white70,
//           backgroundColor: Colors.transparent,
//           style: NativeTemplateFontStyle.normal,
//           size: 14.0,
//         ),
//         tertiaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.white54,
//           backgroundColor: Colors.transparent,
//           style: NativeTemplateFontStyle.normal,
//           size: 12.0,
//         ),
//       ),
//     );
//
//     _nativeAd!.load();
//   }
//
//   @override
//   void dispose() {
//     _nativeAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded || _nativeAd == null) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       height: AdConfig.nativeAdHeight,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withValues(alpha: 0.15),
//                   Colors.white.withValues(alpha: 0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withValues(alpha: 0.2),
//                 width: 1.5,
//               ),
//             ),
//             child: AdWidget(ad: _nativeAd!),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════
// //  🎁 REWARDED AD HELPER
// // ═══════════════════════════════════════════════════════════
//
// class RewardedAdHelper {
//   /// Show rewarded ad offer dialog
//   static void showRewardedAdOffer({
//     required BuildContext context,
//     required String title,
//     required String description,
//     required String rewardText,
//     required Function() onRewardEarned,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black87,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(32),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 400),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withValues(alpha: 0.2),
//                     Colors.white.withValues(alpha: 0.1),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(32),
//                 border: Border.all(
//                   color: Colors.white.withValues(alpha: 0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Container(
//                     padding: const EdgeInsets.all(32),
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       ),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(32),
//                         topRight: Radius.circular(32),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.play_circle_filled_rounded,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Body
//                   Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       children: [
//                         Text(
//                           description,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             height: 1.6,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 onPressed: () async {
//                                   Navigator.pop(context);
//
//                                   // Show loading
//                                   showDialog(
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder: (context) => const Center(
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   );
//
//                                   // Wait a bit for dialog to show
//                                   await Future.delayed(
//                                     const Duration(milliseconds: 300),
//                                   );
//
//                                   // Show rewarded ad
//                                   final success = await AdManager().showRewardedAd(
//                                     source: 'premium_unlock',
//                                     onRewardEarned: onRewardEarned,
//                                   );
//
//                                   // Close loading
//                                   if (context.mounted) {
//                                     Navigator.pop(context);
//                                   }
//
//                                   // Show result
//                                   if (!success && context.mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           '⚠️ Ad abhi ready nahi hai, thodi der baad try karo',
//                                         ),
//                                         backgroundColor: Colors.orange,
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 icon: const Icon(
//                                   Icons.play_arrow_rounded,
//                                   size: 20,
//                                 ),
//                                 label: Text(rewardText),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: const Color(0xFF667EEA),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 14,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton(
//                               onPressed: () => Navigator.pop(context),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                 Colors.white.withValues(alpha: 0.1),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 14,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               child: const Icon(Icons.close_rounded),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
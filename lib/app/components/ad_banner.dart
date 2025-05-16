// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class BannerExampleState extends State<BannerExample> {
//   AdManagerBannerAd? _bannerAd;
//   bool _isLoaded = false;
//
//   // TODO: replace this test ad unit with your own ad unit.
//   final adUnitId = '/21775744923/example/adaptive-banner';
//
//
//   /// Loads a banner ad.
//   void loadAd() async {
//     // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
//     final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
//         MediaQuery.sizeOf(context).width.truncate());
//
//     _bannerAd = AdManagerBannerAd(
//       adUnitId: adUnitId,
//       request: const AdManagerAdRequest(),
//        listener: AdManagerBannerAdListener(
//         // Called when an ad is successfully received.
//         onAdLoaded: (ad) {
//           debugPrint('$ad loaded.');
//           setState(() {
//             _isLoaded = true;
//           });
//         },
//         // Called when an ad request failed.
//         onAdFailedToLoad: (ad, err) {
//           debugPrint('AdManagerBannerAd failed to load: $err');
//           // Dispose the ad here to free resources.
//           ad.dispose();
//         },
//         // Called when an ad opens an overlay that covers the screen.
//         onAdOpened: (Ad ad) {},
//         // Called when an ad removes an overlay that covers the screen.
//         onAdClosed: (Ad ad) {},
//         // Called when an impression occurs on the ad.
//         onAdImpression: (Ad ad) {},
//       ), sizes: [
//
//     ],
//     )..load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

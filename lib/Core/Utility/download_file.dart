// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
//
// class DownloadFile {
//   /// Opens the given [url] directly in Chrome (shows Chrome’s download option for PDFs).
//   static Future<void> openInBrowser(
//       String url, {
//         required BuildContext context,
//       }) async
//   {
//     try {
//       url = url.trim();
//
//       if (url.isEmpty) {
//         _showError('Empty download link');
//         return;
//       }
//
//       // Ensure proper protocol
//       if (!url.startsWith(RegExp(r'https?://'))) {
//         url = 'https://$url';
//       }
//
//       final Uri normalUri = Uri.parse(url);
//       bool launched = false;
//
//       if (Platform.isAndroid) {
//         // Try Chrome app scheme
//         final Uri chromeUri = Uri.parse("googlechrome://$url");
//         if (await canLaunchUrl(chromeUri)) {
//           launched = await launchUrl(chromeUri);
//         }
//       } else if (Platform.isIOS) {
//         // iOS Chrome uses 'googlechromes://' for HTTPS
//         final String chromeScheme =
//         url.startsWith('https') ? 'googlechromes://' : 'googlechrome://';
//         final String chromeUrl = url.replaceFirst(RegExp(r'^https?://'), '');
//         final Uri chromeUri = Uri.parse('$chromeScheme$chromeUrl');
//
//         if (await canLaunchUrl(chromeUri)) {
//           launched = await launchUrl(chromeUri);
//         }
//       }
//
//       // Fallback: open in default browser if Chrome unavailable
//       if (!launched) {
//         launched = await launchUrl(
//           normalUri,
//           mode: LaunchMode.externalApplication,
//         );
//       }
//
//       if (!launched) {
//         _showError('Could not open link in Chrome or browser');
//       }
//     } catch (e) {
//       _showError('Unexpected error: $e');
//     }
//   }
//
//   static void _showError(String message) {
//     Get.snackbar(
//       'Error',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red.shade600,
//       colorText: Colors.white,
//     );
//   }
// }
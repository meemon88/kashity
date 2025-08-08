import 'dart:developer';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:kashity/app/config.dart'; // your config with domain URL
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  late WebViewController webViewController;

  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;         // For connection errors (no internet)
  RxBool isConnect = true.obs;         // Internet connected status
  RxBool showErrorWidget = false.obs;  // For webpage errors (like 404)

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }

  void initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              isLoading.value = false;
              hasError.value = false;
            }
          },
          onPageStarted: (String url) {
            isLoading.value = true;
            hasError.value = false;
            showErrorWidget.value = false; // Hide error UI on new load
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
            hasError.value = true;

            if (error.description.contains('net::ERR_INTERNET_DISCONNECTED')) {
              isConnect.value = false;
              hasError.value = true;
              showErrorWidget.value = true;


            } else {
              // For other errors, show custom error UI replacing WebView
              showErrorWidget.value = true;
              hasError.value = false;
            }

            log('WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            String url = request.url;

            final externalSchemes = [
              "tg://",
              "mailto:",
              "tel:",
              "intent://",
              "whatsapp://",
            ];

            // Private Telegram invite link fix
            if (url.startsWith("https://t.me/+") || url.startsWith("t.me/+")) {
              final inviteCode = url.split("+").last;
              url = "tg://join?invite=$inviteCode";
            }

            if (externalSchemes.any((scheme) => url.startsWith(scheme)) || url.contains("t.me")) {
              try {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  print("Could not launch $url");
                }
              } catch (e) {
                print("Error launching $url: $e");
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(Config.domain));
  }

  void reload() {
    webViewController.reload();
    // hasError.value = false;
    showErrorWidget.value = false;
    isLoading.value = true;

  }

  void goBack() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
    }
  }

  void goForward() async {
    if (await webViewController.canGoForward()) {
      webViewController.goForward();
    }
  }

  void navigateToUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    webViewController.loadRequest(Uri.parse(url));
  }
}

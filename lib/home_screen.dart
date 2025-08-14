import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userType;
  final String userJson;

  const HomeScreen({
    super.key,
    required this.token,
    required this.userType,
    required this.userJson,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  InAppWebViewController? webViewController;
  bool isTokenInjected = false; // ✅ prevent double injection

  final List<String> _urls = [
    "https://nnhire.novanectar.in/candidate_dashboard",
    "https://nnhire.novanectar.in/candidate_dashboard",
    "https://nnhire.novanectar.in/candidate_dashboard/cand_helpcenter",
    "https://nnhire.novanectar.in/candidate_dashboard/cand_helpcenter",
  ];

  Widget _buildWebView(String url) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStop: (controller, uri) async {
        if (uri == null) return;

        String currentUrl = uri.toString();
        debugPrint("🌐 Current URL: $currentUrl");

        // ✅ Agar root ya login page open ho gaya to login screen pe bhej do
        if (currentUrl == "https://nnhire.novanectar.in/" ||
            currentUrl == "https://nnhire.novanectar.in/login" ||
            currentUrl.contains("/login")) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          return;
        }

        // ✅ Token inject sirf ek baar
        if (!isTokenInjected) {
          String safetoken = widget.token.replaceAll('"', '\\"');
          String safeUserType = widget.userType.replaceAll('"', '\\"');
          String safeUserJson = widget.userJson.replaceAll("'", "\\'");

          await controller.evaluateJavascript(
            source:
                '''
        localStorage.setItem("token", "$safetoken");
        localStorage.setItem("userType", "$safeUserType");
        localStorage.setItem("user", '$safeUserJson');
      ''',
          );

          debugPrint("💾 Token aur user data inject ho gaya");
          isTokenInjected = true;
        }
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          cacheEnabled: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWebView(_urls[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (webViewController != null) {
            webViewController!.loadUrl(
              urlRequest: URLRequest(url: WebUri(_urls[index])),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken_sharp),
            label: "saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

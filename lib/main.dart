import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart' as webview_android;

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Bottom navigation index provider
class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(NavIndexNotifier.new);

// WebView loading progress provider
class WebViewProgress extends Notifier<int> {
  @override
  int build() => 0;

  void setProgress(int progress) {
    state = progress;
  }
}

final webViewProgressProvider = NotifierProvider<WebViewProgress, int>(WebViewProgress.new);

// WebViewController provider
final webViewControllerProvider = Provider<WebViewController>((ref) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          ref.read(webViewProgressProvider.notifier).setProgress(progress);
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          ref.read(webViewProgressProvider.notifier).setProgress(100);
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) async {
          final uri = Uri.parse(request.url);
          // Handle payment and other external schemes
          if (!['http', 'https'].contains(uri.scheme)) {
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://alpha.bealls.com/login/'));

  // Enable Google Pay for Android
  if (controller.platform is webview_android.AndroidWebViewController) {
    (controller.platform as webview_android.AndroidWebViewController).setPaymentRequestEnabled(true);
  }

  return controller;
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final progress = ref.watch(webViewProgressProvider);

    final List<Widget> screens = [
      const WebViewContent(),
      const RewardsScreen(),
      const ProfileScreen(),
    ];

    final List<String> titles = [
      'Shop',
      'Rewards',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        bottom: (selectedIndex == 0 && progress < 100)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navIndexProvider.notifier).setIndex(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class WebViewContent extends ConsumerWidget {
  const WebViewContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(webViewControllerProvider);
    return WebViewWidget(controller: controller);
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 80, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('Your Rewards', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('User Profile', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

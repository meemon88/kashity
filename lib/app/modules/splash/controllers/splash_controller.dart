import 'package:get/get.dart';
import 'package:kashity/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    print('➡ SplashController: Navigating to home...');
    await Future.delayed(const Duration(seconds: 3));
    print('➡ Now redirecting to HOME...');
    Get.offAllNamed(Routes.HOME);
  }


  @override
  void onClose() {
    super.onClose();
    // Dispose resources if any
  }
}

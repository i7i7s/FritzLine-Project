import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_page_controller.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final controller = Get.find<LoginPageController>();

  late TextEditingController _emailC;
  late TextEditingController _passC;

  @override
  void initState() {
    super.initState();
    _emailC = TextEditingController();
    _passC = TextEditingController();
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 30),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const textSecondary = Color(0xFF333E63);

    return Column(
      children: [
        Image.asset('assets/images/logo.png', width: 120),
        const SizedBox(height: 16),
        const Text(
          "Selamat Datang Kembali",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Silakan login ke akun Anda",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildForm() {
    const primaryColor = Color(0xFF656CEE);
    const fillColorEmail = Color(0xFFEFF3FF);
    const fillColorPassword = Color(0xFFFFF1F1);

    return Column(
      children: [
        TextField(
          controller: _emailC,
          decoration: _buildInputDecoration(
            "Email",
            Icons.email_outlined,
            fillColor: fillColorEmail,
            focusColor: primaryColor,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passC,
          decoration: _buildInputDecoration(
            "Password",
            Icons.lock_outline,
            fillColor: fillColorPassword,
            focusColor: primaryColor,
          ),
          obscureText: true,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    Color? fillColor,
    Color? focusColor,
  }) {
    const primaryColor = Color(0xFF656CEE);

    final Color effectiveFill = fillColor ?? Colors.white70;
    final Color effectiveFocus = focusColor ?? primaryColor;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: effectiveFocus),
      filled: true,
      fillColor: effectiveFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveFocus, width: 2),
      ),
    );
  }

  Widget _buildLoginButton() {
    const primaryColor = Color(0xFF656CEE);

    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.login(_emailC.text, _passC.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    const primaryColor = Color(0xFF656CEE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun?"),
        TextButton(
          onPressed: () => controller.goToRegister(),
          child: const Text(
            "Daftar di sini",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

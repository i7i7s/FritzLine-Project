import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final controller = Get.find<RegisterController>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildBackground(), _buildBody(context)]),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
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
              _buildRegisterButton(),
              const SizedBox(height: 20),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', width: 120),
        const SizedBox(height: 16),
        const Text(
          "Buat Akun Baru",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333E63),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Silakan isi data diri Anda",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: _buildInputDecoration(
            "Nama Lengkap",
            Icons.person_outline,
            fillColor: const Color(0xFFEFFAF4),
            focusColor: const Color(0xFF656CEE),
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: _buildInputDecoration(
            "Email",
            Icons.email_outlined,
            fillColor: const Color(0xFFEFF3FF),
            focusColor: const Color(0xFF656CEE),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: _buildInputDecoration(
            "Password",
            Icons.lock_outline,
            fillColor: const Color(0xFFFFF1F1),
            focusColor: const Color(0xFF656CEE),
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
    final Color effectiveFill = fillColor ?? Colors.white70;
    final Color effectiveFocus = focusColor ?? const Color(0xFF656CEE);

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

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.processRegister(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF656CEE),
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
                  "DAFTAR",
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

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Sudah punya akun?"),
        TextButton(
          onPressed: () => controller.goToLogin(),
          child: const Text(
            "Login di sini",
            style: TextStyle(
              color: Color(0xFF656CEE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

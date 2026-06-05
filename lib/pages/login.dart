import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jejaksehat_mobile/pages/splash.dart'; // Dibutuhkan untuk mengambil gambar

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String baseUrl = "https://ilham.pplg1.my.id";

  // --- CONTROLLER KHUSUS TAB LOGIN ---
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // --- CONTROLLER KHUSUS TAB SIGN UP ---
  final TextEditingController _signUpUsernameController =
      TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  final TextEditingController _signUpConfirmPasswordController =
      TextEditingController();

  bool isLoginSelected = true;

  // --- STATE UNTUK GAMBAR PROFIL ---
  Uint8List? _profileImageBytes;
  String? _profileImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpUsernameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI MENGAMBIL GAMBAR DARI GALERI ---
  Future<void> _pickImage() async {
    // Meminta image_picker untuk membuka galeri
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = imageBytes;
        _profileImageName = pickedFile.name;
      });
    }
  }

  Future<void> _handleLogin() async {
    final nama = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (nama.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nama': nama, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['error'] ?? 'Login gagal')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleRegister() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/register'),
      );

      request.fields['nik'] = _signUpUsernameController.text.trim();

      request.fields['nama'] = _signUpEmailController.text.trim();

      request.fields['password'] = _signUpPasswordController.text.trim();

      if (_profileImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profil',
            _profileImageBytes!,
            filename: _profileImageName ?? 'profile.jpg',
          ),
        );
      }

      final response = await request.send();

      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));

        print(body);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // --- WIDGET FORM LOGIN ---
  Widget _buildLoginForm(Color inputLineColor) {
    return Column(
      key: const ValueKey('login_form'),
      children: [
        _buildTextField(
          controller: _loginEmailController,
          hintText: 'Username',
          lineColor: inputLineColor,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _loginPasswordController,
          hintText: 'Password',
          isObscure: true,
          lineColor: inputLineColor,
        ),
      ],
    );
  }

  // --- WIDGET FORM SIGN UP (DENGAN INPUT GAMBAR) ---
  Widget _buildSignUpForm(Color inputLineColor) {
    return Column(
      key: const ValueKey('signup_form'),
      children: [
        // --- WIDGET FOTO PROFIL ---
        GestureDetector(
          onTap: _pickImage, // Panggil fungsi saat ditekan
          child: Stack(
            children: [
              // Lingkaran Dasar
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white24,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : null,
                child: _profileImageBytes == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white54)
                    : null,
              ),
              // Ikon Kamera Kecil di Pojok Kanan Bawah
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFCC29), // Warna kuning dari tema
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30), // Jarak antara foto dan input text
        // --- TEXT FIELDS ---
        _buildTextField(
          controller: _signUpUsernameController,
          hintText: 'NIK',
          lineColor: inputLineColor,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _signUpEmailController,
          hintText: 'Username',
          lineColor: inputLineColor,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _signUpPasswordController,
          hintText: 'Password',
          isObscure: true,
          lineColor: inputLineColor,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFCC29);
    const Color darkBackground = Color(0xFF272D37);
    const Color inputLineColor = Colors.white54;

    return Scaffold(
      backgroundColor: primaryYellow,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- BAGIAN ATAS: LOGO ---
            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: double.infinity,
              color: primaryYellow,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    height: 120, // Diperbesar sesuai pembaruan sebelumnya
                  ),
                ],
              ),
            ),

            // --- BAGIAN BAWAH: FORM INPUT ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: darkBackground,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // --- TOGGLE BUTTON (SLIDING ANIMATION) ---
                      Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: [
                            // Background Kuning yang bergerak
                            AnimatedAlign(
                              alignment: isLoginSelected
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                heightFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryYellow,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            // Area Tap dan Teks
                            Row(
                              children: [
                                // Tombol Login
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isLoginSelected = true;
                                      });
                                    },
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        style: TextStyle(
                                          color: isLoginSelected
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: const Text('Login'),
                                      ),
                                    ),
                                  ),
                                ),
                                // Tombol Sign Up
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isLoginSelected = false;
                                      });
                                    },
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        style: TextStyle(
                                          color: !isLoginSelected
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: const Text('Sign Up'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- FORM DENGAN TRANSISI CROSS FADE ---
                      AnimatedCrossFade(
                        firstChild: _buildLoginForm(inputLineColor),
                        secondChild: _buildSignUpForm(inputLineColor),
                        crossFadeState: isLoginSelected
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                        sizeCurve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                      ),

                      const SizedBox(height: 50),

                      // --- TOMBOL AKSI UTAMA ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLoginSelected) {
                              _handleLogin();
                            } else {
                              _handleRegister();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              isLoginSelected ? 'Login' : 'Sign Up',
                              key: ValueKey<bool>(isLoginSelected),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    required Color lineColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lineColor, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

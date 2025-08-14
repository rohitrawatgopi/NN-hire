import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isLoading = false;

  final dio = Dio();

  Future<void> sendOtp() async {
    if (emailController.text.isEmpty || !_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid email first")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await dio.post(
        "https://api.nnhire.novanectar.in/api/send-otp",
        data: {"email": emailController.text},
      );
      if (res.statusCode == 200) {
        setState(() => isOtpSent = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP sent to your email")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter OTP")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await dio.post(
        "https://api.nnhire.novanectar.in/api/verify-otp",
        data: {"email": emailController.text, "otp": otpController.text},
      );
      if (res.statusCode == 200) {
        setState(() => isOtpVerified = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP Verified")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isOtpVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verify OTP first")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await dio.put(
        "https://api.nnhire.novanectar.in/api/auth/signup",
        data: {
          "firstname": firstNameController.text,
          "lastname": lastNameController.text,
          "phoneno": phoneController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "userType": "candidate",
        },
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Signup Successful")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name *",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name *",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone No"),
                keyboardType: TextInputType.phone,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email Address *",
                      ),
                      validator: (v) =>
                          _isValidEmail(v ?? "") ? null : "Enter valid email",
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : sendOtp,
                    child: const Text("Send OTP"),
                  ),
                ],
              ),
              if (isOtpSent)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: otpController,
                        decoration: const InputDecoration(
                          labelText: "Enter OTP",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isLoading ? null : verifyOtp,
                      child: const Text("Verify"),
                    ),
                  ],
                ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password *"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: "Confirm Password *",
                ),
                obscureText: true,
                validator: (v) => v != passwordController.text
                    ? "Passwords do not match"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : signUp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

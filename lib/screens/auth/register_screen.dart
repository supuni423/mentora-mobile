import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

/// Three steps mirroring the backend exactly: verify email with an OTP
/// before the registration endpoint will accept it.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _goToOtpStep() => setState(() => _step = 1);
  void _goToFormStep() => setState(() => _step = 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Verify Email', 'Enter Code', 'Create Account'][_step]),
      ),
      body: SafeArea(
        child: switch (_step) {
          0 => _EmailStep(email: _email, onSent: _goToOtpStep),
          1 => _OtpStep(email: _email.text.trim(), onVerified: _goToFormStep),
          _ => _DetailsStep(email: _email.text.trim()),
        },
      ),
    );
  }
}

class _EmailStep extends StatefulWidget {
  const _EmailStep({required this.email, required this.onSent});

  final TextEditingController email;
  final VoidCallback onSent;

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendVerification(widget.email.text.trim());
    if (ok) {
      widget.onSent();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not send code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('We\'ll send a verification code to your email.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: Validators.email,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Send Code',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({required this.email, required this.onVerified});

  final String email;
  final VoidCallback onVerified;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyEmail(
      email: widget.email,
      otp: _otp.text.trim(),
    );
    if (ok) {
      widget.onVerified();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Invalid or expired code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter the 6-digit code sent to ${widget.email}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Verification code'),
              validator: Validators.otp,
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Verify',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsStep extends StatefulWidget {
  const _DetailsStep({required this.email});

  final String email;

  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _school = TextEditingController();
  final _age = TextEditingController();
  final _language = TextEditingController();
  final _gradeLevel = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _fullName.dispose();
    _school.dispose();
    _age.dispose();
    _language.dispose();
    _gradeLevel.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerStudent(
      email: widget.email,
      password: _password.text,
      fullName: _fullName.text.trim(),
      school: _school.text.trim(),
      age: int.parse(_age.text.trim()),
      language: _language.text.trim(),
      gradeLevel: _gradeLevel.text.trim(),
      address: _address.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullName,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => Validators.required(v, label: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _school,
              decoration: const InputDecoration(labelText: 'School'),
              validator: (v) => Validators.required(v, label: 'School'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: Validators.age,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _language,
              decoration: const InputDecoration(
                labelText: 'Preferred language',
              ),
              validator: (v) => Validators.required(v, label: 'Language'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gradeLevel,
              decoration: const InputDecoration(labelText: 'Grade level'),
              validator: (v) => Validators.required(v, label: 'Grade level'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (v) => Validators.required(v, label: 'Address'),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create Account',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

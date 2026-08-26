import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _school;
  late final TextEditingController _grade;
  late final TextEditingController _bio;
  late final TextEditingController _address;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: profile?.name ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
    _school = TextEditingController(text: profile?.school ?? '');
    _grade = TextEditingController(text: profile?.grade ?? '');
    _bio = TextEditingController(text: profile?.bio ?? '');
    _address = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _school.dispose();
    _grade.dispose();
    _bio.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProfileProvider>();
    final ok = await provider.save(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      school: _school.text.trim(),
      grade: _grade.text.trim(),
      bio: _bio.text.trim(),
      address: _address.text.trim(),
      profilePicture: _pickedImage,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.saveError ?? 'Could not save profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;
    final currentPicture = context
        .read<ProfileProvider>()
        .profile
        ?.profilePicture;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (currentPicture != null
                                    ? NetworkImage(currentPicture)
                                    : null)
                                as ImageProvider?,
                      child: _pickedImage == null && currentPicture == null
                          ? const Icon(Icons.camera_alt_outlined, size: 32)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => Validators.required(v, label: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _school,
                  decoration: const InputDecoration(labelText: 'School'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _grade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bio,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save',
                  isLoading: isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

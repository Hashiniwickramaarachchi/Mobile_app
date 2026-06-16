import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../utils/constants.dart';
import '../widgets/input_field.dart';
import '../widgets/reusable_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.onBack,
    required this.onOpenSettings,
  });

  final Profile profile;
  final ValueChanged<Profile> onSaveProfile;
  final VoidCallback onBack;
  final VoidCallback onOpenSettings;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _guardian;
  late final TextEditingController _elderly;
  late final TextEditingController _age;
  late final TextEditingController _disabilities;

  @override
  void initState() {
    super.initState();
    _guardian = TextEditingController(text: widget.profile.guardianName);
    _elderly = TextEditingController(text: widget.profile.elderlyName);
    _age = TextEditingController(text: widget.profile.age);
    _disabilities = TextEditingController(text: widget.profile.disabilities);
  }

  @override
  void dispose() {
    _guardian.dispose();
    _elderly.dispose();
    _age.dispose();
    _disabilities.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton.outlined(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Row(
          children: [
            Expanded(
                child: Text('Profile',
                    style: Theme.of(context).textTheme.titleLarge)),
            _isEditing
                ? TextButton(onPressed: _save, child: const Text('Save'))
                : IconButton.outlined(
                    tooltip: 'Edit profile',
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_rounded),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Guardian',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _isEditing
                  ? InputField(controller: _guardian)
                  : Text(widget.profile.guardianName),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elderly',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                InputField(controller: _elderly),
                const SizedBox(height: 8),
                InputField(
                    controller: _age, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                InputField(controller: _disabilities),
              ] else ...[
                Text(widget.profile.elderlyName),
                const SizedBox(height: 4),
                Text('Age: ${widget.profile.age}'),
                const SizedBox(height: 4),
                Text(widget.profile.disabilities),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Emergency Contacts',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final contact in widget.profile.emergencyContacts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${contact.name} - ${contact.phone}'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ReusableButton(
            label: 'Open Settings', onPressed: widget.onOpenSettings),
      ],
    );
  }

  void _save() {
    widget.onSaveProfile(
      widget.profile.copyWith(
        guardianName: _guardian.text.trim(),
        elderlyName: _elderly.text.trim(),
        age: _age.text.trim(),
        disabilities: _disabilities.text.trim(),
      ),
    );
    setState(() => _isEditing = false);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

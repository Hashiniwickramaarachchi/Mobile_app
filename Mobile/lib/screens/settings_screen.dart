import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../models/profile.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/input_field.dart';
import '../widgets/reusable_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.profile,
    required this.notifications,
    required this.onBack,
    required this.onToggleNotification,
    required this.onSignOut,
    required this.onSaveProfile,
  });

  final Profile profile;
  final Map<String, bool> notifications;
  final VoidCallback onBack;
  final ValueChanged<String> onToggleNotification;
  final VoidCallback onSignOut;
  final ValueChanged<Profile> onSaveProfile;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditingProfile = false;
  bool _showAddContactForm = false;
  String? _editingContactId;

  late final TextEditingController _guardian;
  late final TextEditingController _elderly;
  late final TextEditingController _age;
  late final TextEditingController _disabilities;
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactRelationship = TextEditingController();
  final _editName = TextEditingController();
  final _editPhone = TextEditingController();
  final _editRelationship = TextEditingController();

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
    _contactName.dispose();
    _contactPhone.dispose();
    _contactRelationship.dispose();
    _editName.dispose();
    _editPhone.dispose();
    _editRelationship.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddMoreContact = widget.profile.emergencyContacts.length < 3;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.bottomNavHeight + 20,
      ),
      children: [
        Row(
          children: [
            IconButton.outlined(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Settings',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                      child: Text('Elderly Profile',
                          style: TextStyle(fontWeight: FontWeight.w800))),
                  _isEditingProfile
                      ? TextButton(
                          onPressed: _saveProfile, child: const Text('Save'))
                      : IconButton.outlined(
                          tooltip: 'Edit elderly profile',
                          onPressed: () =>
                              setState(() => _isEditingProfile = true),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEditingProfile) ...[
                InputField(controller: _guardian, hint: 'Guardian Name'),
                const SizedBox(height: 8),
                InputField(controller: _elderly, hint: 'Elderly Person Name'),
                const SizedBox(height: 8),
                InputField(
                    controller: _age,
                    hint: 'Age',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                InputField(controller: _disabilities, hint: 'Disabilities'),
              ] else ...[
                Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: 'Guardian: ',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: widget.profile.guardianName),
                ])),
                const SizedBox(height: 4),
                Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: 'Elderly: ',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(
                      text:
                          '${widget.profile.elderlyName} (Age ${widget.profile.age})'),
                ])),
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
              Row(
                children: [
                  const Expanded(
                      child: Text('Emergency Contacts',
                          style: TextStyle(fontWeight: FontWeight.w800))),
                  if (canAddMoreContact)
                    TextButton(
                      onPressed: () => setState(
                          () => _showAddContactForm = !_showAddContactForm),
                      child: Text(_showAddContactForm ? 'Cancel' : '+ Add'),
                    )
                  else
                    const Text('Max 3 contacts',
                        style: TextStyle(color: AppColors.muted)),
                ],
              ),
              for (final contact in widget.profile.emergencyContacts)
                _ContactRow(
                  contact: contact,
                  editing: _editingContactId == contact.id,
                  editName: _editName,
                  editPhone: _editPhone,
                  editRelationship: _editRelationship,
                  onStartEdit: () => _startEditContact(contact),
                  onSaveEdit: _saveEditContact,
                  onDelete: () => _deleteContact(contact.id),
                ),
              if (canAddMoreContact && _showAddContactForm) ...[
                const SizedBox(height: 10),
                InputField(controller: _contactName, hint: 'New contact name'),
                const SizedBox(height: 8),
                InputField(
                    controller: _contactPhone,
                    hint: 'New contact phone',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                InputField(
                    controller: _contactRelationship,
                    hint: 'Relationship (optional)'),
                const SizedBox(height: 10),
                ReusableButton(label: 'Add Contact', onPressed: _addContact),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final entry in widget.notifications.entries)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: entry.value,
                  title: Text(labelize(entry.key)),
                  onChanged: (_) => widget.onToggleNotification(entry.key),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ReusableButton(
          label: 'Sign Out',
          variant: ButtonVariant.danger,
          onPressed: widget.onSignOut,
        ),
      ],
    );
  }

  void _saveProfile() {
    widget.onSaveProfile(
      widget.profile.copyWith(
        guardianName: _guardian.text.trim(),
        elderlyName: _elderly.text.trim(),
        age: _age.text.trim(),
        disabilities: _disabilities.text.trim(),
      ),
    );
    setState(() => _isEditingProfile = false);
  }

  void _addContact() {
    if (_contactName.text.trim().isEmpty || _contactPhone.text.trim().isEmpty) {
      return;
    }

    widget.onSaveProfile(
      widget.profile.copyWith(
        emergencyContacts: [
          ...widget.profile.emergencyContacts,
          Contact(
            id: 'c${DateTime.now().millisecondsSinceEpoch}',
            name: _contactName.text.trim(),
            phone: _contactPhone.text.trim(),
            relationship: _contactRelationship.text.trim().isEmpty
                ? 'Contact'
                : _contactRelationship.text.trim(),
          ),
        ],
      ),
    );

    _contactName.clear();
    _contactPhone.clear();
    _contactRelationship.clear();
    setState(() => _showAddContactForm = false);
  }

  void _deleteContact(String id) {
    widget.onSaveProfile(
      widget.profile.copyWith(
        emergencyContacts: widget.profile.emergencyContacts
            .where((contact) => contact.id != id)
            .toList(),
      ),
    );
  }

  void _startEditContact(Contact contact) {
    setState(() {
      _editingContactId = contact.id;
      _editName.text = contact.name;
      _editPhone.text = contact.phone;
      _editRelationship.text = contact.relationship;
    });
  }

  void _saveEditContact() {
    final id = _editingContactId;
    if (id == null) {
      return;
    }

    widget.onSaveProfile(
      widget.profile.copyWith(
        emergencyContacts: widget.profile.emergencyContacts.map((contact) {
          if (contact.id != id) {
            return contact;
          }
          return contact.copyWith(
            name: _editName.text.trim(),
            phone: _editPhone.text.trim(),
            relationship: _editRelationship.text.trim(),
          );
        }).toList(),
      ),
    );

    setState(() => _editingContactId = null);
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.editing,
    required this.editName,
    required this.editPhone,
    required this.editRelationship,
    required this.onStartEdit,
    required this.onSaveEdit,
    required this.onDelete,
  });

  final Contact contact;
  final bool editing;
  final TextEditingController editName;
  final TextEditingController editPhone;
  final TextEditingController editRelationship;
  final VoidCallback onStartEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: editing
                ? Column(
                    children: [
                      InputField(controller: editName),
                      const SizedBox(height: 8),
                      InputField(
                          controller: editPhone,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 8),
                      InputField(controller: editRelationship),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        '${contact.relationship} - ${contact.phone}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              editing
                  ? TextButton(onPressed: onSaveEdit, child: const Text('Save'))
                  : IconButton.outlined(
                      tooltip: 'Edit',
                      onPressed: onStartEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                    ),
              IconButton.outlined(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded,
                    color: AppColors.danger, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
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

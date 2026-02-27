import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  final _nameController = TextEditingController(text: 'Ramesh Patil');
  double _age = 42;
  final String _location = 'Nagpur, Maharashtra';
  final String _soilType = 'Black (काली)';
  String _language = 'Hindi';
  final List<String> _crops = ['Tomato', 'Onion', 'Wheat'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_editing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile saved ✅'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
              setState(() => _editing = !_editing);
            },
            icon: Icon(
              _editing ? Icons.check : Icons.edit,
              size: 18,
              color: AgriChainTheme.primaryGreen,
            ),
            label: Text(
              _editing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: AgriChainTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👨‍🌾', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Name ──
            _buildField(
              icon: Icons.person,
              label: 'Name',
              child: _editing
                  ? TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    )
                  : Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),

            // ── Age ──
            _buildField(
              icon: Icons.cake,
              label: 'Age',
              child: _editing
                  ? Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _age,
                            min: 18,
                            max: 80,
                            divisions: 62,
                            activeColor: AgriChainTheme.primaryGreen,
                            label: _age.round().toString(),
                            onChanged: (v) => setState(() => _age = v),
                          ),
                        ),
                        Text(
                          '${_age.round()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '${_age.round()} years',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),

            // ── Location ──
            _buildField(
              icon: Icons.location_on,
              label: 'Location',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _location,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_editing)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change 📍',
                        style: TextStyle(color: AgriChainTheme.primaryGreen),
                      ),
                    ),
                ],
              ),
            ),

            // ── Soil type ──
            _buildField(
              icon: Icons.terrain,
              label: 'Soil Type',
              child: Text(_soilType, style: const TextStyle(fontSize: 16)),
            ),

            // ── Language ──
            _buildField(
              icon: Icons.translate,
              label: 'Language',
              child: _editing
                  ? DropdownButton<String>(
                      value: _language,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: ['English', 'Hindi', 'Marathi', 'Gujarati']
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _language = v ?? _language),
                    )
                  : Text(_language, style: const TextStyle(fontSize: 16)),
            ),

            // ── My Crops ──
            _buildField(
              icon: Icons.eco,
              label: 'My Crops',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._crops.map(
                    (c) => Chip(
                      label: Text(c),
                      backgroundColor: AgriChainTheme.primaryGreen.withValues(
                        alpha: 0.1,
                      ),
                      deleteIcon: _editing
                          ? const Icon(Icons.close, size: 16)
                          : null,
                      onDeleted: _editing
                          ? () => setState(() => _crops.remove(c))
                          : null,
                    ),
                  ),
                  if (_editing)
                    ActionChip(
                      label: const Text('+ Add'),
                      onPressed: () {},
                      backgroundColor: Colors.grey.shade100,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Save button (only in edit mode) ──
            if (_editing)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _editing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profile saved ✅'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 22),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ── Logout button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    final storage = ref.read(storageServiceProvider);
                    await storage.clearAll();
                    if (mounted) context.go('/auth');
                  }
                },
                icon: const Icon(Icons.logout, size: 22, color: Colors.red),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AgriChainTheme.greyText),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AgriChainTheme.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.only(left: 24), child: child),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

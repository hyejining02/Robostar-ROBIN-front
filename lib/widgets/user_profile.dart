import 'package:flutter/material.dart';

import '../models/access_control.dart';
import 'robin_dialog.dart';

class RobinUserProfile {
  final String name;
  final String department;
  final String rank;
  final String email;
  final String phone;
  final String username;
  final RobinAccountRole role;
  final RobinDepartmentPermission departmentPermission;

  const RobinUserProfile({
    required this.name,
    required this.department,
    required this.rank,
    required this.email,
    required this.phone,
    required this.username,
    required this.role,
    required this.departmentPermission,
  });

  bool get isAdmin => role == RobinAccountRole.admin;
  bool get isDealer => role == RobinAccountRole.dealer;
}

final robinUserProfile = ValueNotifier<RobinUserProfile>(
  const RobinUserProfile(
    name: '김로빈',
    department: '인사/지원실',
    rank: '책임',
    email: 'robin.kim@robostar.com',
    phone: '010-1234-5678',
    username: 'admin',
    role: RobinAccountRole.admin,
    departmentPermission: RobinDepartmentPermission.hr,
  ),
);

void activateRobinAccount(String username, {String? role}) {
  RobinEmployee? account;
  for (final employee in robinEmployees.value) {
    if (employee.id == username) {
      account = employee;
      break;
    }
  }

  final requestedRole = RobinAccountRole.fromApi(role);
  account ??= robinEmployees.value.firstWhere(
    (employee) => employee.role == requestedRole,
    orElse: () => robinEmployees.value.first,
  );
  robinUserProfile.value = RobinUserProfile(
    name: account.name,
    department: account.department,
    rank: account.rank,
    email: account.email,
    phone: account.phone,
    username: account.id,
    role: account.role,
    departmentPermission: account.departmentPermission,
  );
}

Future<void> showRobinProfileEditor(BuildContext context) async {
  final updated = await showDialog<RobinUserProfile>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProfileEditorDialog(profile: robinUserProfile.value),
  );
  if (updated != null) robinUserProfile.value = updated;
}

class _ProfileEditorDialog extends StatefulWidget {
  final RobinUserProfile profile;
  const _ProfileEditorDialog({required this.profile});

  @override
  State<_ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<_ProfileEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rankController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String _department;

  static const _departments = [
    '인사/지원실',
    '영업',
    '기술',
    '제조',
    '대리점',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _rankController = TextEditingController(text: widget.profile.rank);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _department = widget.profile.department;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rankController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
        title: const Text('내 정보 수정'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field(_nameController, '이름'),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    initialValue: _department,
                    decoration: const InputDecoration(
                      labelText: '부서',
                      border: OutlineInputBorder(),
                    ),
                    items: _departments
                        .map((department) => DropdownMenuItem(
                              value: department,
                              child: Text(department),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _department = value);
                    },
                  ),
                  const SizedBox(height: 13),
                  _field(_rankController, '직급'),
                  const SizedBox(height: 13),
                  _field(_emailController, '이메일', email: true),
                  const SizedBox(height: 13),
                  _field(_phoneController, '연락처'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: _save,
            child: const Text('저장'),
          ),
        ],
      );

  Widget _field(TextEditingController controller, String label,
      {bool email = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return '$label 항목을 입력해주세요.';
        if (email && !text.contains('@')) return '올바른 이메일을 입력해주세요.';
        return null;
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      RobinUserProfile(
        name: _nameController.text.trim(),
        department: _department,
        rank: _rankController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        username: widget.profile.username,
        role: widget.profile.role,
        departmentPermission: widget.profile.departmentPermission,
      ),
    );
  }
}

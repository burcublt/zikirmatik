import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

/// [editZikr] null ise yeni zikir ekleme, değilse düzenleme modu.
Future<void> showZikrFormSheet(
  BuildContext context, {
  ZikrDefinition? editZikr,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ZikrFormSheet(editZikr: editZikr),
  );
}

class _ZikrFormSheet extends ConsumerStatefulWidget {
  const _ZikrFormSheet({this.editZikr});

  final ZikrDefinition? editZikr;

  @override
  ConsumerState<_ZikrFormSheet> createState() => _ZikrFormSheetState();
}

class _ZikrFormSheetState extends ConsumerState<_ZikrFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  bool get _isEdit => widget.editZikr != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.editZikr?.title ?? '');
    _targetCtrl = TextEditingController(
      text: widget.editZikr?.defaultTarget.toString() ?? '33',
    );
    _descCtrl = TextEditingController(text: widget.editZikr?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(zikrsNotifierProvider.notifier);
      final target = int.parse(_targetCtrl.text.trim());
      final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

      if (_isEdit) {
        await notifier.editZikr(
          existing: widget.editZikr!,
          title: _nameCtrl.text,
          defaultTarget: target,
          description: desc,
        );
      } else {
        await notifier.add(
          title: _nameCtrl.text,
          defaultTarget: target,
          description: desc,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorSave),
            backgroundColor: context.palette.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: mq.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Başlık
            Text(
              _isEdit ? l10n.editZikrTitle : l10n.addZikrTitle,
              style: TextStyle(
                color: context.palette.cream,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),

            // Zikir adı
            _buildLabel(l10n.zikrName),
            SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: context.palette.cream),
              decoration: _inputDecoration(l10n.zikrNameHint),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            SizedBox(height: 16),

            // Hedef sayı
            _buildLabel(l10n.target),
            SizedBox(height: 6),
            TextFormField(
              controller: _targetCtrl,
              style: TextStyle(color: context.palette.cream),
              decoration: _inputDecoration(l10n.targetHint),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return l10n.invalidTarget;
                return null;
              },
            ),
            SizedBox(height: 16),

            // Açıklama (isteğe bağlı)
            _buildLabel(l10n.description),
            SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              style: TextStyle(color: context.palette.cream),
              decoration: _inputDecoration(l10n.descriptionHint),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 28),

            // Kaydet butonu
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: context.palette.gold,
                foregroundColor: context.palette.deepGreen,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: _saving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.deepGreen,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: context.palette.mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.palette.outline),
      filled: true,
      fillColor: context.palette.elevatedGreen,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.palette.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.palette.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.palette.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.palette.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.palette.error, width: 1.5),
      ),
      errorStyle: TextStyle(color: context.palette.error, fontSize: 12),
    );
  }
}

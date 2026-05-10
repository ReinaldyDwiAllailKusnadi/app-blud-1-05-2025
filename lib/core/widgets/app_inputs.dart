import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    String? hintText,
    String? hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.enabled = true,
  }) : hintText = hintText ?? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.navBlue, size: 22) : null,
            filled: true,
            fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.navBlue, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final IconData icon;
  final String? Function(String?)? validator;
  final String? hint;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: hint != null ? Text(hint!, style: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400)) : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.navBlue, size: 22),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.navBlue, width: 2),
            ),
          ),
          selectedItemBuilder: (context) {
            return items.map((String item) {
              return Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }).toList();
          },
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, overflow: TextOverflow.ellipsis)
          )).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final IconData icon;

  const AppDateField({
    super.key,
    required this.label,
    DateTime? date,
    required this.onTap,
    this.icon = Icons.calendar_month_rounded,
    DateTime? value,
  }) : date = date ?? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.navBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd/MM/yyyy').format(date!) : 'Pilih Tanggal',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date != null ? AppTheme.textPrimary : AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

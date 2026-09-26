import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class AppBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final bool hasLeading;
  final VoidCallback? onLeadingTap;
  final List<Widget>? actions;
  final double titleSpacing;
  final double titleFontSize;
  final FontWeight titleFontWeight;

  const AppBackAppBar({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.hasLeading = true,
    this.onLeadingTap,
    this.actions,
    this.titleSpacing = 0,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.w800,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: titleSpacing,
      leading: hasLeading
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: AppColors.textPrimary,
              ),
              onPressed: onLeadingTap ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: titleFontSize,
          fontWeight: titleFontWeight,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions,
    );
  }
}

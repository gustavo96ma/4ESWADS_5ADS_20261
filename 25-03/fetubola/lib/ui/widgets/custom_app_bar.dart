import 'package:fetubola/utils/app_style.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppStyle.appBarTitleStyle),
      backgroundColor: AppStyle.primaryColor,
      iconTheme: AppStyle.appBarIconTheme,
    );
  }
}

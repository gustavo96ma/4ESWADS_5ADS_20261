import 'package:fetubola/providers/news_provider.dart';
import 'package:fetubola/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: searchController,
            cursorColor: AppStyle.primaryColor,
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                context.read<NewsProvider>().updateSearch(
                  searchController.text,
                );
              },

              icon: const Icon(Icons.search),
              color: AppStyle.onPrimaryColor,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppStyle.primaryColor),
                minimumSize: WidgetStatePropertyAll(const Size(40, 40)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

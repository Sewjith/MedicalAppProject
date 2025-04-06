import 'package:flutter/material.dart';

class SearchbarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchbarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return  SearchBar(
      controller: controller,
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      shadowColor: const WidgetStatePropertyAll(Colors.black),
      elevation: const WidgetStatePropertyAll(10),
      leading: const Icon(Icons.search),
      hintText: "Search for Doctor",
      onChanged: onChanged,
      trailing: [
        IconButton(
          onPressed: () {
            controller.clear();
            onChanged(""); // Notify that text is cleared
          },
          icon: const Icon(Icons.clear),
        ),
      ],
    );
  }
}

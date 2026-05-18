import 'package:flutter/material.dart';

class PageApplication1 extends StatefulWidget {
  const PageApplication1({super.key, required this.title});
  final String title;

  @override
  State<PageApplication1> createState() => _PageApplication1State();
}

class _PageApplication1State extends State<PageApplication1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text("Ch'ti Face Bouc"),
      ),
    );
  }
}

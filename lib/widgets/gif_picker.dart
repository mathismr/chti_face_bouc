import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _tenorApiKey = 'AIzaSyAyimkuYQYF_FXVALexPuGQctUWRURdCYQ';
const _tenorClientKey = 'chti_face_bouc';

class GifPicker extends StatefulWidget {
  const GifPicker({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) =>
            _GifPickerContent(scrollController: controller),
      ),
    );
  }

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _GifPickerContent extends StatefulWidget {
  final ScrollController scrollController;
  const _GifPickerContent({required this.scrollController});

  @override
  State<_GifPickerContent> createState() => _GifPickerContentState();
}

class _GifPickerContentState extends State<_GifPickerContent> {
  final _searchController = TextEditingController();
  List<_GifItem> _gifs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() => _loading = true);
    final url = Uri.parse(
        'https://tenor.googleapis.com/v2/featured'
        '?key=$_tenorApiKey&client_key=$_tenorClientKey&limit=30&locale=fr_FR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _parseResults(jsonDecode(response.body));
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadTrending();
      return;
    }
    setState(() => _loading = true);
    final url = Uri.parse(
        'https://tenor.googleapis.com/v2/search'
        '?key=$_tenorApiKey&client_key=$_tenorClientKey&q=${Uri.encodeComponent(query)}&limit=30&locale=fr_FR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _parseResults(jsonDecode(response.body));
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _parseResults(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    _gifs = results.map((r) {
      final media = r['media_formats'] as Map<String, dynamic>;
      final preview = media['tinygif']?['url'] ?? media['gif']?['url'] ?? '';
      final full = media['gif']?['url'] ?? preview;
      return _GifItem(previewUrl: preview, fullUrl: full);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un GIF...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: _search,
            textInputAction: TextInputAction.search,
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _gifs.isEmpty
                  ? const Center(child: Text('Aucun GIF trouvé'))
                  : GridView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: _gifs.length,
                      itemBuilder: (context, index) {
                        final gif = _gifs[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(gif.fullUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              gif.previewUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _GifItem {
  final String previewUrl;
  final String fullUrl;
  _GifItem({required this.previewUrl, required this.fullUrl});
}

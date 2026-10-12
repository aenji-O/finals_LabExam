import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Map;
    final id = post['id'];
    final title = '${post['title']}';
    final body = '${post['body']}';
    final box = Hive.box('favoritesBox');
    final alreadySaved = box.containsKey(id);
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: ListView(padding: const EdgeInsets.fromLTRB(22, 16, 22, 30), children: [
        Text('STORY  ${id.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w700, letterSpacing: 1.4, fontSize: 12)),
        const SizedBox(height: 15),
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 32)),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(22), child: Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 17)))),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: alreadySaved ? null : () async {
            await box.put(id, {'id': id, 'title': title, 'body': body, 'note': ''});
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to your favorites.')));
          },
          icon: Icon(alreadySaved ? Icons.check_rounded : Icons.bookmark_add_outlined),
          label: Text(alreadySaved ? 'Saved to Favorites' : 'Save to Favorites'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.brown, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Back to posts'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15))),
      ]),
    );
  }
}




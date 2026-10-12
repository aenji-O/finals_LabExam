import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Box _box = Hive.box('favoritesBox');

  Future<void> _editNote(dynamic key, Map post) async {
    final controller = TextEditingController(text: '${post['note'] ?? ''}');
    final note = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Personal note'),
      content: TextField(controller: controller, autofocus: true, maxLines: 3, maxLength: 140, decoration: const InputDecoration(hintText: 'What would you like to remember?')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save note'))],
    ));
    controller.dispose();
    if (note == null) return;
    await _box.put(key, {...Map<String, dynamic>.from(post), 'note': note});
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your note has been saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final keys = _box.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Favorites', style: TextStyle(fontWeight: FontWeight.w700))),
      body: keys.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 72, height: 72, decoration: const BoxDecoration(color: AppColors.lightBrown, shape: BoxShape.circle), child: const Icon(Icons.bookmark_border_rounded, size: 34, color: AppColors.brown)),
              const SizedBox(height: 18),
              Text('A space for the good ones.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Save a post while reading and it will be waiting here.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.tonalIcon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.auto_stories_outlined), label: const Text('Explore posts')),
            ])))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                final post = Map<String, dynamic>.from(_box.get(key) as Map);
                final note = '${post['note'] ?? ''}';
                return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 15, 8, 13),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 35, height: 35, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.lightBrown, borderRadius: BorderRadius.circular(12)), child: Text('${post['id']}', style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w700, fontSize: 12))),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${post['title']}', style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      IconButton(tooltip: 'Remove favorite', onPressed: () async { await _box.delete(key); setState(() {}); }, icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9A665B))),
                    ]),
                    Padding(padding: const EdgeInsets.fromLTRB(47, 3, 12, 5), child: Text('${post['body']}', maxLines: 3, overflow: TextOverflow.ellipsis)),
                    Padding(padding: const EdgeInsets.only(left: 47, right: 12, top: 7), child: Row(children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.brown),
                      const SizedBox(width: 7),
                      Expanded(child: Text(note.isEmpty ? 'Add a personal note' : note, style: TextStyle(fontSize: 13, color: note.isEmpty ? AppColors.muted : AppColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      TextButton(onPressed: () => _editNote(key, post), child: Text(note.isEmpty ? 'Add' : 'Edit')),
                    ])),
                  ]),
                )));
              },
            ),
    );
  }
}





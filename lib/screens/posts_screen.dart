import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _posts = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        throw Exception('The server returned status ${response.statusCode}.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = 'Could not load posts. $error'; _loading = false; });
    }
  }

  Future<void> _showComposeDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? validationMessage;
    final payload = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          scrollable: true,
          title: const Text('Write a post'),
          content: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Your thoughts'),
              ),
              if (validationMessage != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    validationMessage!,
                    style: const TextStyle(color: Color(0xFF9A5148)),
                  ),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                if (title.isEmpty || body.isEmpty) {
                  updateDialog(() {
                    validationMessage = 'Please add both a title and some text.';
                  });
                  return;
                }
                Navigator.pop(dialogContext, {'title': title, 'body': body});
              },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    bodyController.dispose();
    if (payload == null) return;
    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({...payload, 'userId': 1}),
      );
      if (!mounted) return;
      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final postId = result is Map<String, dynamic> && result['id'] != null
            ? result['id']
            : DateTime.now().microsecondsSinceEpoch;
        setState(() {
          _posts = [
            {
              'id': postId,
              'title': payload['title'],
              'body': payload['body'],
              'userId': 1,
            },
            ..._posts,
          ];
          _notice = 'Your post was published successfully (ID $postId).';
        });
      } else {
        setState(() => _notice =
            'Post could not be published. Server status: ${response.statusCode}.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _notice = 'Post could not be published. $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Post Reader', style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              tooltip: 'Favorites',
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
              icon: const Icon(Icons.bookmark_border_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showComposeDialog,
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Write'),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchPosts,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.lightBrown,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 16,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'A QUIET CORNER OF THE INTERNET',
                    style: TextStyle(
                      color: AppColors.brown,
                      fontSize: 10,
                      letterSpacing: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                const SizedBox(height: 17),
                Text('A little reading,\nfor your day.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 34)),
                const SizedBox(height: 10),
                const Text('Discover stories from the community.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
                const SizedBox(height: 22),
                if (_notice != null) _MessageCard(text: _notice!, success: !_notice!.contains('could not')),
                if (_error != null) _MessageCard(text: _error!, success: false, onRetry: _fetchPosts),
                if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 50), child: Center(child: CircularProgressIndicator())),
                if (!_loading && _error == null) Row(children: [
                  const Text('LATEST POSTS', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(width: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: AppColors.lightBrown, borderRadius: BorderRadius.circular(20)), child: Text('${_posts.length} stories', style: const TextStyle(color: AppColors.brown, fontSize: 11, fontWeight: FontWeight.w600))),
                ]),
              ]),
            )),
            if (!_loading && _error == null) SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
              sliver: SliverList.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Card(child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                      leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.lightBrown, borderRadius: BorderRadius.circular(14)), child: Text('${post['id']}'.padLeft(2, '0'), style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w700, fontSize: 12))),
                      title: Text('${post['title']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, height: 1.3)),
                      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${post['body']}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.muted),
                      onTap: () => Navigator.pushNamed(context, '/details', arguments: {'id': post['id'], 'title': post['title'], 'body': post['body']}),
                    )),
                  );
                },
              ),
            ),
          ]),
        ),
      );
}


class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text, required this.success, this.onRetry});
  final String text;
  final bool success;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.brown : const Color(0xFF9A5148);
    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: success ? AppColors.lightBrown : const Color(0xFFF1DFD5), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [Icon(success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded, color: color), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))), if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry'))]),
    );
  }
}




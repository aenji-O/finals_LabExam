import 'package:flutter_test/flutter_test.dart';
import 'package:post_reader_favorites/main.dart';

void main() {
  testWidgets('shows the posts screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PostReaderApp());

    expect(find.text('Post Reader'), findsOneWidget);
    expect(find.text('A little reading,\nfor your day.'), findsOneWidget);
    expect(find.byTooltip('Favorites'), findsOneWidget);
  });
}

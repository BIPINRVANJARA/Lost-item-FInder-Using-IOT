import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lost_finder_app/main.dart';
import 'package:lost_finder_app/providers/theme_provider.dart';
import 'package:lost_finder_app/providers/item_provider.dart';
import 'package:lost_finder_app/providers/notification_provider.dart';
import 'package:lost_finder_app/services/firebase_iot_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ItemProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => FirebaseIotService()),
        ],
        child: const LostFinderApp(),
      ),
    );
    expect(find.byType(LostFinderApp), findsOneWidget);

    // Advance time past splash timer and animations
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}

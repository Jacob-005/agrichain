import 'package:flutter_test/flutter_test.dart';
import 'package:agrichain_app/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriChainApp());
    // Basic smoke test — the app should render without crashing
    expect(find.text('AgriChain'), findsOneWidget);
  });
}

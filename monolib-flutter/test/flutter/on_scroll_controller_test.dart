import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monolib_flutter/monolib_flutter.dart';

void main() {
  testWidgets('scrollToTheEnd', (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          controller: controller,
          itemCount: 100,
          itemBuilder: (context, index) =>
              SizedBox(height: 100, child: Text('Item \$index')),
        ),
      ),
    );
    controller.scrollToTheEnd().ignore();
    await tester.pumpAndSettle();
    expect(controller.position.extentAfter, 0.0);
  });
}

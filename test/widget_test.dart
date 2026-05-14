import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_flutter/src/app/persona_app.dart';

void main() {
  testWidgets('shows the desktop shell and core product entries', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PersonaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Style Lab'), findsWidgets);
    expect(find.text('Plot Lab'), findsWidgets);
    expect(find.text('Workflow Runs'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}

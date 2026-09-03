// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:book_exchange_app/main.dart';

void main() {
  testWidgets('login page opens the book exchange home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookExchangeApp());

    expect(find.text('A good book\nfinds its person.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Enter the exchange'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);

    await tester.tap(find.text('Remember me'));
    await tester.pump();
    expect(find.byType(Checkbox), findsOneWidget);

    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next\nfavorite read.'), findsOneWidget);
    expect(find.text('The Midnight\nLibrary'), findsOneWidget);
    expect(find.text('New near you', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Your exchange shelf', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('12', skipOffstage: false), findsOneWidget);
    expect(find.text('Around the corner', skipOffstage: false), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Mystery'));
    await tester.pump();
    expect(find.text('Mystery'), findsOneWidget);
    expect(find.text('Mystery reads', skipOffstage: false), findsOneWidget);
    expect(
      find.text('The Silent Patient', skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.text('The Thursday Murder Club', skipOffstage: false),
      findsNWidgets(2),
    );
  });

  testWidgets('register mode validates and creates an account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookExchangeApp());
    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pump();

    expect(find.text('Join the exchange'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    expect(find.text('Create my account'), findsOneWidget);

    await tester.ensureVisible(find.text('Create my account'));
    await tester.tap(find.text('Create my account'));
    await tester.pump();
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Reader');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'bookworm');
    await tester.tap(find.text('Create my account'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next\nfavorite read.'), findsOneWidget);
  });

  testWidgets('home options open working views and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    final search = find.byType(TextField);
    await tester.enterText(search, 'Pachinko');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.text('Showing books matching “Pachinko”'), findsOneWidget);

    await tester.tap(find.text('Exchanges'));
    await tester.pump();
    expect(find.text('My exchanges'), findsOneWidget);
    expect(find.text('Ready for pickup'), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.pump();
    expect(find.text('Saved shelf'), findsOneWidget);
    expect(find.text('Educated'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Your profile'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pump();
    expect(find.text('Display name'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Book Lover');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Book Lover'), findsOneWidget);
  });
}

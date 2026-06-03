import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prm393project/main.dart';

void main() {
  testWidgets('opens splash then lets a customer register', (tester) async {
    await tester.pumpWidget(const SimDepApp());

    expect(find.text('Sim Đẹp'), findsOneWidget);
    expect(find.text('Đang kiểm tra phiên đăng nhập'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.byKey(const ValueKey('email_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('password_field')), findsOneWidget);

    await tester.tap(find.text('Đăng ký').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('full_name_field')),
      'Tran Van Test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('phone_field')),
      '0901234567',
    );
    await tester.enterText(
      find.byKey(const ValueKey('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password_field')),
      '123456',
    );

    await tester.tap(find.byKey(const ValueKey('auth_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Xin chào, Tran Van Test'), findsOneWidget);
  });
}

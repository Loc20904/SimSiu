import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prm393project/core/app_theme.dart';
import 'package:prm393project/main.dart';
import 'package:prm393project/screens/sim_list/sim_list_screen.dart';
import 'package:prm393project/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.instance.signOut();
  });

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
    expect(find.text('Loại sim phổ biến'), findsOneWidget);
    expect(find.text('Sim nổi bật'), findsOneWidget);
  });

  testWidgets('sim list searches by phone number', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SimListScreen()),
    );

    expect(find.text('Danh sách sim'), findsOneWidget);
    expect(find.text('Nhà mạng'), findsOneWidget);
    expect(find.text('Loại sim'), findsOneWidget);
    expect(find.text('Khoảng giá'), findsOneWidget);
    expect(find.text('0909 888 888'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Về bộ lọc'), findsOneWidget);

    await tester.tap(find.byTooltip('Về bộ lọc'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sim_list_search_field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('sim_list_search_field')),
      '686868',
    );
    await tester.pumpAndSettle();

    expect(find.text('0986 686 868'), findsOneWidget);
    expect(find.text('0909 888 888'), findsNothing);
  });
}

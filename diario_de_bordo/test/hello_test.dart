// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:diario_de_bordo/main.dart' as app;

void main() {
  testWidgets('Log screen smoke test', (WidgetTester tester) async {
    app.main(); // builds the app and schedules a frame but doesn't trigger one
    await tester.pump(); // triggers a frame

    expect(find.text('Diário de Bordo'), findsOneWidget);
    expect(find.text('Status: Parado'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });
}

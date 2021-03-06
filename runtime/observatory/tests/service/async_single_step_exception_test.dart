// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// VMOptions=--verbose_debug --async_debugger --no-sync-async

import 'dart:developer';
import 'service_test_common.dart';
import 'test_helper.dart';

const LINE_A = 19;
const LINE_B = 20;
const LINE_C = 26;
const LINE_D = 28;
const LINE_E = 31;
const LINE_F = 34;
const LINE_G = 36;

helper() async {
  print('helper'); // LINE_A.
  throw 'a'; // LINE_B.
  return null;
}

testMain() async {
  debugger();
  print('mmmmm'); // LINE_C.
  try {
    await helper(); // LINE_D.
  } catch (e) {
    // arrive here on error.
    print('error: $e'); // LINE_E.
  } finally {
    // arrive here in both cases.
    print('foo'); // LINE_F.
  }
  print('z'); // LINE_G.
}

var tests = <IsolateTest>[
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_C),
  stepOver, // print.
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_D),
  stepInto,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  stepOver, // print.
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_B), // throw 'a'.
  stepInto, // exit helper via a throw.
  hasStoppedAtBreakpoint,
  stepInto, // exit helper via a throw.
  hasStoppedAtBreakpoint,
  stepInto, // step once from entry to main.
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_E), // print(error)
  stepOver,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_F), // print(foo)
  stepOver,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_G), // print(z)
  resumeIsolate
];

main(args) => runIsolateTests(args, tests, testeeConcurrent: testMain);

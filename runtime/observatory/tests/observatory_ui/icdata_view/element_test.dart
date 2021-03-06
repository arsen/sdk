// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:test/test.dart';
import 'package:observatory/src/elements/icdata_view.dart';
import 'package:observatory/src/elements/nav/refresh.dart';
import 'package:observatory/src/elements/object_common.dart';
import '../mocks.dart';

main() {
  ICDataViewElement.tag.ensureRegistration();

  final cTag = ObjectCommonElement.tag.name;
  final rTag = NavRefreshElement.tag.name;

  const vm = const VMMock();
  const isolate = const IsolateRefMock();
  final events = new EventRepositoryMock();
  final notifs = new NotificationRepositoryMock();
  final icdata = const ICDataMock();
  final icdatas = new ICDataRepositoryMock();
  final reachableSizes = new ReachableSizeRepositoryMock();
  final retainedSizes = new RetainedSizeRepositoryMock();
  final inbounds = new InboundReferencesRepositoryMock();
  final paths = new RetainingPathRepositoryMock();
  final objects = new ObjectRepositoryMock();
  test('instantiation', () {
    final e = new ICDataViewElement(vm, isolate, icdata, events, notifs,
        icdatas, retainedSizes, reachableSizes, inbounds, paths, objects);
    expect(e, isNotNull, reason: 'element correctly created');
    expect(e.isolate, equals(isolate));
    expect(e.icdata, equals(icdata));
  });
  test('elements created after attachment', () async {
    final icdatas = new ICDataRepositoryMock(
        getter: expectAsync2((i, id) async {
      expect(i, equals(isolate));
      expect(id, equals(icdata.id));
      return icdata;
    }, count: 1));
    final e = new ICDataViewElement(vm, isolate, icdata, events, notifs,
        icdatas, retainedSizes, reachableSizes, inbounds, paths, objects);
    document.body.append(e);
    await e.onRendered.first;
    expect(e.children.length, isNonZero, reason: 'has elements');
    expect(e.querySelectorAll(cTag).length, equals(1));
    (e.querySelector(rTag) as NavRefreshElement).refresh();
    await e.onRendered.first;
    e.remove();
    await e.onRendered.first;
    expect(e.children.length, isZero, reason: 'is empty');
  });
}

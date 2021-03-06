// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:async_helper/async_helper.dart';
import 'package:compiler/src/compiler.dart';
import 'package:compiler/src/ir/static_type.dart';
import 'package:compiler/src/library_loader.dart';
import 'package:kernel/ast.dart' as ir;
import 'package:kernel/class_hierarchy.dart' as ir;
import 'package:kernel/core_types.dart' as ir;
import 'package:kernel/type_environment.dart' as ir;

import '../helpers/memory_compiler.dart';

const String source = '''
main() {}
''';

main() {
  asyncTest(() async {
    Compiler compiler =
        await compilerFor(memorySourceFiles: {'main.dart': source});
    LoadedLibraries loadedLibraries = await compiler.libraryLoader
        .loadLibraries(Uri.parse('memory:main.dart'));
    ir.Component component = loadedLibraries.component;
    StaticTypeVisitor visitor = new Visitor(component);
    component.accept(visitor);
  });
}

class Visitor extends StaticTypeTraversalVisitor {
  Visitor(ir.Component component)
      : super(new ir.TypeEnvironment(
            new ir.CoreTypes(component), new ir.ClassHierarchy(component)));

  ir.DartType getStaticType(ir.Expression node) {
    if (typeEnvironment == null) {
      // The class hierarchy crashes on multiple inheritance. Use `dynamic`
      // as static type.
      return const ir.DynamicType();
    }
    ir.TreeNode enclosingClass = node;
    while (enclosingClass != null && enclosingClass is! ir.Class) {
      enclosingClass = enclosingClass.parent;
    }
    try {
      typeEnvironment.thisType =
          enclosingClass is ir.Class ? enclosingClass.thisType : null;
      return node.getStaticType(typeEnvironment);
    } catch (e) {
      // The static type computation crashes on type errors. Use `dynamic`
      // as static type.
      return const ir.DynamicType();
    }
  }
}

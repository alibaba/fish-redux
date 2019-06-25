import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'basic.dart';

class Local {
  static T of<T>(Context<Object> ctx, {T Function() init}) =>
      (ctx.extra['${T.toString()}'] ??= init());

  static void onDispose<T>(
    Context<Object> ctx, {
    @required void Function(T) visitor,
  }) {
    if (ctx.extra['onDispose ${T.toString()}'] == null) {
      ctx.extra['onDispose ${T.toString()}'] = true;
      ctx.registerOnDisposed(() => visitor(Local.of<T>(ctx)));
    }
  }
}

class LocalVars<T, P> {
  final T Function(P, BuildContext) construct;
  final void Function(T, BuildContext) destruct;

  const LocalVars({@required this.construct, this.destruct})
      : assert(construct != null);

  T of(ExtraData extraData) {
    assert(extraData is Context<P>);
    final Context<P> ctx = extraData;
    if (ctx.extra[_key] == null) {
      final T result = construct(ctx.state, ctx.context);
      ctx.extra[_key] = result;
      if (destruct != null) {
        ctx.registerOnDisposed(() => destruct(result, ctx.context));
      }
    }
    return ctx.extra[_key];
  }

  String get _key => '\$ ${T.toString()}';
}

abstract class L<T, P> {
  T construct(P state, BuildContext context);
  void destruct(T local);
}

// class T {
//   int a;
//   int b;
//   static final LocalVars<T, Object> local = LocalVars<T, Object>(
//     construct: (P state, BuildContext context) => T(),
//     destruct: (T _) => null,
//   );
// }

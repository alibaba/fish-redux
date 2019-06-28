import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'basic.dart';

@immutable
class LocalProps<T, P> {
  final T Function(Context<P>) construct;
  final void Function(T, Context<P>) destruct;

  const LocalProps({@required this.construct, this.destruct})
      : assert(construct != null,
            'Please provide a constructor to create <T> instance.');

  T of(ExtraData context) {
    assert(context is Context<P>);
    final Context<P> ctx = context;
    if (ctx.extra[_key] == null) {
      final T result = construct(ctx);
      ctx.extra[_key] = result;
      if (destruct != null) {
        ctx.registerOnDisposed(() => destruct(result, ctx));
      }
    }
    return ctx.extra[_key];
  }

  String get _key => '\$ ${T.toString()}';
}

/***
 *      
 *       @immutable
 *       class T {
 *         final int a;
 *         final int b;
 *         final FocusNode focusNode;
 *
 *         const T(this.a, this.b, this.focusNode);
 *
 *         static final LocalProps<T, Object> local = LocalProps<T, Object>(
 *           construct: (Context<Object> ctx) {
 *             const T result = T(0, 0, FocusNode());
 *             result.focusNode.addListener(() {});
 *             return result;
 *           },
 *           destruct: (T result, Context<Object> ctx) {
 *             // result.a = 0;
 *             // result.b = 0;
 *           },
 *         );
 *       }

        Widget build(Object state, Dispatch dispatch, ViewService vs) {
          final T result = T.local.of(vs);
          // result.
          return Container();
        }

        void init(Context<Object> ctx, Action a) {
          final T result = T.local.of(ctx);
        }
 */

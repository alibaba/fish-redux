import 'package:flutter/foundation.dart';

import 'basic.dart';

/// usage
/// class ALocal extends LocalState<ALocal> {
///   /// your fields
///
///   ALocal(Context<Object> ctx) : super(ctx) {
///     /// your constructor
///   }
///
///   @override
///   void destruct(Context<Object> ctx) {
///     // your destructor
///   }
///
///   factory ALocal.of(ExtraData ctx) =>
///       LocalState.provide<ALocal>((_) => ALocal(_)).of(ctx);
/// }
abstract class LocalState<T extends LocalState<T>> {
  LocalState(Context<Object> ctx) : assert(ctx != null);
  void destructor(Context<Object> ctx);

  static _LocalStateProvider<T> provide<T extends LocalState<T>>(
          T Function(Context<Object>) construct) =>
      _LocalStateProvider<T>(
        construct: construct,
        destruct: (T local, Context<Object> ctx) => local.destructor(ctx),
      );
}

@immutable
class _LocalStateProvider<T> {
  final T Function(Context<Object>) construct;
  final void Function(T, Context<Object>) destruct;

  const _LocalStateProvider({@required this.construct, this.destruct})
      : assert(construct != null,
            'Please provide a constructor to create <T> instance.');

  T of(ExtraData context) {
    assert(context is Context<Object>);
    final Context<Object> ctx = context;
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

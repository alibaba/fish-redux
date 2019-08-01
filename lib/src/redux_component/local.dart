import 'package:flutter/foundation.dart';

import 'basic.dart';

///
/// Description:
///
/// LocalProps 所储存的 props 不参与 view 的刷新
///
///
/// Define:
///
/// ```dart
/// class ComponentLocalProps extends LocalProps<ComponentLocalProps> {
///
///   final controller = TextEditingController();
///
///   ComponentLocalProps(Context<Object> ctx) : super(ctx);
///
///   @override
///   void destruct(Context<Object> ctx) {}
///
///   factory ComponentLocalProps.of(ExtraData ctx) {
///     return ComponentLocalProps.provide<ALocal>((_) => ComponentLocalProps(_)).of(ctx);
///   }
/// }
/// ```
///
/// Usage:
///
/// in View
/// ```dart
/// ComponentLocalProps.of(viewService).controller
/// ```
/// in effect
/// ```dart
/// ComponentLocalProps.of(ctx).controller
/// ```
///
abstract class LocalProps<T extends LocalProps<T>> {
  LocalProps(Context<Object> ctx) : assert(ctx != null);
  void destructor(Context<Object> ctx);

  static _LocalPropsProvider<T> provide<T extends LocalProps<T>>(
          T Function(Context<Object>) construct) =>
      _LocalPropsProvider<T>(
        construct: construct,
        destruct: (T local, Context<Object> ctx) => local.destructor(ctx),
      );
}

@immutable
class _LocalPropsProvider<T> {
  final T Function(Context<Object>) construct;
  final void Function(T, Context<Object>) destruct;

  const _LocalPropsProvider({@required this.construct, this.destruct})
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

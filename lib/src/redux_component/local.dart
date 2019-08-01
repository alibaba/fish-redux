import 'package:flutter/foundation.dart';

import 'basic.dart';

///
/// Description:
///
/// LocalProps的状态变化不会触发View的刷新
///
///
/// Define:
///
/// ```dart
/// class ComponentLocalProps extends LocalProps<ComponentLocalProps> {
///   final TextEditingController controller = TextEditingController();
///
///   ComponentLocalProps(Context<Object> ctx) : super(ctx);
///
///   factory ComponentLocalProps.of(ExtraData ctx) {
///     return LocalProps.provide((_) => ComponentLocalProps(_)).of(ctx);
///   }
///
///   @override
///   void destructor(Context<Object> ctx) {
///     controller.dispose();
///   }
/// }
///
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

// class ComponentLocalProps extends LocalProps<ComponentLocalProps> {
//   ComponentLocalProps(Context<Object> ctx) : super(ctx);

//   factory ComponentLocalProps.of(ExtraData ctx) {
//     return LocalProps.provide((_) => ComponentLocalProps(_)).of(ctx);
//   }

//   @override
//   void destructor(Context<Object> ctx) {}
// }

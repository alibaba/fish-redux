# Auto-Dispose

-   AutoDispose is a very simple way to manage lifecycle objects. An auto-dispose object can be released on its own initiative or released when the managed object it follows is released.
-   The Context used in Effect and the EffectPart in HigherEffect are auto-dispose objects. So we can easily host custom objects that need to be managed for lifecycle management.
-   Sample Code

```dart
class ItemWidgetBindingObserver extends WidgetsBindingObserver
    with AutoDispose {
  ItemWidgetBindingObserver() : super() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppConfig.flutterBinding.framesEnabled &&
        state == AppLifecycleState.resumed) {
      AppConfig.flutterBinding.performReassemble();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}

void _init(Action action, Context<ItemPageContainerState> ctx) {
    final ItemWidgetBindingObserver observer = ItemWidgetBindingObserver();
    observer.follow(ctx);
}

```

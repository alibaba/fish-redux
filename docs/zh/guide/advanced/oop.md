---
title: 面向对象写法
---

虽然框架推荐使用的函数式的编程方式，但也提供面向对象式的编程方式的支持。

View 部分，要继承于 ViewPart 类，复写 build 函数来输出 UI ，而需要的 state ，dispatch ， viewService 已经成为了对象的字段，可以直接使用。此时定义的对象应是不变的，所以不应该也不需要在内部定义可变字段。

示例代码

```dart
class MessageView extends ViewPart<MessageState> {
  @override
  Widget build() {
    return Column(children: [
      viewService.buildComponent('profile'),
      InkWell(
        child: Text('$message'),
        onTap: () => dispatch(const Action('onShare')),
      ),
    ]);
  }
}
```


Effect 部分，要继承于 EffectPart 类，复写 createMap 函数为组件注入 Effect 。而需要的 Context 已经被打平，作为了对象的字段可以直接使用，可以定义字段，它的可见性也仅限于自身。**它必须配合 higherEffect 一起使用**。

示例代码

```dart
class MessageEffect extends EffectPart<MessageState> {
  ///we could put some Non-UI fields here.

  @override
  Map<Object, OnAction> createMap() {
    return <Object, OnAction>{
      Lifecycle.initState: _initState,
      'onShare': _onShare,
    };
  }

  void _initState(Action action) {
    //do something on initState
  }

  void _onShare(Action action) async {
    //do something on onShare
    await Future<void>.delayed(Duration(milliseconds: 1000));
    dispatch(const Action('shared'));
  }
}

class MessageComponent extends Component<MessageState> {
  MessageComponent(): super(
    view: MessageView().asView(),
    higherEffect: higherEffect(() => MessageEffect()),
  );
}
```

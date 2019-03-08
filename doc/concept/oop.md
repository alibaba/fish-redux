# OOP

-   Although the framework recommends the use of functional programming, it also provides object-oriented programming support.
    -   ViewPart
        -   Need to override the 'build' function.
        -   The required state, dispatch, and viewService parameters have become fields of the object and can be used directly.
        -   It is immutable, so there should be no need to define variable fields internally.
    -   EffectPart
        -   Need to override the 'createMap' function.
        -   The required Context has been flattened as the fields which can be used directly.
        -   Fields can be defined and their visibility is limited to themselves.
        -   It must be used with higherEffect.
-   Sample Code

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

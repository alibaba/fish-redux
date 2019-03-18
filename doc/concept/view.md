# View

-   View is a context-independent function that outputs Widget. It receives the following parameters
    -   T state
    -   Dispatch
    -   ViewService
-   It mainly contains three aspects of information
    -   The view is completely driven by data.
    -   The event/callback triggered by the view, use Dispatch to send "intent", but never do a specific implementation.
    -   Use dependent component/adapter, by explicitly configuring it on the parent component, and then standardizing calls through the ViewService.
        -   Where ViewService provides three capabilities
            -   BuildContext context: Ability to get widget's BuildContext
            -   Widget buildView(String name): Ability to create subcomponents directly
                -   The name passed in here is the name configured on Dependencies.
                -   Creating subcomponents does not require passing in any other parameters, since the parameters required by the subcomponents have been passed through the Dependencies configuration, and their data relationships are established via the connector.
            -   ListAdapter buildAdapter(): Ability to create adapter directly
-   Sample Code

```dart
Widget buildMessageView(String message, Dispatch dispatch, ViewService viewService) {
  return Column(children: [
    viewService.buildComponent('profile'),
    InkWell(
      child: Text('$message'),
      onTap: () => dispatch(const Action('onShare')),
    ),
  ]);
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
        );
}
```

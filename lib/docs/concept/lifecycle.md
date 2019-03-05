# Lifecycle

-   The default all lifecycles are essentially derived from the lifecycle in flutter State<StatefulWidget>.
    -   initState
    -   didChangeDependencies
    -   build
    -   didUpdateWidget
    -   deactivate
    -   dispose
-   Within the component, the Lifecycle of the Reducer is consistent with the page, and the lifecycle of Effect and View is consistent with the component's Widget.
-   In the adapter, the Lifecycle of the Reducer is consistent with the page. The life cycle of the Effect is the same as the life cycle of the ListView. The life cycle of the View is short-lived (destroyed in the invisible area). At the same time, the life cycle of appear and disappear is added, representing the view array managed by this adapter, the callback just entering the display area and completely leaving the display area.

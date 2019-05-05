# Adapter

-   In addition to the concept of the underlying Component, we have added a componentized abstract Adapter. Its goal is to solve the 3 problems of the Component model in the ListView scene.

    -   1）Putting a "Big-Cell" in the ListView does not enjoy the performance optimization of the ListView code.
    -   2）Component cannot distinguish between the appear|disappear and init|dispose events.
    -   3）The life cycle of the Effect and the coupling of the View do not meet the intuitive expectations in some scenes of the ListView.

-   An Adapter and a Component are almost identical except for the following points

    -   Component generates a Widget, Adapter generates a ListAdapter, and ListAdapter has the ability to generate a list of Widgets.。
        -   Not specifically generating a Widget but a ListAdapter can greatly improve the page frame rate and fluency.
    -   Effect-Lifecycle-Promote
        -   The Effect of Component follows the life cycle of the Widget, and the Adapter's Effect follows the life cycle of the parent Widget.
        -   The improvement of the life cycle of the effect greatly removes the coupling between the business logic and the view life. Even if its display has not yet appeared, other modules can still call its capabilities through dispatch-api.
    -   Appearance|disappear event notification
        -   As the Effect lifecycle improves, we can more closely distinguish between init|dispose and appear|disappear. This is indistinguishable from the Model's model.
    -   Reducer is long-lived, Effect is medium-lived, View is short-lived.

-   Three implementations of Adapter
    -   [DynamicFlowAdapter](dynamic-flow-adapter.md)
    -   [StaticFlowAdapter](static-flow-adapter.md)
    -   [CustomAdapter](custom-adapter.md)

# Directory

The recommended directory structure

```
sample_page
    -- action.dart /// define action types and action creator
    -- page.dart /// config a page or component
    -- view.dart /// define a function which expresses the presentation of user interface
    -- effect.dart /// define a function which handles the side-effect
    -- reducer.dart /// define a function which handles state-change
    -- state.dart /// define a state and some connector of substate
    components
        sample_component
        -- action.dart
        -- component.dart
        -- view.dart
        -- effect.dart
        -- reducer.dart
        -- state.dart
```

The upper layer is responsible for assembly and the lower layer is responsible for implementation.

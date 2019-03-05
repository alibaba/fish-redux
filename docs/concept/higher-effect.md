# HigherEffect

-   Since Effect may have some temporary state of its own (although it is not recommended, support is provided), in order to support this feature, we promote the Effect to a higher-order function and put its state in the closure.
-   The framework supports the configuration of Effect|HigherEffect on component or adapter, but it can't be configured for one component or adapter at the same time, which will cause trouble. In general, the configuration is often an explicit negligence.
-   HigherEffect = (Context ctx) => (Action action) => FutureOr
-   For more detailed examples, please refer to [OOP](oop.md) - EffectPart

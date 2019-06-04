# HigherEffect

-   由于 Effect 有可能有自己一些临时状态（尽管不建议这么做，但还是提供了支持），为了支持这个特性，我们将 Effect 提升为高阶函数，将它的状态放在闭包里。
-   框架支持 Effect|HigherEffect 的配置，但是不能对一个组件或适配器同时都配置，那样会带来困扰，一般情况下，都配置往往是个显式的疏忽大意。
-   HigherEffect = (Context ctx) => (Action action) => FutureOr
-   更详细的例子请参考 [OOP](oop-cn.md) - EffectPart

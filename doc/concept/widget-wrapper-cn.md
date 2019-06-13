### WidgetWrapper

-   它用来解决 flutter 的 ui 体系下，一些需要实现特色接口的 Widget，比如 KeepAlive，因为通过 Component 产生的 Widget 会被一个框架内部的 Stateful 的 Widget 所包裹。
-   示例代码

```dart
import 'package:flutter/material.dart' hide Action;

Widget repaintBoundaryWrapper(Widget widget) {
  return RepaintBoundary(child: widget);
}
```

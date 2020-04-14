# Communication Mechanism

## Page internal communication

-   Component internal communication
-   Inter-component communication

![image.png | left | 747x399](https://cdn.nlark.com/lark/0/2018/png/82574/1545365233153-4c8105b4-050c-49e6-be02-dbf28a861caa.png)

Self-First-Broadcast。
The emitted Action will be processed first by its own Effect, otherwise it will be broadcast to other components and Redux.

We completed the communication between the components (parent to child, child to parent, brother, etc.) through a simple and intuitive dispatch.

## Inter-page communication

-   Context.appBroadcast
    -   Each page's PageStore receives an action which is handled independently.

![image.png | left | 691x519](https://cdn.nlark.com/lark/0/2018/png/82574/1545368705599-745c46a3-f5c6-41a7-a757-1bc6f9a389d4.png)

# Refresh Mechanism

## 数据刷新

-   Local data modification automatically triggers a shallow copy of the upper layer data and is transparent to the business code.

![image.png | left | 747x361](https://cdn.nlark.com/lark/0/2018/png/82574/1545386668521-0081cb5f-8017-47d1-ad7c-8802bb0be8a0.png)

## View refresh

-   When the state changes, the store flatly notifies all the components and the [ShouldUpdate](should-update.md) decide whether the view should be refreshed

![image.png | left | 747x336](https://cdn.nlark.com/lark/0/2018/png/82574/1545386773247-2eddfa99-e6b9-4be9-ac43-d1944ff44e9b.png)

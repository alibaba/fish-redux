## [0.3.7]
- fix test .
- revert issue 613

## [0.3.6]
- fix some dos .

## [0.3.5]
- fix deprecated using of api - inheritFromWidgetOfExactType .

## [0.3.4]
- fix PureViewComponent's dispatch bug

## [0.3.3]
- fix Page name duplication
- easy to use reselect
- add keep-alive-client wrapper
- fix spell error on pure-view-widget
- add default widget for component.buildComponent api
- add docsify to view docs
- add unit test for collection utils and maplike connector

## [0.3.2]
- fix Page name duplication

## [0.3.1]
- rename AdapterSource’s api 
- add PureViewComponent 
- deprecate broadcastEffect 
- 
## [0.3.0]
- add SourceFlowAdapter
- Use SourceFlowAdapter instead of DynamicFlowAdapter in example
- deprecate DynamicFlowAdapter

## [0.2.8]
- fix item-bean clone bug #493

## [0.2.7]
- add StateKey #461
- reselect optimization #482

## [0.2.6]
- add TickerProviderMixin
- let dispatch return whatever result in effect. #462 
- fix Reselect's _listEquals bug #457 
- fix SingleTickerProviderMixin & TickerProviderMixin’s dispose bug #461 
- add ClearOnDependenciesChanged 

## [0.2.5]
- add ctx.listen api
- rename LocalState to LocalProps
- correct some comments 

## [0.2.4]
- fix Context.broadcast bug #375
- fix PrivateReducerMixin bug #380 
- add LocalState

## [0.2.3]
- Reconstruct Context
- Breaking-change 
  - Reconstruct dependencies
  - Remove OOP style
  - Remove higherEffect
  - Remove deprecated api(Connector, createMixedStore, AutoDispose:follow, AutoDispose:follower)
  - Remove unused DisposedException
- Hide widgets.dart's Action to compate with flutter1.7
- Compate with flutter_web

## [0.2.2]
- add congruent conn 
- fields mainCtx & viewUpdater in ComponentState become public 
- fix bug when a store recived action after teardown

## [0.2.1]
- add forceUpdate api on context
- fix bug in adapter’s appear & disappear if items are recycled
- fix bug in connectStores api if page has no reducer

## [0.2.0]
- force update if driven by outside observable 
- fix inverter bugs & optimization connectStores api 
- modify the use of global state in example 

## [0.1.9]
- add mixed-store's batch notification feature

## [0.1.8]
- add api to subscribe app-store for page-store
- add api to subscribe app-store for component
- add viewMiddleware
- add adapterMiddleware
- add effectMiddleware
- add protected attribute method, more friendly to OOP
- remove debug_report

## [0.1.7]
- reconstruct mixed-store
- reconstruct communication
- rename appBroadcast to broadcast
- rename pageBroadcast to broadcastEffect
- add dispatch-bus
- enhance dispatch-api
- add some docs
- move test to dev_dependencies

## [0.1.6]
- fix bug if component has no reducer in app-routes
- reconstruct createStore
- app-routes's store to be visible

## [0.1.5]
- fix bug if notified on building
- reconstruct test
- add mergeMiddleware\$

## [0.1.4]
- add support for AppStore
- add routes
- move middleware/aop to the top dir
- add PrivateReducerMixin
- add reselect
- add docs

## [0.1.3]
- add support for immutable-state #111
- fix the same type of state component reuse in listview #107
- remove warnings in logMiddleware for debug-actions #98
- correct spelling
- modify bindAction #73

## [0.1.2]
- add stfState field in Context #58
- add batchedNotify feature in page-store
- add some docs
- correct spelling

## [0.1.1]
- fix hot-reload bug
- add excluedSelf in broadcast
- rename sample to example
- rename docs to doc

































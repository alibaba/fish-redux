## Fish-Redux入门教程

### 说在前面

这篇教程主要是对有一定flutter基础，而对状态管理或者redux，fish-redux几乎0基础的同学了解，如何快速使用fish-redux。这里也吐槽一下之前fish-redux的文档，以我这个水平的同学看懂一部分需要很长一段时间，这篇文章也是我看懂这些文档的一些过程和总结。不过官方在0.1.8版本后文档已经修改了很多，这里表扬一下！

### 状态管理概念

Flutter中更新的UI都是基于state修改然后对widget树的渲染，而UI刷新逻辑和widget树或者element树（渲染树）逻辑已经是flutter框架写好的，在大部分情况下，开发者不用去干涉，所以开发者要对UI的控制，基本都是对state的控制。以至于我们需要一个合理的流程或者说管理方式来控制state。

这里还有一个问题的就是state是什么？

state可以认为是对数据的一个封装，对于有客户端开发经验的同学，可以认为state就是数据model。

### Fish-Redux中state层级

在Fish-Redux中状态可以依据状态的作用域分为以下三个层级

1. AppState 全局状态 例如：主题，语言版本，用户状态，或者多个页面需要都需要用到的数据，这里重点提一下多页面数据，有些数据可能只有俩个页面使用，例如，进入profile，然后进入编辑，这里的数据需要共享，我们依然需要使用全局数据。这里还有一些其他方法可以做到，但是涉及到之后的知识点，现在暂不说明。
2. page 页面状态，仅用于单个页面的状态。数据展现和改变只在页面有效。
3. component 组件状态，仅用于单个组件的状态，状态初始化大部分来源于页面的状态的一部分。这里不细讲。



### 一个完整page使用流程

这里我们用一个例子来完整的使用一下基于page页面状态的fish-redux使用流程。这里主要展示编写流程和类的概念，所以不涉及到测试。如果使用tdd，需要先写测试用例，在写实现，函数测试和组件测试之后会单独介绍。

需求：用户登陆

1. 用户输入email 和密码，点击登陆按钮执行登陆
2. 如果输入email不合法的toast提示email不合法
3. 输入特定的账户密码，返回登陆成功，toast用户XXX login sucess

##### State

第一步肯定需要定义，我们需要的状态，也就是展示或修改的数据。

```dart
class LoginState implements Cloneable<LoginState> {
  static const LoginResult_EmailFail = 1;
  static const LoginResult_PassWordFail = 2; // 例子密码不合法，暂不实现
  static const LoginResult_NetWorkFail = 3; //例子网络错误，暂不实现
  static const LoginResult_LoginSuccess = 4;
  int loginResult = 0; //登陆的结果
  String userName; 
  final int age = 0;
  
  //需要重写clone方法，因为reducer生成新的state时会调用
  @override
  LoginState clone() {
    return LoginState()
      ..loginResult = this.loginResult
      ..userName = this.userName
      ..age=this.age;
  }

  //对比方法，比较俩个实例是否相等，测试验证需要
  @override
  bool operator ==(dynamic other) {
    if (!(other is LoginState)) return false;
    return loginResult == other.loginResult && userName == other.userName
     &&age==other.age;
  }
}
//这里有个静态函数，用于初始化state，具体调用位置之后会介绍
//需要注意的是 这是静态函数，不属于LoginState类
LoginState initState(Map<String, dynamic> args) {
  return LoginState()
    ..loginResult = 0
    ..userName = ""
    ..age=0;
}
```

##### view

这是一个函数非一个类，返回一个widget

```dart
//编辑控制器，用于获取编辑文本
//这里使用有些欠妥，这里定义在外部，在多个相同实例的情况下，可能会有问题，建议还是将这两个字段表达在state中。
//这里是例子，就不做修改了。希望读者在实际使用中注意。
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
//参数
// state用于数据展示
// dispatch用于发送action
// ViewService 用于获取buildcontext，跳转页面需要使用到
Widget buildView(demoState state, Dispatch dispatch, ViewService viewService) {
  return MaterialApp(
      home: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                ),
                //生成eamil编辑组件
                //这里widget较为复杂，都用私有函数生成，建议真实开发中widget嵌套不要超过三层
                _buildEdit(
                    Icon(Icons.email), "email", "input email", _emailController,
                    key: ValueKey('emailEdit')),
                SizedBox(
                  height: 20,
                ),
                 //生成password编辑组件
                _buildEdit(Icon(Icons.lock), "password", "input password",
                    _passwordController,
                    key: ValueKey('passwordEdit')),
                SizedBox(
                  height: 20,
                ),
                 //生成登陆按钮组件
                _loginBtn(dispatch, viewService, key: ValueKey('loginBtn')),
                SizedBox(
                  height: 20,
                ),
                //state中的数据展示如果state更新，会自动刷新
                Text('name = ${state.userName}',style: TextStyle(fontSize: 16),),
                
              ],
            ),
          )));
}
//编辑组件
Widget _buildEdit(
    Widget icon, String label, String hint, TextEditingController controller,
    {Key key}) {
		...	
       controller: controller,
}

//登陆按钮
Widget _loginBtn(Dispatch dispatch, ViewService viewService, {Key key}) {
  return RaisedButton(
   ...
    onPressed: () {
      //获取数据
      var email = _emailController.text;
      
      var password = _passwordController.text;
      //组装数据
      Map<String, dynamic> map = {"email": email, "password": password};
      //发送包装好数据Action
      dispatch(LoginActionCreator.onLoginAction(map));
    },
  );
}
```



##### Action

Action是Fish-Redux中复杂通讯的纽带，于redux不同，fish-redux已经为开发者定义好了，action封装，开发者只需要定义其Type和数据（需要传递的参数），具体方式如下：

```dart
enum LoginAction { login,emailFail,loginSuccess}
//与redux一样使用时用静态方法创建
class LoginActionCreator {

  static Action onEmailFail() {
    return Action(LoginAction.emailFail);
  }
  static Action onLoginSuccess(LoginModel loginModel) {
    return Action(LoginAction.loginSuccess,payload: loginModel);
  }
  static Action onLoginAction(params) {
    return Action(LoginAction.login,payload: params);
  }
}
```



##### Effect和Reducer

说完Action，我们来说看看Action的接收者，Fish-Redux把Action的接收者分为俩块，Effict和Reducer都是一组接收Action的函数，主要的区别是，前者不产生新的状态（state），后者产生一个状态后给view并执行view的build方法重绘页面。接下来还是用一个例子说明，实现判断用户输入的email合法性与请求网络并返回登陆成功的需求。

```dart
Effect
  
Effect<LoginState> buildEffect() {
  return combineEffects(<Object, Effect<LoginState>>{
    //收到type为login的action执行，onlogin方法，这里开发者不用定义参数，是因为已经被Effect定义好的，
    //参数为action和Context<T>
    demoAction.login: onLogin,
    
  });
}
void onLogin(Action action, Context<demoState> ctx) {
  //取出action的登陆参数，参数类型为dynamic，可以是任意对象
  Map loginMap = action.payload;
  String email = loginMap['email'];
  if (!email.contains("@")) {
    //由于是例子，就简单的判断email是否含有@字符，如果没有说明email不合法
    //如果不合法使用context，发送EmailFailAction给reducer
    ctx.dispatch(demoActionCreator.onEmailFail());
  }else{
    //eamil合法初始化网络请求工具类。备注：这个网络请求工具是基于dio很简单的封装，为了之后的测试mock方便
    //读者可以根据自己的业务编写。
    //这里的??=翻译一下
    //if(API.request==null){
    // 	API.request=HttpRequest(API.BASE_URL)
  	//}
    API.request??=HttpRequest(API.BASE_URL);
    //执行post返回一个future
    API.request.post(API.Login, loginMap).then((result) {
     	//由于是例子没有判断result的合法性，直接转为model数据类
      //model类可以通过json转dart类工具生成 地址
      //https://javiercbk.github.io/json_to_dart/
      LoginModel loginModel=LoginModel.fromJson(result);
      //发送登陆成功action给reducer，并model做为参数，放在action中一起传递给reducer
      ctx.dispatch(demoActionCreator.onLoginSuccess(loginModel));
    });
  }
}

Reducer
  
Reducer<LoginState> buildReducer() {
  return asReducer(
    <Object, Reducer<LoginState>>{
      //收到相应type 的action执行相应的方法
      LoginAction.emailFail: _onEmailFail,
      LoginAction.loginSuccess: _onLoginSuccess
    },
  );
}
LoginState _onLoginSuccess(LoginState state, Action action) {
  //返回的state一定不能拿到旧的state直接修改并返回，
  //需要创建一个新的state，大部分情况是用clone创建。
  final LoginState newState = state.clone();
  //状态赋值
  newState.loginResult=LoginState.LoginResult_LoginSuccess;
  //action.payload是action的参数，类型也是dynamic，这里不强转也不会报错，只是写的时候IDE不会
  //自动联想。所以我建议还是写上比较清晰
  newState.userName=(action.payload as LoginModel).session.user.displayName;
  newState.age=(action.payload as LoginModel).session.user.age;
  return newState;
}

LoginState _onEmailFail(LoginState state, Action action) {
  final LoginState newState = state.clone();
  //改变state状态为email不合法
  newState.loginResult=LoginState.LoginResult_EmailFail;
  return newState;
}

```

这里提醒一下，页面是可以直接发送action给reducer的，不是一定要进过effect，但是如果effect定义接收action的type，reducer就不能收到这个action了。

##### 获取新数据展示

如果认真读了前面的代码的小伙伴，应该可以自己领悟出，新数据展示该怎么写了。这里一起回顾一下，并添加一个email不合法的toast。回到我们的view，

```dart
Widget buildView(LoginState state, Dispatch dispatch, ViewService viewService) {
  //在build时，查看状态是否为EmailFail。
  _showEamilFailToast(state, viewService);
  return MaterialApp(
      home: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: <Widget>[
               	...
                 //state中的数据展示如果state更新，会自动刷新
                Text('name = ${state.userName}',style: TextStyle(fontSize: 16),),
              ],
            ),
          )));
}

_showEamilFailToast(LoginState state, ViewService viewService) {
  
  if (state.loginResult == LoginState.LoginResult_EmailFail
      ) {
    //如果当前状态为EmailFail，便展示toast
    Fluttertoast.showToast(
        msg: "Login Email Fail",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black);
  }
}
```

##### Page拼装

说完了流程和所有相应的组件，接下来介绍一下他们是怎么结合在一起的。（这里暂时只介绍Page的拼装，至于App和compnent的拼装比较大同小异，不同的地方之后会单独介绍）

```dart

//声明范型，一个page必须对应一个State，后面的map为启动这个page时传递的参数类型之后会提到
class LoginPage extends Page<LoginState, Map<String, dynamic>> {
  LoginPage()
      : super(
        		//这里传入初始化一个初始化函数，也就是state.dart中定义的初始化函数
            initState: initState,
        		//一个返回effect函数，在effect.dart中定义
            effect:  buildEffect(),
//    面向对象编程
//    higherEffect: higherEffect(() => MessageEffect()),
        		//一个返回reducer函数，在reducer.dart中定义
            reducer: buildReducer(),
        		//一个返回reducer函数
            view: buildView
           );

}
```



### AppState全局状态

####Page组装器路由（Routes）

上面的page使用流程，应该大家对fish-redux的使用，有一个大致的了解。不过还有一个问题没有觉得怎么把page放在flutter中去。因为page这里并不返回一个widget所以不能直接使用，我们需要用路由（routes）来完成对page的组装，并build为具体的widget。fish-redux中routes有俩种类型，分别是PageRoutes和AppRoutes，我们从比较简单的PageRoutes说起。

#### PageRoutes

PageRoutes是最基本的page组装。我们直接看看代码里使用。

```dart
PageRoutes pageRoutes=PageRoutes(
          pages: <String, Page<Object, dynamic>>{
            //这是一个map，实际使用中login这个字符串应该定义到为一个static const字符串。
            //这里为了展示清晰直接使用字符串
            'login': LoginPage()
              ...//这里可以声明多个page
          },
        );
//使用route生成widget
//重点是这里的map参数。这是一个范型，也就是我们page类在定义的时候继承page声明的范型。用于在buildpage时传递数据给page，所以一般以map的key=>value的形式。开发者也可以定义任意形式。
//在page中使用，大家应该还记得initstate，这个函数我们传递了一个map，那就是这个map了。用于初始化state。
Widget loginWidget=pageRoutes.buildPage('login', Map())
...//生成widget，就可以做任意的组装了。
  
```



#### AppRoutes

认真的读者，会有也许会有这样的疑问，为什么page的路由使用会放到AppState全局状态的内容里？接下来就会提到重点AppRoutes。AppRoutes是一个包含了State,Reducer,pages的路由，整个过程，我们还是以一个例子来讲解，

例子需求

1. 点击登陆后跳转到一个detail页面，背景色为主题色
2. 点击detail文字后，背景色替换
3. 在detail页面退出后再点击login再次进入detail页面，背景色为更换后的主题色

##### State

我们定义俩个state，一个是appstate，一个是detailstate。之后我们会说这俩个state的连接问题

```dart
//复习一下state，实现Cloneable，定义数据，重写clone函数和判等函数
class AppState implements Cloneable<AppState> {
  //这里我们只定义了一个color
  Color themeColor;

  AppState(this.themeColor);

  @override
  AppState clone() {
    return AppState(this.themeColor);
  }
  @override
  bool operator ==(dynamic other) {
    if (!(other is AppState)) return false;
    return themeColor == other.themeColor;
  }

  AppState.initialState() {
    themeColor=Colors.blue;
  }
}

//detailpage使用的state
class DetailState implements Cloneable<DetailState> {
  //也只有一个颜色这一个属性
  Color themeColor;

  @override
  DetailState clone() {
    return DetailState();
  }
}

DetailState initState(Map<String, dynamic> args) {
  return DetailState()..themeColor=Colors.red;
}
```

##### Action和reducer

这里的action和reducer都比较简单，我们就一起把代码贴出来。这里需要注意的是AppRoutes是没有effect。因为不修改状态的action都应该在page中执行。

```dart
//这里是把背景色改为黄色
enum AppAction {changYellow}

class AppActionCreator {
  static Action onChangeYellowAction() {
    return const Action(AppAction.changYellow);
  }
}

Reducer<AppState> buildReducer() {
  return asReducer(
    <Object, Reducer<AppState>>{
      AppAction.changYellow: _changYellow,
    },
  );
}
AppState _changYellow(AppState state, Action action) {
  final AppState newState = state.clone();
  newState.themeColor=Colors.yellow;
  return newState;
}
```

##### ConnOp&lt;state,subState&gt;

这是一个连接器，当我们需要从一个state获取一些数据初始化另一个SubState，并且childstate的变化需要同步到State中，这时我们需要定义一个连接器，来定义SubState如何通过State的数据初始化，和Substate变化时如何改变State。在我们的例子中便是 appstate和 detailstate。具体我们看看代码。

```dart
//继承ConnOp
class DetailConn extends ConnOp<AppState, DetailState> {
  @override
  DetailState get(AppState state) {
    //重写get函数，返回一个DetailState，也就是DetailState的绑定
    return AppState.detailState;
  }

  @override
  void set(AppState state, DetailState subState){
    //重写set函数，定义当DetailState有新的状态时AppState应该如何修改
   AppState.detailState=subState;
  }
}
```

连接器是fish-redux比较核心的部分，这里用官方文档的俩句话来描述一下。

- 它表达了如何从一个大数据中读取小数据，同时对小数据的修改如何同步给大数据，这样的数据连接关系。

- 它是将一个集中式的 Reducer，可以由多层次多模块的小 Reducer 自动拼装的关键。

这里和下面component的部分都简单的做了使用介绍，没有继续深入。有兴趣的读者，可以之后去看看实现的原理，这里不再赘述。

##### AppRoutes

我们在看看AppRoutes是怎么完成组装的。其实和page的组件基本相似。

```dart
AppRoutes<AppState>(
  					//初始化状态，这里和page不同，返回不是一个函数，而直接是一个state，
  					//我们这里用的一个工厂构造方法获取
            preloadedState: AppState.initialState(),
  					//配置page组，和每个page和connOp的关系
            slots: {
              // 这里有两种写法，效果是一样的，带操作符的写法比较生动，也简短些。
              // RoutePath.todoList: DetailPage().asDependent(DetailConn()),
              // 这里的加运算符可能部分读者会有疑惑，这里和上面这句代码意义相同，至于为什么可以用这个运算符
              // 是因为ConnOp的运算符被重写了
              // 具体代码  Dependent<T> operator +(Logic<P> logic) => createDependent<T, P>								// (this, logic);
              'detail': DetailConn() + DetailPage(),

            },
  					//配置reducer()和page完全一样
            reducer: buildReducer())
      ])
  
  //创建page widget和PageRoutes完全相同
  //不过这里参数传null，因为我们已经通过ConnOp，把page的state初始化工作完成了。所以不通过参数初始化state
  //而且page中的initstate函数也不会被调用
  AppRoute.buildPage('detail', null)；
  
  
 	//发送action给app的reducer
  //开发者需要把自己创建的appRoutes静态暴露出来。在使用的地方直接调appRoutes的store发送action
  AppRoute.appRoutes.store.
                .dispatch(AppActionCreator.onChangeYellowAction());
	
	//也可以发送action，改变子state，通过ConnOp改变appstate，
	//建议使用这种方法，上一种方法可以用与改变appstate，但是这个数据不属于当前page的state数据的情况
 	dispatch(DetailActionCreator.onChangeYellowAction());
  
```

#### 关于全局state的更新

之前介绍了PageRoutes和AppRoutes，根据和fish-redux开发者我的一些问题的解答，这里对之前的一些讲解做一些更正，这里的更正基于0.1.8版本。

##### 用PageRoutes实现主题

之前的例子，我们使用AppRoutes修改全局状态，来改变主题，细心的读者可能发现在连接器中，AppState是包含了整个DetailState，如果我们有成百上千的页面都需要主题色，那AppState不是需要包涵全部的PageState，这是我们不想看到的。对这个疑问，我在issue上跟fush-redux的开发者做了沟通，他给了一个在PageRoutes上实现的方案。

```dart
const Store<AppState> appStore = ...;

MainRoutes extends HybridRoutes {
  MainRoutes():super(
    routes: [
      PageRoutes(
        pages: <String, Page<Object, dynamic>>{
          //这里依然强调数据流的单向性。
					//AppState的数据变更，推送到PageStore，引起PageState的变更与否，再由PageState的变更推送到所					//有页面内的组件的UI变更。
          'detail': DetailPage()..connectExtraStore<AppState>(appStore, (DetailState detailState, AppState appState) {
                return detailState.clone().. themeColor = appState.themeColor;
            },
          ),
         
        },
      ),
    ]
  );
}
```

在0.1.8版本中AppRoutes已经不推荐使用了，各位这样使用PageRoutes完成Page与全局State的绑定关系。



### ComponentState组件状态

接下来我们讲解最一个层级的状态，组件状态，这是fish-redux做到分治的核心，开发者可以根据自己的业务，按照自己的颗粒度来编写一个逻辑独立的组件。且这个组件可插拔到任意你想要的地方。这里我们也用一个例子来讲解。

例子需求

1. 登陆成功和展示用户年龄，并添加一个add按钮
2. 点击add按钮用户年龄加一

#### Component

由于Component在action，effect，reducer，state这些使用和page完全一样，这里就重新说明了，具体的可以看看例子源码就懂了，我们着重讲一下Component在page中的使用。

1. 第一步在page中声明需要使用的Component
2. 第二步在view中通过viewService创建widget

```dart
//在page中声明
class demoPage extends Page<demoState, Map<String, dynamic>> {
  demoPage()
      : super(
					...
            dependencies: Dependencies<demoState>(
                adapter: null,
                slots: <String, Dependent<demoState>>{
                  //注册component
                  //map的key是Component的名字，在view中创建的时候会用到
                  //map的value是一个ConnOp和对应Component
                  'ageChange':AgeChangeConn() + AgechangeComponent()
                }),
      		...      
      );

}
//在view中使用
Widget buildView(demoState state, Dispatch dispatch, ViewService viewService) {
 
  return MaterialApp(
      home: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: <Widget>[
              	...
                //使用这个函数就可以创建Component的widget
                viewService.buildComponent('ageChange')
              ],
            ),
          )));
}
```

最后在着重讲解一点，Component数据的来源，可能有些读者已经了解，在page中申明 的时候我们同时声明了ConnOp，我们就是通过这个ConnOp把Compotent的state初始化的。

#### 修正

如果页面有可能多次构建，且email和password的输入需要保存，_emailController和_passwordController应该放入state，

### 测试相关

测试这部分主要是函数测试和widget测试。这里我们还是以之前page那个例子的需求，说一下如果以TDD的形式如果写函数单测和widget测试。

#### 函数测试

函数测试我们主要是对所有的effect和reducer进行测试。且测试代码应该放到相应的文件夹下，对其我们的生产代码。测试代码结构应该为这三个文件。下面我们一一说明。

![image-20190518094709960](/Users/Macx/Library/Application Support/typora-user-images/image-20190518094709960.png)

#### effect测试

虽然这里写了effect测试，由于fish-redux暂时对effect的单测支持不好，在最新的版本中不能对context.dispatch做验证，但是已经和fish-redux沟通，已经在吧dispatch修改为方法，并合并到master分支上。这里我们已修改后的fish-redux做讲解。

我们主要测试收到type为login的action后执行的onLogin函数。

##### 更正

最新的0.1.8版本已经把dispatch修改为函数。下面代码在0.1.8版本下可以通过测试

```dart
//flutter想要mock类，是非常简单的，因为每个类都是一个接口，
// mock类直接继承mock类，并实现你想要mock的类就可以生成mock类
//这里我们mock，effect发送action的context类和网络请求工具类，模拟返回。
class MockContext extends Mock implements Context<demoState> {}

class MockRequest extends Mock implements HttpRequest {}

void main() {
  test('onlogin email fail', () {
    MockContext context=MockContext();
    Map<String, dynamic> map = {"email": '123', "password": '123'};
    Action action =demoActionCreator.onLoginAction(map);
    //这里onLogin在一般的demo中应该是私有函数，但是我们需要单测，我暂时没有找到测试私有函数的方法
    //目前把它改为public的函数，reducer中方法是一样的
    onLogin(action,context);
    //目前fish-redux 0.1.7版本dispatch还是一个字段，会导致这个验证是失败的
    //跟fish-redux的开发者提出这个问题后，已经在代码里做里改进。改动已经合在master分支上了。
    verify(context.dispatch(demoActionCreator.onEmailFail()));
  });

  test('onlogin login success', () {

    MockRequest mockRequest = MockRequest();
    API.request=mockRequest;
    String loginSuccessReslut='{"session": {"token": "5cd961ec5db81","expire": 300,"rong": "*******","user": {"user_id": "5cd961ebb2fea9226c8b4568","display_name": "devcie9poh","gender": 1,"age": 38}}';
    //这里提一下，因为post返回是一个future，所有需要用thenAnswer返回。这个写法是固定的
    when(mockRequest.post(any, any)).thenAnswer((_) => Future.value(json.decode(loginSuccessReslut)));

    MockContext context=MockContext();
    Map<String, dynamic> map = {"email": '123@gmail.com', "password": '123456'};
    Action action =demoActionCreator.onLoginAction(map);
    onLogin(action,context);
    verify(context.dispatch(demoActionCreator.onloginSuccess());
  });
}
```



#### Reducer测试

相比effect 测试，reducer测试相对简单，因为函数直接返回state，且都是不涉及外部变量的纯函数。

```dart
void main() {
  test('reducer onLoginSuccess', () {
    String loginSuccessReslut='{"session": {"token": "5cd961ec5db81","expire": 300,"rong": "*******","user": {"user_id": "5cd961ebb2fea9226c8b4568","display_name": "devcie9poh","gender": 1,"age": 38}}';
    LoginModel loginModel=LoginModel.fromJson(json.decode(loginSuccessReslut));
    demoState state= onLoginSuccess(demoState(),demoActionCreator.onLoginSuccess(loginModel)) ;
    expect(state.loginResult,demoState.LoginResult_LoginSuccess);
    expect(state.age,38);
    expect(state.userName,"devcie9poh");
  });
}
```



#### Widget测试

这里的组件测试主要参考fish-redux中对整个框架流程的测试，讲解基于fish-redux 项目test代码，fish-redux的组件测试会和其他有比较大的差别。首先我们需要三个dart工具代码。Instrument.dart , test_base.dart, track.dart。具体我们在代码中再做介绍。这次我们分俩个测试用例来讲解。

- 组件UI测试

```dart
testWidgets('login page build', (WidgetTester tester) async {
  		//足迹类，用于最后的验证。最后会通过程序运行真实的足迹和我们设定的足迹是否相等来判断测试是否通过
      final Track track = Track();
  
  		//flutter中widget测试是模拟一个widget的生成，如果不清楚的同学可以查看			   https://flutter.dev/docs/cookbook/testing/widget/introduction
  		//TestPage是之前引入的test_base.dart工具类中一个page实现和page一样
  		//只是initState和view为必填参数，因为是单page测试，不可能从appstate进行state初始化
      await tester.pumpWidget(TestPage<demoState, Map<String, dynamic>>(
        	//instrumentInitState是Instrument.dart中的函数，
        	//作用是对真实的initState做一次封装，目的是在initstate方法执行后，增加一段记录代码
          initState: instrumentInitState<demoState, Map<String, dynamic>>(
              initState, pre: (map) {
            track.append('initState', map);
          }),
        	//与前面的instrumentInitState类似，封装buildview函数，添加一段记录代码
          view: instrumentView<demoState>(buildView,
              (demoState state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          })).buildPage(null));
      //页面测试 目前只能测试是否含有这些元素
      //      findsNothing
      //      验证没有找到Widgets
      //      findsWidgets
      //      验证是否找到一个或多个小部件
      //      findsNWidgets
      //      验证是否找到特定数量的小部件
      expect(find.byKey(ValueKey('emailEdit')), findsOneWidget);
      expect(find.byKey(ValueKey('passwordEdit')), findsOneWidget);
      expect(find.byKey(ValueKey('loginBtn')), findsOneWidget);
			//验证代码是否按照预想的执行
      expect(track,
          Track.pins([Pin('initState', null), Pin('build', initState(null))]));
    });
```

- 组件逻辑测试

这里我们测试登陆的俩种情况代码比较长，请耐心阅读。

```dart
testWidgets('login page test', (WidgetTester tester) async {
      final Track track = Track();
      //生成testpage
      await tester.pumpWidget(TestPage<demoState, Map<String, dynamic>>(
        initState: instrumentInitState<demoState, Map<String, dynamic>>(
            initState, pre: (map) {
          track.append('initState', map);
        }),
        view: instrumentView<demoState>(buildView,
            (demoState state, Dispatch dispatch, ViewService viewService) {
          track.append('build', state.clone());
        }),
        //封装effect 函数，执行记录代码。这类可以拿到action和当时的状态
        effect: instrumentEffect(buildEffect(),
            (Action action, Get<demoState> getState) {
          if (action.type == demoAction.login) {
            //这个状态是改变之前的
            track.append('on effect login', getState().clone());
          }
        }),
        reducer: instrumentReducer<demoState>(buildReducer(),
            suf: (demoState state, Action action) {
          track.append('onReduce', state.clone());
        }),
      ).buildPage(null));
      ///输入不合法email，点击登陆，返回email不合法
      await tester.enterText(find.byKey(ValueKey('emailEdit')), "123");
      await tester.tap(find.byKey(ValueKey('loginBtn')));
      await tester.pump();
    	demoState state = initState(null);
      expect(
          track,
          Track.pins([
            Pin('initState', null), 
            Pin('build', state.clone()),
            Pin('on effect login', state.clone()),
            //注意如果要验证state是否相等，一定要重写相等函数
            Pin('onReduce', () {
              state = state.clone()
                ..loginResult = demoState.LoginResult_EmailFail;
              return state;
            }),
            ///刷新后会执行build并传入最新的state
            Pin('build', state.clone())
          ]));

      ///输入正确数据，点击登陆
  		//如果要多次测试记得重制路径
      track.reset();
  		//模拟请求
      MockRequest mockRequest = MockRequest();
      API.request = mockRequest;
      String loginSuccessReslut =
          '{"session": {"token": "5cd961ec5db81","expire": 300,"rong": "*****","user": {"user_id": "5cd961ebb2fea9226c8b4568","display_name": "devcie9poh","gender": 1,"age": 38}';
      when(mockRequest.post(any, any))
          .thenAnswer((_) => Future.value(json.decode(loginSuccessReslut)));

      await tester.enterText(
          find.byKey(ValueKey('emailEdit')), "123@gmail.com");
      await tester.enterText(find.byKey(ValueKey('passwordEdit')), "123456");
      await tester.tap(find.byKey(ValueKey('loginBtn')));
      await tester.pump(Duration(seconds: 5));
 

      expect(
          track,
          Track.pins([
            Pin('on effect login', state.clone()),
            Pin('onReduce', () {
              state = state.clone()
                ..loginResult = demoState.LoginResult_LoginSuccess
                ..userName = "devcie9poh"
                ..age = 38;
              return state;
            }),
            ///刷新后会执行build并传入最新的state
            Pin('build', state.clone())
          ]));
    });
```



### 其他

就像之前所说的到这里已经基本完成了对fish-redux的基本使用。至于adapter，生命周期这些使用，目前我也还没有在实际中使用到。所以对其了解不深，就不在这里介绍了。如果之后有使用，可能会在后面做更新。其中adapter虽然也很常用，不过我真的有些部分看不懂，讲出来也是最基本的使用，原谅水平有限。如果之后实际项目中用到可能还会去深入研究，所以就到这里了。去敲业务代码写单元测试了  -.-
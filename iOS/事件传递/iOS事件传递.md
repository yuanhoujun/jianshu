#前言
无论是Android，还是IOS，都是事件驱动的操作系统，事件是操作系统的灵魂。却很少有人能够理清楚事件在操作系统内部是如何进行传递处理的。这篇文章将深入探讨iOS系统事件，阐述事件是如何在iOS系统内部进行传递并处理的，希望这篇文章能够对你有所帮助。

#代码说明
本文将使用Objective-C语言进行编码，使用Cocoapods作依赖管理。同时，使用了一个非常优秀的自动布局库PureLayout。PureLayout是拥有非常优秀的自动布局API，支持iOS和OS X双系统，强烈推荐大家使用。

#基本原理
##事件的分类
iOS系统将事件分为三类：
*	**Multitouch Events**
*	**Motion Events**
*	**Remote Control Events**

**Multitouch Events**: 所谓的多点触摸事件，非常好理解，即用户触摸屏幕交互产生的事件类型。

**Motion Events**: 所谓的移动事件。是指用户在摇晃，移动和倾斜手机的时候产生的事件成为移动事件。这类事件依赖于iPhone手机里面的加速计，陀螺仪等传感器。

**Remote Control Events**：所谓的远程控制事件。这个事件从名称上面看，不太好理解。但其实，这个事件指的是用户在操作多媒体的时候产生的事件。比如，播放音乐、视频等。

仔细分析这三类事件，**Multitouch Events**有明确的触摸视图，**UIKit**框架的**View**对象可以明确获取到当前点击的视图对象以及坐标。然后，对触摸视图做出相应的响应。而**Motion Events**和**Remote Control Events**却没有一个明确的交互界面的概念。iOS系统为了支持对这类事件的响应，提出了**Responder**的概念。
关于**Responder**，我们后面再来探讨。


鉴于系统对这三类事件处理的区别，我们将这三类事件区分为两类：
* **Multitouch Events** 有明确的交互界面，可以获取到当前点击的视图组件，并作出相应的响应。
* **Motion Events and Remote Control Events** 没有明确的交互界面，依赖于Responder对事件作出相应的响应

**Continue**
首先，让我们来了解一下**Responder**的概念，什么是Responder，怎样才能成为Responder，Responder又是如何对事件作出响应的。

**About Responder**
1)	什么是**Responder**？
**Responder**是**UIKit**框架封装的一个对象类型，它可以响应并处理事件。所有**Responder**对象的基类都是**UIResponder**，下面我们来通过一张类图看看哪些对象具有**Responder**特性
![图-1](http://upload-images.jianshu.io/upload_images/703764-0932ae01563d3ca5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从上图可以看出，**UIApplication**、**UIViewController**和**UIView**都是**UIResponder**对象，都具有对事件进行响应，处理的能力

再来看看**UIResponder**类里面的一些方法和属性
<pre>
- (UIResponder* )nextResponder;


- (BOOL)canBecomeFirstResponder;    // default is NO
- (BOOL)becomeFirstResponder;


// Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;


// Motion Event
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0);
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0);
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0);


// Remote Control Event
(void)remoteControlReceivedWithEvent:(UIEvent*)event NS_AVAILABLE_IOS(4_0);

</pre>
	
从上面的代码片段，可以看到**UIResponder**对象可以处理**TouchEvent**，**MotionEvent**和**Remote Control Event**事件。还有一个非常重要的方法**nextResponder**,这个方法可以获取到下一个关联的**Responder**，**Responder**对象正是关联**nextResponder**引用组成了一个**Responder**链，我们称之为**The Responder Chain**,系统事件会沿着这个**Responder Chain**传播到**nextResponder**，直到最后一个**Responder**，如果依然没有处理该事件，事件就会被舍弃。但是，问题来了，系统必须先找到第一个**Responder**，即第一个可以响应该对象的事件。英文称之为**First Responder**。

2)   怎样才能成为**First Responder**？
这里还需要关注的一个概念就是**First Responder**，**First Responder**是第一个可以处理当前事件的对象，如果**First Responder**不能处理当前事件，则传递到**nextResponder**。然后依次传递给**nextResponder**。
 
我们用一张官方的图，来具体地看看**Responder**是如何在响应链之间传递的    	
![图-1](http://upload-images.jianshu.io/upload_images/703764-72acb1fab65f7cb6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们来分析一下，事件的传递过程：
第一步，**Application**对象从事件队列中获取事件对象
第二步，**Application**对象将事件对象传递给**Window**，**Window**对象继续传递给**First Responder**，然后事件就会沿着**Responder Chain**（响应者链）传递，直到找到可以处理它的对象。

基于上面的讨论，事件的传递过程，我们基本已经讨论清楚。但是，仅仅是讨论还不够，我们缺乏必要的论据，关于事件传递的证明，我会在后面给出代码证明。

这里，我们先来关注一个问题：
对于**TouchEvents**事件，系统是如何获取到当前正在点击的视图对象的呢？（其实就是寻找**First Responder**）
这依赖于**UIView**里面的两个方法：
<pre>
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event;  
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;
</pre>

第一个方法会返回当前点击的View对象，第二个方法判断当前点击的坐标是否在当前视图边界范围内。如果在当前视图范围内，则返回YES，否则，返回NO。第一个方法会根据第二个方法的判断返回当前点击的视图。

下面我们通过一个比较直观的图形来讲述iOS系统获取当前点击视图对象的过程：
![图-2](http://upload-images.jianshu.io/upload_images/703764-7ad9c79dbc3049ef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
假设用户点击了视图D：
1)   检测到点击坐标在View A范围之内。
2)   继续检测点击范围是否在其子视图B，C范围内。发现点击范围在视图C范围内，则忽略掉B视图及其子视图分支。
3)   继续检测点击范围是否在其子视图D范围内，如果是，则用户当前视图即为视图D。如果不是，继续检测其子视图。
 
根据上述分析：iOS系统会从父视图向子视图依次查找，直到找到点击范围在当前视图边界范围以内。如果点击范围在某子视图范围内，并且没有了子视图，则该视图即为当前点击视图。如果点击范围在某子视图范围之内，并且不在其子视图范围之内，则点击视图即为当前点击视图。
 
PS：感兴趣的同学可以自己去证明一下点击视图的查找过程。

下面开始事件传递的证明：
![图-3](http://upload-images.jianshu.io/upload_images/703764-5243fd8ee5f6a724.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
为此我们创建如上图所示的一个简单app，三种颜色View分别对应类
红色：FirstView
绿色：SecondView
蓝色：ThirdView

我们以**Remote Control Events**为例，来看看事件的传递过程：
首先，我们让SecondView成为**First Responder**
<pre>
- (BOOL)canBecomeFirstResponder {
  return YES;
}
// 然后在ViewController中，执行如下代码
[_secondView becomeFirstResponder];
</pre>

然后，在三个视图分别添加如下测试语句：
FirstView
<pre>
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"FirstView:Play");
            break;
            
        default:
            break;
    }
}
</pre>

SecondView
<pre>
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"SecondView:Play");
            break;
            
        default:
            break;
    }
}
</pre>

ThirdView
<pre>
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"ThirdView:Play");
            break;
            
        default:
            break;
    }
}
</pre>

运行，从屏幕底部拉出音频播放界面，点击播放。这里会触发**Remote Control Event**，回调上图中的方法。
![图-4](http://upload-images.jianshu.io/upload_images/703764-fb2787c923e25e7b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
看到如下输出日志：
<pre>
EventDelivery[4559:323237] SecondView:Play
</pre>
注释掉SecondView里面的 **remoteControlReceivedWithEvent**:，我们可以看到如下输出日志：
<pre>
EventDelivery[4559:323237] ThirdView:Play
</pre>
这里的现象说明：**Remote Control Event**会沿着父视图往子视图传递，即父视图的**nextResponder**就是其子视图。这里大家可以考虑一下，如果当前视图有多个直接的子视图呢？**nextResponder**会是哪一个？请读者们自行证明。
 
这里，我们更进一步证明，事件是否会从View传递给**ViewController**，注释掉三个视图里面的**remoteControlReceivedWithEvent:**方法，并在**ViewController**中重写该方法，同时添加打印日志输出，运行，可以看到如下日志输出：
<pre>
EventDelivery[4559:323237] ViewController:Play
</pre>
这更进一步证明了Responder的传递方向符合上面的分析。

#总结
iOS系统将事件分为三类：
*  **Touch Events**
*  **Motion Events**
*  **Remote Control Events**
 
根据三类事件获取**First Responder**方式的不同，又可以将事件分为：
*  **Touch Events**
*  **Motion Events and Remote Control Events**
 
第一类事件通过获取当前用户交互的界面组件，即为**First Responder**
第二类事件的**First Responder**由用户手动指定。
 
成为**First Responder**必须实现如下两个步骤：
*  重写**canBecomeFirstResponder**方法，返回**YES**
*  给**UIResponder**对象发送**becomeFirstResponder**消息  
 
综上所述，事件的传递过程可以分为两步：
第一步，获取到**First Responder**，不同的事件有不同的获取方式。
第二步，从**First Responder**沿着**Responder Chain**传递到**nextResponder**，直到事件被处理或者舍弃。
 
 
常见的**Responder**传递方向有：
**Initial View** -> **Parent View** -> **ViewController** -> **Window** -> **Application**

如果最终传递到**Application**对象，依然没有对事件作出响应，事件就会被舍弃掉。

通常来说，子视图的**nextResponder**即为其父视图。如果子视图直接依附于**ViewController**，则该子视图的**nextResponder**即为其依附的**ViewController**
 
PS：本文源码和文章原稿都在下方我的**Github**仓库中，有任何问题请按照下面的方式联系我。
 
参考资料：[Event Handling Guide for iOS](https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009541-CH1-SW1)
 
 
如果你喜欢这篇文章，请到Fork我的github仓库：
[https://github.com/yuanhoujun/jianshu.git](https://github.com/yuanhoujun/jianshu.git)
如果你对这篇文章有任何的修改建议，请给我发送**Pull Request**。如果你想给我留言，可以加我的QQ：**626306805**，如果你想和更多的人一起讨论iOS，请加入iOS交流群：**468167089**

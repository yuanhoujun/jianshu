---
你以为你获得了整个世界，其实你已经失去了你最爱的人。你以为你只是配角，可是，你在我的心目中，才是真正的主角。

---


# 什么是Optional
Optional 英文意思是 可选的。在Swift中，Optional变量代表其里面可能有值，也可能没有值。引用官方文档的一段描述，它有两层意思

* 我有一个值，等于x
* 我什么都没有

这个概念是在OC，Java，C++等语言都没有的，第一次接触这个概念请抱着宽容的心态去接受它，看完这篇文章你一定会因此而爱上它。

先来看一看它的基本用法
<pre>
let optionalValue:String? = "abc"
print(optionalValue!)   // “abc”
</pre>

不要以为我写错了，上面的两行代码就是Optional Value的基本用法，你可以看到两个你非常熟悉的符号用在你非常不熟悉的地方。别着急，请先去掉你熟悉的OC外衣，听我慢慢道来。


# 基本概念
---
了解我，请先从我的习性开始

---
从上面两行代码，我们可以了解到，使用Optional Value分为两个步骤：

* 声明 Optional Value （?）
* 使用 Optional Value  (!)

两个步骤对应两个符号： 问号和感叹号，类型后面加一个问号表示声明一个可选值，其中可能包含有指定类型的值，也可能不包含任何值。
而感叹号（!）对应一个新的概念UnWrap,这个概念和Java语言的Unbox类似，中文意思我把它翻译为*解封装*。简而言之，就是从Optional值里面获取真正的值的意思。至于为什么要这样设计，在这篇文章的末尾你就会得到答案。从这里引申开来，你可能会有以下的几个疑问，我们来逐一解决。

## 如何声明一个没有任何值的Optional Value
很简单，将可选值指向nil即可
<pre>
var optValue? = nil
注意：在Swift语言中，不能声明一个非可选值变量或者常量指向nil，它仅仅代表可选变量或常量中不包含任何值的意思。这也是与OC语言不一样的地方
</pre>

## 如果Optional Value中没有值，却用感叹号去取值会怎么样？
这是一个很好的问题，如果发现可选变量或者常量中没有值却依然解封装的话，就会出现运行时异常，导致程序奔溃。故在解封装之前一定要先判断Optional变量或者常量中是否有值
<pre>
// 使用Optional Value之前要先判断其中是否有值
var optValue1:Int?
if optValue1 != nil {
    print("其中包含值:\(optValue1!)")
} else {
    print("其中不包含任何值！")
}
</pre>
Swift是一门神奇的语言，它总是尽可能地将一些流程简化。于是，Optional Binding的概念出现了，所谓的可选绑定，其实就是，在if语句中，如果可选变量或常量中包含值，直接将其解封装赋给一个常量。如果没有值的话，则会进入else分支，具体，请看代码
<pre>
// Optional Binding
if let actualValue = optValue1 {
    print("其中包含值:\(actualValue)")
} else {
    print("其中不包含任何值！")
}
</pre>

## Implicitly Unwrapped Optionals(隐含解封装)
为了简化Swift可选值的用法，SWift还提出了**隐含解封装**这个概念，即不需要手动使用感叹号去解封装，在使用的时候直接使用可选值即可。 
<pre>
// Implicitly Optional Value
let implicitlyOptionalValue:Int! = 33
print(implicitlyOptionalValue)
</pre>
可以看到，隐藏解封装使用冒号声明可选值，使用的时候则直接使用可选值变量名访问即可。不过，这依然存在触发运行时异常的风险。因为，可选变量中可能没有值。所以，在使用之前最好做一个是否有值的判断。

# Optional Value的本质是什么？
可选值其实是用一个叫做Optional的枚举类来实现的，来简单看看它的声明
<pre>
public enum Optional<Wrapped> : _Reflectable, NilLiteralConvertible {
    case None
    case Some(Wrapped)
    /// Construct a `nil` instance.
    public init()
    /// Construct a non-`nil` instance that stores `some`.
    public init(_ some: Wrapped)
    /// If `self == nil`, returns `nil`.  Otherwise, returns `f(self!)`.
    @warn_unused_result
    public func map<U>(@noescape f: (Wrapped) throws -> U) rethrows -> U?
    /// Returns `nil` if `self` is nil, `f(self!)` otherwise.
    @warn_unused_result
    public func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U?
    /// Create an instance initialized with `nil`.
    public init(nilLiteral: ())
}
</pre>
可以看到该枚举类包含了两个值None和Some，None即代表可选对象中没有值，而Some则代表有某些值，枚举类中的泛型参数则代表Optional Value中真正包含的数据类型。所以，声明可选值对象，其实也可以这样声明：
<pre>
// Optional Value的本质
//let optValue2:Int? = 3 // 等同于
let optValue2:Optional<Int> = 3
</pre>
这就是为什么需要用？和！去声明及取值，其实只是告诉编译器这是一个可选值对象，取值的时候请调用该对象的指定方法获取。

# Optional Value解决了什么问题？
第一次接触可选值这个概念的时候，我也一直在问自己这样一个问题。但一直未得到解答。直到上一次我的新文章[《从Swift看Java8》](http://www.jianshu.com/p/6effae84eb45)我才真正理解了这个问题。有兴趣的同学也可以去看我的这篇文章。可选值的出现主要是为了解决非空判断带来的一系列if判断，以及不小心漏判带来的奔溃问题。这些问题从诞生之初就给程序员们带来很大的困扰，一直到Optional变量的出现才彻底解决了这个问题。其实Optional变量并不是Swift的独创，很多之前的新生语言都有这个概念。下面，通过一个简单的例子，来看看它是如何解决上述问题的
<pre>
class Dog {
    var name:String? = "Lucy"
}

class Person {
    var dog:Dog?
}

let person:Person = Person()
print(person.dog?.name) // nil
</pre>

上面的代码会打印出nil，因为dog对象里面没有任何值，？后面的获取属性操作并不会被执行，其并不会导致运行时异常，从而有效地避免了冗长的if语句判断。

# 怎么使用Optional Value
Swift语言有着非常严格的类型检查，普通变量或者常量都被要求必须显式初始化。如果你获取的值可能存在，也可能不存在，推荐使用可选值。因为它可以极大地简化你的业务逻辑，也会让代码看起来更加的清晰。而一些肯定存在值的地方，推荐使用普通变量或者常量，因为这会加快编译速度。使用可选值的时候注意增加是否有值的判断，如果明确知道可选变量中肯定会有值存在，可以使用隐含解封装，因为这会让代码看起来更加优雅。隐含解封装和普通可选值都可以使用可选绑定进行解封装，这会简化是否有值的判断，推荐大家使用。

如果你喜欢我的这篇文章，请点击文章右上方的添加关注。如果你想和更多的人一起讨论Swift语言，请加入我的Swift交流群，我们等着你。
也欢迎你fork这篇文章的源码仓库：[https://github.com/yuanhoujun/Swift.git](https://github.com/yuanhoujun/Swift.git)。更多的意见和讨论请在文章下方的评论里面告诉我！
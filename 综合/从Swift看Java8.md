# 前言
Swift是一门令人惊喜的语言，第一次听说Swift，以为它只不过是OC的一个语法糖而已。可是，当我真正开始了解它的时候，我开始意识到了自己的错误。Swift语言是一门全新设计，有着漂亮语法的现代语言。而今天，我想站在Swift的角度来看看最新发布的Java8，看看Java8给我们带来了什么惊喜，亦或是给我们带来了什么遗憾。

# 姗姗来迟的Java8
从2011年7月底Sun发布了Java 7正式版后，不久，Sun公司被Oracle公司收购了。Java也因此成为了Oracle公司的独家资产。Oracle公司原定于2013年发布Java8，却因安全性问题一拖再拖，最终在2014年3月18日正式发布了Java8。虽然从Java6到Java7中间经历了5年多的等待，而从Java7到Java8只经历了不到3年的时间，却因Oracle公司的频繁“跳票”让开发者感觉比Java7来的似乎更漫长一些。然而，不管怎样，让我们充满期待的Java8终究是来了...

# 久违的闭包
Java8语言中被提到最多的名词恐怕就是**Lambda**表达式，这其实就是闭包。闭包，简单来说，就是没有函数名的代码块。很多现代语言如：Python,Ruby,Go,Objective-C,Swift等都支持闭包。而Java语言支持闭包却让我们等了将近20年。今天，我们就和Swift语言的闭包进行简单的对比，看看Java8的闭包和Swift闭包在用法上有什么区别，各有什么优缺点。

先来看看Java8闭包的基本写法：
<pre>
// 例子一 实现两个数字的相加
// 用几个简单的例子来说明Java8闭包的基本用法
// 实现两个数字相加
interface Sum {
	int f(int x,int y);
}
// 匿名类实现方式
Sum sum = new Sum() {
	@Override
	public int f(int x,int y) {
		return x + y;
	}
};
// 闭包实现
Sum sum = (int x,int y) -> {
	return x + y;
};
// 闭包还支持类型推导
Sum sum = (x,y) -> {
	return x + y;
};
// 甚至可以省略return关键字
Sum sum = (x,y) -> x + y;

// 例子二 实现集合的遍历
List<String> list = new ArrayList<>();
...
// 常规实现
for(String s : list) {
	System.out.println(s);
};

// 闭包实现
list.forEach((value) -> System.out.println(value));
// Java8还支持方法引用。上面的表达式还可以更简单
list.forEach(System.out::println);
</pre>

通过上面两个简单的例子对比，是否感觉闭包在实现同样功能上，其表达方式更加的优雅呢？

下面，我们来看一下用Swift语言实现同样功能的闭包写法
<pre>
// 同样地，实现两个数字相加
// 完整写法
var sum = {(x:Int,y:Int) -> Int in return x + y }
// Swift同样可以省略return关键字,甚至返回值
// 因此简化后，写法
var sum = {(x:Int,y:Int) in x + y}
// 同样地，Swift也支持类型推导，这里我们假设这个闭包表达式作为函数f的一个参数
func f((x:Int,y:Int) -> Int) {

}
// 这里在调用函数f的时候，闭包表达式就可以简写为
f({x,y in x + y})
// Swift还支持参数索引，因此我们还可以进一步简化为
f({$0 + $1})
// Swift还支持Trailing闭包，因此可以使用更漂亮的实现方式
// 这里简单地介绍一下Training闭包，所谓的Trailing闭包，就是说，如果闭包作为函数的最后一个参数，就可以将闭包的实现从括号中直接剥离出来，像函数体一样写在括号的外面。因此，上面的闭包实现还可以写成如下形式：
f() {
	$0 + $1
}
// 下面来实现集合的遍历
var list = [2,1,4,3]
list.forEach { (a) -> () in
    print(a)
}
</pre>

从上面的实现中，可以看到Swift在实现闭包的时候并不需要先定义接口，它可以用一个变量直接接受闭包表达式。但这并不能作为Swift闭包设计优于Java8的证据，这是由于Java天然的面向对象基因决定了其在闭包实现上的短板。不过，Swift的参数索引以及Trailing闭包相对于Java8还是具有微弱的优势。

# Optional 让你告别空指针异常
可能很多人像我一样第一次看到这个名称会感觉到非常陌生。可是，当我换一种说法，大家就会感觉到非常熟悉了。**NulllPointerException** 作为Java程序员，恐怕这个错误是再熟悉不过了吧。没错，Optional就是为了解决空指针异常而引入的。它为什么可以解决空指针异常呢？且听我慢慢道来。

看到这里，你不妨先喝杯茶，我们来简单看看**NullPointerException**的作者怎么评价**NullPointerException**
<pre>
Tony Hoare, the inventor of the null reference apologized in 2009 and denotes this kind of errors as his billion-dollar mistake.
I call it my billion-dollar mistake. It was the invention of the null reference in 1965. 
At that time, I was designing the first comprehensive type system for references in an object oriented language (ALGOL W). 
My goal was to ensure that all use of references should be absolutely safe, with checking performed automatically by the compiler. 
But I couldn't resist the temptation to put in a null reference, simply because it was so easy to implement. 
This has led to innumerable errors, vulnerabilities, and system crashes, 
which have probably caused a billion dollars of pain and damage in the last forty years.

</pre>

从上面这段话可以看出，创始人**Tony Hoare**对其当初的设计并不满意，而且对**NullPointerException**给大家带来的问题感到抱歉。然而，幸好有了**Optional**，这个问题开始出现好转。
所谓的Optional，顾名思义，可选的，即是说，其里面是否包含值是可选的，这个变量里面可能包含值，也可能不包含值。下面我们就通过一个简单的例子，来看看它到底是怎么用的？以及它是如何避免出现空指针异常的。
<pre>
 // 基本用法
 // 存值
 Optional<String> str = Optional.of("string");
 // 取值
 System.out.println(str.get());
 
 // 判断Optional中是否有值
 str.isPresent();
 // 判断其是否有值。如果有进行括号中的操作
 str.ifPresent(...)
 // 我们就利用上面这个特性来尝试解决空指针异常
 
 class Person {
     private String name;
	 public String getName() {
        return name;
    }
}

public class Test {
    public static void main(String[] args) {
        Optional.of(new Person())
                .map(Person::getName)
                .ifPresent(System.out::println);
    }
}
 
 // 上面的写法就能实现，如果name不为空，将name直接打印出来，否则将不进行任何操作。这样，就省去了非空判断的操作，简单明了。
</pre>
第一次接触Optional这个名词是来自Swift，Swift在实现这个功能的时候更加的优雅，美观。同样的例子，我们用Swift来实现一遍
<pre>
class Person {
    var name:String?
    func getName() -> String {
        return name!
    }
}

var p:Person = Person()
print(p.name)
// 上面的代码将直接打印出nil
// 变量后面添加？表示该对象是一个可选值
// 添加！表示获取可选值里面的对象，专业名词叫做UnWrap(解封装)

// 上面的例子还不足以看出Swift是如何解决空指针异常的，让我们通过另外一个例子来看一下它是如何避免出现空指针异常的
class Eye {
    var color:String? = "red"
    func getColor() -> String {
        return color!
    }
}

class Fish {
    var eye:Eye?
    func getEye() -> Eye {
        return eye!
    }
}

var fish:Fish = Fish()
print(fish.eye?.color)
// 这里依然会打印出nil字符串
// 可以看到如果Swift发现可选对象为空，后面获取对象中属性的方法将不会执行，从而避免了空指针异常的发生，其解决方案和Java8是一致的，只是实现方式上更加优雅。
</pre>
看了上面的介绍，你更喜欢Java8的实现方式还是Swift语言呢？不妨在评论里面告诉我。

# 更好的interface
Java8以前如果在一个类中既要存在抽象方法，又要存在已实现方法，必须使用抽象类实现。而Java8终于开始在接口中进行方法实现了，它使用**default**关键字

<pre>
interface Java8 {
    void abstractMethod();
    
    default void defaultMethod() {
        System.out.print("This is default method in interface");
    }
}

// 通过这种方式，Java语言也可以轻松实现类似C++语言的多重继承了。But forget it...
</pre>

# Stream
**stream**通过Stream，结合闭包。我们可以轻松实现很多在Java8之前很难实现的功能。例如：排序，过滤等
<pre>
        List<String> list = Arrays.asList("Java","Swift","Cpp","C#");
        // 排序,字母长度由长到短
        list.stream().sorted((a1,a2) -> a2.length() - a1.length()).forEach(System.out::println);
        // 过滤,保留包含字母C的所有元素
        list.stream().filter(value -> value.contains("C")).forEach(System.out::println);
</pre>

# more
Java8提供的新特性还远不止这些，以上特性是我认为最值得跟大家分享，也最值得为人所称道的。如果你想了解更多的Java8新特性，请参考Oracle官方Java8文档。如果你对这篇文章有任何自己的见解，请在文章下方留言，分享你对Java8语言的看法，我在这里期待你的发言哦！

# 总结
从Java7到Java8，从Sun到Oracle，我们看到了Java语言的巨变。它开始接受新语言新思想的洗礼，开始融入Swift等现代编程语言的大家庭；它开始变得谦虚起来，不再高高在上；它开始变得更加美丽，更加让人爱不释手。不管，Java语言的过去如何，也不管Java语言花落谁家，至少我们知道它在进步。这也让我对Java9抱有更大的期待，我期待着它给Java程序员们带来更大的惊喜。


# 参考文档
[http://winterbe.com/blog/](http://winterbe.com/blog/)




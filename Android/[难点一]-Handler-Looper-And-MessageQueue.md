# 前言
Handler,Looper,MessageQueue是在Android开发中使用频率非常高的三个类，也是困扰了我很久的一个难题，我一直想试图搞清楚他们之间的逻辑关系，所以，我把这篇文章放在了Android难点系列的第一篇，希望和我一样对这三个类有疑问的同学能够从中获得些许启发。另外，笔者水平有限，如果文章中有说的不对的地方，请不吝赐教。如果你有不同的见解，也请在文章的下方评论中告诉我。

# Why
可能很多人会说，Handler每天都在用，从来没觉得它难啊？

是的，你的确每天都在用。可是，你是否可以准确地回答下面的三个问题：
* 他们是如何实现线程之间通信的呢？
* 子线程可以往主线程发送消息。那主线程是否可以主动给子线程发送消息？如果能，怎么做？
* 这样的设计有什么好处？

其实，很少有人可以准确地回答我上面提到的三个问题；在我最近实际面试的几位同学中，甚至极少有同学能够准确地告诉我它的用法；其中，我印象比较深刻的一个面试者，他说他看过这部分的源码；可以给我详述整个消息循环的过程；可是，等他洋洋洒洒全部说完；我问了一句：请问ThreadLocal是做什么的？他犹豫了一下，告诉我，“本地线程”；那它到底是做什么的呢？实现了什么功能？它沉默了一会，答到：不知道。

看过源码？却不知道ThreadLocal，看来只是走马观花而已！
其实ThreadLocal恰恰是连接这三者的灵魂人物，在接下来的文章中，我将会详细介绍ThreadLocal的原理及其用法。

# 目的
这篇文章主要从Java语言层面去解释以下三个问题，部分可能会涉及C++代码：

* 他们是如何实现线程之间通信的
* ThreadLocal的实现原理及其作用
* Android系统工程师为什么要这样设计

为了解答上面三个问题，我们将从源码角度来进行跟踪解释；

我们开始第一个问题，要解答第一个问题。首先，我们要知道一个很重要的预备知识--->ThreadLocal

# ThreadLocal
在Java开发中，可能很少会接触到这个类。但其实经常进行多线程开发的同学可能会用到过这个类，有关于这个类的用途网上说法不一，笔者今天将从源码角度还原事情的真相！

**ThreadLocal** 这个类比较准确的翻译应该是线程局部变量，为什么这样说呢？因为这个类的设计初衷其实就是为了简化多线程访问的数据同步问题，防止线程间数据访问的相互影响。
它的设计思路是：
每个线程都建立自己的局部变量，他们互不影响；多个线程共享一个ThreadLocal实例，通过ThreadLocal的set方法将对象和当前线程绑定；我们先通过一张图来看一下具体的实现细节，然后再从源码角度来证明。


![ThreadLocal](http://upload-images.jianshu.io/upload_images/703764-b9a180d62b945e68.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

从上面这张图可以看到ThreadLocal有一个内部类Values，该类中有一个table数组用于存放对应线程的局部变量，它保存变量的方式是: 偶数位存放Key，而奇数位存放对应局部变量的值。ThreadLocal中有一个非常重要的set方法用于将变量设置到当前线程中去，多个线程可以共享同一个ThreadLocal实例。通过ThreadLocal保存的线程局部变量，多线程访问互不干扰。即：在哪个线程中设置的局部变量就只有所在线程可以对其进行修改。那么，它是如何实现变量访问的线程间隔离的呢？下面我们就通过ThreadLocal的源码来一探究竟

注意：**该类所在的路径为Android SDK所在目录的java.lang包下面，不要错找成JDK下面的ThreadLocal类哈**

<pre>
    // set方法用于绑定值到当前线程
    public void set(T value) {
	    Thread currentThread = Thread.currentThread();
	    // 这里是初始化Values对象,方便存放局部变量
	    Values values = values(currentThread);
	    if (values == null) {
	        values = initializeValues(currentThread);
	    }
	    values.put(this, value);
    }
    
    // 可以看到Values方法是直接获取当前线程的localValues局部变量里面的值
    Values values(Thread current) {
    	// 这里可以知道每个线程都有一个对应的成员变量localValues，
    	// 对应ThreadLocal的Values类
       return current.localValues;
    }
    // Values是对应ThreadLocal里面的一个静态内部类，其具体实现如下：
    // 这里只保留了几处重要的实现,与文章无关的实现已经删除掉
    static class Values {
        private Object[] table;
		 // 保存对应的变量值到table数组中 	
        void put(ThreadLocal<?> key, Object value) {
	        int firstTombstone = -1;
	
	        for (int index = key.hash & mask;; index = next(index)) {
	            Object k = table[index];
				  // 注意这里：如果对应key已经存在，则只替换对应key的值即可
	            if (k == key.reference) {
	                table[index + 1] = value;
	                return;
	            }
	
	            if (k == null) {
	            	   // 第一次存值，key为空，可以看到对应数组index索引处
	            	   // 存放key，index + 1处对应存放value
	            	   // 这里的key是对应指向ThreadLocal的一个弱引用
	                if (firstTombstone == -1) {
	                    // Fill in null slot.
	                    table[index] = key.reference;
	                    table[index + 1] = value;
	                    size++;
	                    return;
	                }
	               table[firstTombstone] = key.reference;
	                table[firstTombstone + 1] = value;
	                tombstones--;
	                size++;
	                return;
	            }
	
	            if (firstTombstone == -1 && k == TOMBSTONE) {
	                firstTombstone = index;
	            }
        }
    }
 }
 
 // 再来看一下从ThreadLocal中取值的方法：
 public T get() {
    Thread currentThread = Thread.currentThread();
    Values values = values(currentThread);
    if (values != null) {
        Object[] table = values.table;
        int index = hash & values.mask;
        // 根据索引去table数组中找到指定的值并返回
        if (this.reference == table[index]) {
            return (T) table[index + 1];
        }
    } else {
        values = initializeValues(currentThread);
    }

    return (T) values.getAfterMiss(this);
}
</pre>

**源码总结：** 从上面的源码分析中可以知道，每一个线程都有一个localValues的成员变量用于保存当前线程的局部变量。localValues是ThreadLocal.Values类的一个实例，该类中有一个table数组用于存放指定线程的成员变量，其保存方式为：偶数位对应Key，奇数为对应Value，Key其实对应TreadLocal的一个弱引用，而Value则对应实际保存到当前线程的局部变量值。
那么，它又是如何实现线程间局部变量互不影响，并且通过当前线程获取到指定的值的呢？
这一切要归功于**Thread.currentThread()**方法，通过该方法获取当前线程，进而获取当前线程中localValues变量实例值，再通过该类的get方法获取table数组中对应的value值，亦即对应当前线程的局部变量值。这样每次获取到的恰好是当前线程的局部变量，从而实现了线程间的变量隔离。

**综上所述：****ThreadLocal**类的最终目的是实现线程间内存访问的相互隔离，即每一个线程操作自己内存的数据，而通过ThreadLocal在当前线程中也只能获取到当前线程的数据。至此，一切水落石出，如果你对此还有不同的见解，请在文章的下方评论告诉我哦！

# 消息循环
依据上面的分析，我们来看看ThreadLocal在Handler、Loooper和MessageQueue中的应用。
通常如果要在子线程中创建Handler，我们需要实现如下三个步骤：
<pre>

  // 可以看到这里使用一块独立的内存保存ThreadLocal实例
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();

    public static void prepare() {
        prepare(true);
    }

    // 依据上文针对ThreadLocal的分析，我们知道，这里其实是将Looper实例绑定
    // 到了当前线程。
    private static void prepare(boolean quitAllowed) {
        // 这里的判断是为了保证每一个线程只绑定一个Looper实例
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new Looper(quitAllowed));
    }

    // 这里可以看到在创建Looper的同时，创建了MessageQueue对象
    private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
        mThread = Thread.currentThread();
    }
</pre>
从上面的分析可以看到：Looper.prepare()其实是创建一个Looper实例并且绑定到当前线程。创建Looper实例的同时会创建MessageQueue实例。

* handler = new Handler(....) {}
这一步是在线程中创建handler实例，继续追踪源码，我们来看一下创建Handler的时候，又做了哪些初始化工作
<pre>
     // 创建任何一个Handler实例，最终都会调用该构造方法
    public Handler(Callback callback, boolean async) {
        // 这里是提示：handler尽量使用静态方式创建，否则可能会造成内存溢出	    // 至于为什么会出现内存溢出，请读者自行Google
        if (FIND_POTENTIAL_LEAKS) {
            final Class<? extends Handler> klass = getClass();
            if ((klass.isAnonymousClass() || klass.isMemberClass() || klass.isLocalClass()) &&
                    (klass.getModifiers() & Modifier.STATIC) == 0) {
                Log.w(TAG, "The following Handler class should be static or leaks might occur: " +
                        klass.getCanonicalName());
            }
        }
        // 注意：这句代码，这是整个创建逻辑的关键
        // 请看下面Looper.myLooper()的方法实现
        mLooper = Looper.myLooper();
        if (mLooper == null) {
            throw new RuntimeException(
                    "Can't create handler inside thread that has not called Looper.prepare()");
        }
        // 看完下面的分析，你已经可以知道这里获取的消息队列
        // 恰好也是绑定到当前线程的Looper中创建的消息的队列
        mQueue = mLooper.mQueue;
        mCallback = callback;
        mAsynchronous = async;
}
    // 可以看到myLooper方法其实是从ThreadLocal中将绑定到
    // 到当前线程的Looper取出来
    public static
    @Nullable
    Looper myLooper() {
        return sThreadLocal.get();
    }
    </pre>
Ok,take a rest,continue...
* handler.sendMessage(...)
根据英文意思，其实是发送消息，很多人看到这里就已经浅尝辄止了，都已经这么明确了？还要研究什么？可是，它真的是发送消息吗？Java语言中有发送消息的概念吗？据我所知，只有OC语言将方法调用叫做给对象发送消息。Anyway，我们继续，看看这里到底做了些什么

<pre>
	// 注意下面的方法是依次调用的关系
   	public final boolean sendMessage(Message msg) {
        return sendMessageDelayed(msg, 0);
    }
    public final boolean sendMessageDelayed(Message msg, long delayMillis) {
        if (delayMillis < 0) {
            delayMillis = 0;
        }
        return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
    }
	// 注意这里的MessageQueue，它是从绑定到当前线程的Looper实例中获取到的，使用的是同一个MessageQueue实例
    public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }
	 // 注意这个方法中的第一行代码，后面会用的到
    private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
    	 // 这里将msg实例的target设置为handler对象本身
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
    
    // 这是最终调用的方法，看看它到底做了什么 (MessageQueue->enqueueMessage())
     boolean enqueueMessage(Message msg, long when) {
     	 // 从这里可以看到，如果msg的target为空，或者消息正在循环处理当中，都会抛出异常
        if (msg.target == null) {
            throw new IllegalArgumentException("Message must have a target.");
        }
        if (msg.isInUse()) {
            throw new IllegalStateException(msg + " This message is already in use.");
        }
        synchronized (this) {
        	  // 这里是退出，重用机制，就不赘述了。
            if (mQuitting) {
                IllegalStateException e = new IllegalStateException(
                        msg.target + " sending message to a Handler on a dead thread");
                Log.w(TAG, e.getMessage(), e);
                msg.recycle();
                return false;
            }
			  // 下面为这个部分的核心逻辑
			  // 首先标记该消息正在使用中	
            msg.markInUse();
            msg.when = when;
            Message p = mMessages;
            boolean needWake;
            // 这里我们先简单处理，暂时关注when == 0的消息
            // 可以看到这里是将当前消息放入队头,即消息入列
            if (p == null || when == 0 || when < p.when) {
                msg.next = p;
                mMessages = msg;
                needWake = mBlocked;
            } else {
                needWake = mBlocked && p.target == null && msg.isAsynchronous();
                Message prev;
                for (;;) {
                    prev = p;
                    p = p.next;
                    if (p == null || when < p.when) {
                        break;
                    }
                    if (needWake && p.isAsynchronous()) {
                        needWake = false;
                    }
                }
                msg.next = p; // invariant: p == prev.next
                prev.next = msg;
            }

            // We can assume mPtr != 0 because mQuitting is false.
            if (needWake) {
                nativeWake(mPtr);
            }
        }
        return true;
    }
</pre>
从上面的分析可以看到：MessageQueue是一个单向链表结构，链表中保存的是Message实例的引用，handleMessage方法其实是一个消息入列的操作。所以，其实从逻辑层面来说，handleMessage其实只是将消息入列而已！那么真正处理消息的逻辑在哪里呢？继续往下，看最后一行代码!

* Looper.loop()
废话不多说，直接上源码：
<pre>
 public static void loop() {
        final Looper me = myLooper();
        // 这里是提示：开启消息循环，必须先调用prepare()方法
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
        final MessageQueue queue = me.mQueue;

        Binder.clearCallingIdentity();
        final long ident = Binder.clearCallingIdentity();
		  // 注意到这里是一个死循环，在循环中不断地从消息队列中取出消息
		  // 如果消息队列为空，退出消息循环
        for (;;) {
            Message msg = queue.next(); // might block
            if (msg == null) {
                return;
            }

            // This must be in a local variable, in case a UI event sets the logger
            Printer logging = me.mLogging;
            if (logging != null) {
                logging.println(">>>>> Dispatching to " + msg.target + " " +
                        msg.callback + ": " + msg.what);
            }
			  // 还记得msg的target对象是什么吗？如果不记得了，请参考前面的文章		     // 这里的target其实处理消息入列的Handler实例 
			  // 继续追踪Handler的dispatchMessage()方法
            msg.target.dispatchMessage(msg);

            if (logging != null) {
                logging.println("<<<<< Finished to " + msg.target + " " + msg.callback);
            }

            final long newIdent = Binder.clearCallingIdentity();
            if (ident != newIdent) {
                Log.wtf(TAG, "Thread identity changed from 0x"
                        + Long.toHexString(ident) + " to 0x"
                        + Long.toHexString(newIdent) + " while dispatching to "
                        + msg.target.getClass().getName() + " "
                        + msg.callback + " what=" + msg.what);
            }

            msg.recycleUnchecked();
        }
    }
    
    // 是不是和你想象的不太一样，为什么还会有这么多的if？
    // 其实这是对应几种不同的消息入列方式
    public void dispatchMessage(Message msg) {
    	 // msg.callback <=> handler.post(Runnable r)
    	 // 故使用post方式发送的消息，将调用handleCallback方法
    	 // 看下面可以发送是直接调用runnable的run方法
	    if (msg.callback != null) {
	        handleCallback(msg);
	    } else {
	     // 这里对应于handler = new Handler(Callback callback)
	     // 将调用传入的回调接口方法
        if (mCallback != null) {
            if (mCallback.handleMessage(msg)) {
                return;
            }
        }
        // 最终如果没有采用post方式发送消息，并且也没有在构造函数中传入回调
        // 将调用handler的handleMessage方法
        handleMessage(msg);
    }
    
     private static void handleCallback(Message message) {
        message.callback.run();
    }
}
<pre>

通过上面的分析，我们可以知道，消息入列有两种方式：

*  handler.post(Runnable r)
*  handler.sendMessage(Message r)

第一种消息入列的方式最终会转换为下面的这种方式，Runnable实例最终会封装为Message对象，而其自身将作为Message的回调属性。所以，在dispatchMessage的时候，需要先检查msg.callback是否为空，如果不为空则是采用第一种消息入列的方式发送消息的，这种方式回调将直接调用Runnable实例的run方法。第二种回调方法是直接回调创建Handler实例传入的Callback回调接口，调用其handleMessage方法，这里要区分为两种情况，如果其回调接口方法handleMessage返回true，Handler对象的handleMessage将不再被调用。反之，将继续调用其自身的handleMessage方法，由此可以看出，三种回调方式的优先级是：Runnable > Callback > handleMessage

下面我们用一张图来描述整个过程：

![消息循环](http://upload-images.jianshu.io/upload_images/703764-dd32227748e5d966.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这张图描述了整个消息发送，处理的过程，图中假设是使用handler的sendMessage方法发送消息，采用其他方式发送消息类似。上图中隐含的一个重要知识就是ThreadLocal，这在文章的开头部分已经详细介绍过。通过ThreadLocal可以实现变量和线程的绑定，即Looper实例和线程的绑定，而Looper类中有一个叫MessageQueue的成员变量，在创建Looper的时候也会被实例化，从而进一步实现了当前线程和MessageQueue的绑定，故使用handler的sendMessage方法发送消息，也就是消息入列，每次加入到当前线程的消息队列中。至此处理消息循环的Looper实例就会针对当前线程的消息队列进行处理。这里得出一个很重要的结论：要想让当前线程处理消息，只需要把消息存入到当前线程的消息队列中即可，也就是调用当前线程中实例化的handler实例的sendMessage方法即可。

# 扩展
鉴于文章的重点以及研究的深度，文章中并未涉及异步消息，消息入列的顺序，消息循环唤醒等问题，如果以后有时间研究，将作为这篇的扩展类文章发表，尽请期待！

# 总结
看到这里，你是否可以解答文章开头提的问题了呢？下面我们来逐一解答！

* 他们是如何实现线程之间通信的

通过Handler实例将消息加入到当前线程的队列中，再通过当前线程的Looper实例开启消息循环，在消息循环中进行消息的分发，最终交给Handler实例的回调分发进行处理

* ThreadLocal的实现原理及其作用
ThreadLocal的原理在文章的开头部分已经解释的很清楚了，就不赘述了。而其作用是实现线程间变量访问的隔离。

* Android系统工程师为什么要这样设计

Android系统通过消息循环机制的设置，轻松地实现了数据和操作的隔离，同时也避免了多线程访问带来的同步问题，更进一步说，它奠定了整个Android系统的事件驱动基础。

这里还有一个很重要的问题要说明：
一定有人会疑问为什么在主线程中发送消息不用调用prepare和loop方法，这其实是因为Android系统在主线程已经显式地调用了这些方法，故我们不需要再次调用，只需要直接发送消息即可。

最后，我们用一个形象的比喻来结束今天的文章：
MessageQueue好比是一个工厂的流水线
Handler就像是一个工厂的工人不断地将产品放到流水线上
而Looper则是操作的机器，负责将流水线上的产品逐一取出，继续交给工人进行处理

最后，谢谢大家耐心地看完这篇文章，这篇文章会同步到我的Github仓库，同时我会写一个简单的例子，实现主线程和子线程消息的互通，我的Github仓库地址：(简书)[]

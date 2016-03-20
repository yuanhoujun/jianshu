
// 类和结构体

// 基本定义方式
class A {
    var p1:String?
    var p2:String?
    
    func f() {
      print("这是类的定义")
    }
}

struct A1 {
    var p1:String?
    var p2:String?
    
    func f() {
        print("这是结构体的定义")
    }
}

// 不同点
class B1 {
    var x:Int?
    var y:Int?
    
    init() {
        print("初始化方法,初始化时调用")
    }
    
    deinit {
        print("反初始化方法，释放资源时调用")
    }
    
    func f() {
        print("B1->f()")
    }
}

class B2 : B1 {
    override func f() {
        print("B2->f()")
    }
}

let b1:B1 = B2()
b1.f()

struct B11 {
    var x:Int?
    var y:Int?
    
    init() {
        print("初始化方法,初始化时调用")
    }
    
    // 没有deInit方法
//    deinit {
//        
//    }
}

// 不支持继承
//struct B12 : B11 {
//
//}

// 编译器为二者自动生成初始化函数
class C1 {
    var a:String?
    var b:String?
}

struct C11 {
    var a:String?
    var b:String?
}

let c1:C1 = C1()
c1.a = "a"
let c11:C11 = C11(a: "a", b: "b")

// 类实例是引用类型
// 改变c2实例的值也会改变c1的值
let c2:C1 = c1
print("a=\(c1.a!)")
c2.a = "aaa"
print("a=\(c1.a!)")
// 结构体实例是值类型
// 改变c22的值不会改变c11的值
var c22:C11 = c11
print("a=\(c11.a!)")
c22.a = "aaa"
print("a=\(c11.a!)")









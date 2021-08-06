import UIKit

//: 通过基础算数类型进行初始化
Decimal(5)
Decimal(5.0)
//: 通过 字符串进行初始化
let a = "100"
let b = "3.33"
let da = Decimal(string: a)!
let db = Decimal(string: b)!

//: 内部实现了自定义的操作符进行运算
da + db
da - db
da * db
var divisionResult = da / db
// 保留小数位
var result: Decimal = Decimal()
// 下面将 divisionResult 保留两位小数, .plan 执行四舍五入
NSDecimalRound(&result, &divisionResult, 2, .plain)
result

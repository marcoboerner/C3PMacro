import C3PMacro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

@SlopeSubset
enum MyEnum {
    case first
    case second
    case third
}

let value = 5
switch value {
case 1...10:
    print("\(value) in 1...10")

case 0:
    print("\(value) in 0")

case 10:
    print("\(value) in 10")
default:
    print("\(value) in nothing")
}
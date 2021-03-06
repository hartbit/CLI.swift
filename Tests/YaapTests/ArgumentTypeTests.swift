import XCTest
@testable import Yaap

class ArgumentTypeTests: XCTestCase {
    func testStringNoValue() {
        var arguments: [String] = []
        XCTAssertThrowsError(try String(arguments: &arguments), equals: ParseError.missingArgument)
    }

    func testStringValidValue() {
        var arguments = ["hello", "world"]
        XCTAssertEqual(try String(arguments: &arguments), "hello")
        XCTAssertEqual(arguments, ["world"])
    }

    func testBoolNoValue() throws {
        var arguments: [String] = []
        XCTAssertThrowsError(try Bool(arguments: &arguments), equals: ParseError.missingArgument)
    }

    func testBoolInvalidValue() {
        var arguments = ["0"]
        XCTAssertThrowsError(try Bool(arguments: &arguments), equals: ParseError.invalidFormat("0"))
        arguments = ["hello"]
        XCTAssertThrowsError(try Bool(arguments: &arguments), equals: ParseError.invalidFormat("hello"))
    }

    func testBoolValidValue() {
        var arguments = ["true", "false"]
        XCTAssertTrue(try Bool(arguments: &arguments))
        XCTAssertEqual(arguments, ["false"])

        arguments = ["false", "hello"]
        XCTAssertFalse(try Bool(arguments: &arguments))
        XCTAssertEqual(arguments, ["hello"])
    }

    func testIntegersNoValue() {
        var arguments: [String] = []
        XCTAssertThrowsError(try Int(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Int8(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Int16(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Int32(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Int64(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try UInt(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try UInt8(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try UInt16(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try UInt32(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try UInt64(arguments: &arguments), equals: ParseError.missingArgument)
    }

    func testIntegersInvalidValue() {
        var arguments = ["two"]
        XCTAssertThrowsError(try Int(arguments: &arguments), equals: ParseError.invalidFormat("two"))
        XCTAssertEqual(arguments, ["two"])

        arguments = ["-129"]
        XCTAssertThrowsError(try Int8(arguments: &arguments), equals: ParseError.invalidFormat("-129"))
        XCTAssertEqual(arguments, ["-129"])

        arguments = ["4834984935"]
        XCTAssertThrowsError(try Int16(arguments: &arguments), equals: ParseError.invalidFormat("4834984935"))
        XCTAssertEqual(arguments, ["4834984935"])

        arguments = ["really"]
        XCTAssertThrowsError(try Int32(arguments: &arguments), equals: ParseError.invalidFormat("really"))
        XCTAssertEqual(arguments, ["really"])

        arguments = ["2.6"]
        XCTAssertThrowsError(try Int64(arguments: &arguments), equals: ParseError.invalidFormat("2.6"))
        XCTAssertEqual(arguments, ["2.6"])

        arguments = ["three"]
        XCTAssertThrowsError(try UInt(arguments: &arguments), equals: ParseError.invalidFormat("three"))
        XCTAssertEqual(arguments, ["three"])

        arguments = ["-2"]
        XCTAssertThrowsError(try UInt8(arguments: &arguments), equals: ParseError.invalidFormat("-2"))
        XCTAssertEqual(arguments, ["-2"])

        arguments = ["10e45"]
        XCTAssertThrowsError(try UInt16(arguments: &arguments), equals: ParseError.invalidFormat("10e45"))
        XCTAssertEqual(arguments, ["10e45"])

        arguments = ["totally"]
        XCTAssertThrowsError(try UInt32(arguments: &arguments), equals: ParseError.invalidFormat("totally"))
        XCTAssertEqual(arguments, ["totally"])

        arguments = ["big"]
        XCTAssertThrowsError(try UInt64(arguments: &arguments), equals: ParseError.invalidFormat("big"))
        XCTAssertEqual(arguments, ["big"])
    }

    func testIntegersValidValue() {
        var arguments = ["4", "-128", "58", "95", "-29", "4", "128", "58", "95", "29", "other"]
        XCTAssertEqual(try Int(arguments: &arguments), 4)
        XCTAssertEqual(arguments, ["-128", "58", "95", "-29", "4", "128", "58", "95", "29", "other"])
        XCTAssertEqual(try Int8(arguments: &arguments), -128)
        XCTAssertEqual(arguments, ["58", "95", "-29", "4", "128", "58", "95", "29", "other"])
        XCTAssertEqual(try Int16(arguments: &arguments), 58)
        XCTAssertEqual(arguments, ["95", "-29", "4", "128", "58", "95", "29", "other"])
        XCTAssertEqual(try Int32(arguments: &arguments), 95)
        XCTAssertEqual(arguments, ["-29", "4", "128", "58", "95", "29", "other"])
        XCTAssertEqual(try Int64(arguments: &arguments), -29)
        XCTAssertEqual(arguments, ["4", "128", "58", "95", "29", "other"])
        XCTAssertEqual(try UInt(arguments: &arguments), 4)
        XCTAssertEqual(arguments, ["128", "58", "95", "29", "other"])
        XCTAssertEqual(try UInt8(arguments: &arguments), 128)
        XCTAssertEqual(arguments, ["58", "95", "29", "other"])
        XCTAssertEqual(try UInt16(arguments: &arguments), 58)
        XCTAssertEqual(arguments, ["95", "29", "other"])
        XCTAssertEqual(try UInt32(arguments: &arguments), 95)
        XCTAssertEqual(arguments, ["29", "other"])
        XCTAssertEqual(try UInt64(arguments: &arguments), 29)
        XCTAssertEqual(arguments, ["other"])
    }

    func testFloatingPointsNoValue() {
        var arguments: [String] = []
        XCTAssertThrowsError(try Float(arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Double(arguments: &arguments), equals: ParseError.missingArgument)
    }

    func testFloatingPointsInvalidValue() {
        var arguments = ["two"]
        XCTAssertThrowsError(try Float(arguments: &arguments), equals: ParseError.invalidFormat("two"))
        XCTAssertEqual(arguments, ["two"])

        arguments = ["74eff"]
        XCTAssertThrowsError(try Double(arguments: &arguments), equals: ParseError.invalidFormat("74eff"))
        XCTAssertEqual(arguments, ["74eff"])
    }

    func testFloatingPointsValidValue() {
        var arguments = ["2.5", "56", "5e10", "7.84394", "hello", "world"]
        XCTAssertEqual(try Float(arguments: &arguments), 2.5)
        XCTAssertEqual(arguments, ["56", "5e10", "7.84394", "hello", "world"])
        XCTAssertEqual(try Float(arguments: &arguments), 56)
        XCTAssertEqual(arguments, ["5e10", "7.84394", "hello", "world"])
        XCTAssertEqual(try Double(arguments: &arguments), 5e10)
        XCTAssertEqual(arguments, ["7.84394", "hello", "world"])
        XCTAssertEqual(try Double(arguments: &arguments), 7.84394)
        XCTAssertEqual(arguments, ["hello", "world"])
    }

    func testCollectionsNoValue() {
        var arguments: [String] = []
        XCTAssertThrowsError(try [String](arguments: &arguments), equals: ParseError.missingArgument)
        XCTAssertThrowsError(try Set<Int>(arguments: &arguments), equals: ParseError.missingArgument)
    }

    func testCollectionsInvalidValue() {
        var arguments = ["invalid"]
        XCTAssertThrowsError(try [Int](arguments: &arguments), equals: ParseError.invalidFormat("invalid"))
        XCTAssertEqual(arguments, ["invalid"])

        arguments = ["5", "not"]
        XCTAssertThrowsError(try Set<Float>(arguments: &arguments), equals: ParseError.invalidFormat("not"))
        XCTAssertEqual(arguments, ["not"])
    }

    func testCollectionsValidValue() {
        var arguments = ["hello", "world", "!"]
        XCTAssertEqual(try [String](arguments: &arguments), ["hello", "world", "!"])
        XCTAssertEqual(arguments, [])

        arguments = ["4", "-2", "8", "-2"]
        XCTAssertEqual(try Set<Int>(arguments: &arguments), Set([4, -2, 8]))
        XCTAssertEqual(arguments, [])
    }
}

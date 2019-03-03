import XCTest
@testable import Yaap

class OptionTests: XCTestCase {
    func testInitializer() {
        let option1 = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        XCTAssertNil(option1.name)
        XCTAssertNil(option1.shorthand)
        XCTAssertEqual(option1.defaultValue, 42)
        XCTAssertNil(option1.documentation)

        let option2 = Option<String>(
            name: "option",
            shorthand: "o",
            defaultValue: "default",
            documentation: "Super documentation")
        XCTAssertEqual(option2.name, "option")
        XCTAssertEqual(option2.shorthand, "o")
        XCTAssertEqual(option2.defaultValue, "default")
        XCTAssertEqual(option2.documentation, "Super documentation")
    }

    func testPriority() {
        let option1 = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        XCTAssertEqual(option1.priority, 0.75)

        let option2 = Option<Int>(name: "option", shorthand: "o", defaultValue: 42, documentation: "Some documentation")
        XCTAssertEqual(option2.priority, 0.75)
    }

    func testUsage() {
        let option1 = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        option1.setup(withLabel: "label")
        XCTAssertEqual(option1.usage, "[options]")

        let option2 = Option<Int>(name: "option", shorthand: "o", defaultValue: 42, documentation: "Some documentation")
        option2.setup(withLabel: "label")
        XCTAssertEqual(option2.usage, "[options]")
    }

    func testHelp() {
        let option1 = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        option1.setup(withLabel: "label")
        XCTAssertEqual(option1.info, [
            PropertyInfo(
                category: "OPTIONS",
                label: "--label",
                documentation: "[default: 42]")
        ])

        let option2 = Option<Int>(name: "option", shorthand: nil, defaultValue: 0)
        option2.setup(withLabel: "label")
        XCTAssertEqual(option2.info, [
            PropertyInfo(
                category: "OPTIONS",
                label: "--option",
                documentation: "[default: 0]")
        ])

        let option3 = Option<String>(name: "output", shorthand: "o", defaultValue: "./")
        option3.setup(withLabel: "label")
        XCTAssertEqual(option3.info, [
            PropertyInfo(
                category: "OPTIONS",
                label: "--output, -o",
                documentation: "[default: ./]")
        ])

        let option4 = Option<Bool>(
            name: "verbose",
            shorthand: nil,
            defaultValue: true,
            documentation: "Awesome documentation")
        option4.setup(withLabel: "label")
        XCTAssertEqual(option4.info, [
            PropertyInfo(
                category: "OPTIONS",
                label: "--verbose",
                documentation: "Awesome documentation [default: true]")
        ])
    }

    func testParseNoArguments() throws {
        let option = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        option.setup(withLabel: "label")
        var arguments: [String] = []
        XCTAssertFalse(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, 42)
    }

    func testParseNoStart() throws {
        let option = Option<Int>(name: nil, shorthand: nil, defaultValue: 42)
        option.setup(withLabel: "label")

        var arguments = ["one", "2", "3.0"]
        XCTAssertFalse(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, 42)
        XCTAssertEqual(arguments, ["one", "2", "3.0"])

        arguments = ["--other", "2"]
        XCTAssertFalse(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, 42)
        XCTAssertEqual(arguments, ["--other", "2"])

        arguments = ["-o", "test"]
        XCTAssertFalse(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, 42)
        XCTAssertEqual(arguments, ["-o", "test"])
    }

    func testParseNoValue() throws {
        let option = Option<Int>(name: "option", shorthand: "o", defaultValue: 42)
        option.setup(withLabel: "label")

        var arguments = ["--option"]
        XCTAssertThrowsError(
            try option.parse(arguments: &arguments),
            equals: OptionMissingValueError(option: "--option"))

        arguments = ["-o"]
        XCTAssertThrowsError(
            try option.parse(arguments: &arguments),
            equals: OptionMissingValueError(option: "-o"))

        let error = OptionMissingValueError(option: "--option")
        XCTAssertEqual(error.errorDescription, """
            option '--option' missing a value; provide one with '--option <value>' or '--option=<value>'
            """)
    }

    func testParseInvalidValue() throws {
        let option = Option<Int>(name: "option", shorthand: "o", defaultValue: 42)
        option.setup(withLabel: "label")

        var arguments = ["--option", "two"]
        XCTAssertThrowsError(
            try option.parse(arguments: &arguments),
            equals: OptionInvalidFormatError(option: "--option", value: "two"))

        arguments = ["-o", "2.4"]
        XCTAssertThrowsError(
            try option.parse(arguments: &arguments),
            equals: OptionInvalidFormatError(option: "-o", value: "2.4"))

        let error = OptionInvalidFormatError(option: "--option", value: "invalid-value")
        XCTAssertEqual(error.errorDescription, "invalid format 'invalid-value' for option '--option'")
    }

    func testParseValidValue() throws {
        let option1 = Option<Int>(name: "option", shorthand: "o", defaultValue: 42)
        option1.setup(withLabel: "label")

        var arguments = ["--option", "6", "8"]
        XCTAssertTrue(try option1.parse(arguments: &arguments))
        XCTAssertEqual(option1.value, 6)
        XCTAssertEqual(arguments, ["8"])

        arguments = ["-o", "78"]
        XCTAssertTrue(try option1.parse(arguments: &arguments))
        XCTAssertEqual(option1.value, 78)
        XCTAssertEqual(arguments, [])

        let option2 = Option<Int>(defaultValue: 8)
        option2.setup(withLabel: "label")

        arguments = ["--label", "23"]
        XCTAssertTrue(try option2.parse(arguments: &arguments))
        XCTAssertEqual(option2.value, 23)
        XCTAssertEqual(arguments, [])

        arguments = ["-l", "98"]
        XCTAssertFalse(try option2.parse(arguments: &arguments))
        XCTAssertEqual(option2.value, 8)
        XCTAssertEqual(arguments, ["-l", "98"])
    }

    func testParseBoolean() throws {
        let option = Option<Bool>(name: "option", shorthand: "o")
        option.setup(withLabel: "label")

        var arguments = ["--option", "other"]
        XCTAssertTrue(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, true)
        XCTAssertEqual(arguments, ["other"])

        arguments = ["-o"]
        XCTAssertTrue(try option.parse(arguments: &arguments))
        XCTAssertEqual(option.value, true)
        XCTAssertEqual(arguments, [])
    }

    func testParseUpToNextOptional() throws {
        let option1 = Option<String>(name: "option", shorthand: "o", defaultValue: "something")

        var arguments = ["--option", "-v"]
        XCTAssertThrowsError(
            try option1.parse(arguments: &arguments),
            equals: OptionMissingValueError(option: "--option"))

        let option2 = Option<[String]>(name: "option", shorthand: "o", defaultValue: [])

        arguments = ["--option", "one", "two", "--other", "three"]
        XCTAssertTrue(try option2.parse(arguments: &arguments))
        XCTAssertEqual(option2.value, ["one", "two"])
        XCTAssertEqual(arguments, ["--other", "three"])
    }

    func testParseMultipleFlags() throws {
        let option1 = Option<Bool>(name: "option", shorthand: "o")

        var arguments = ["-ab"]
        XCTAssertFalse(try option1.parse(arguments: &arguments))
        XCTAssertEqual(option1.value, false)
        XCTAssertEqual(arguments, ["-ab"])

        arguments = ["-oxy"]
        XCTAssertTrue(try option1.parse(arguments: &arguments))
        XCTAssertEqual(option1.value, true)
        XCTAssertEqual(arguments, ["-xy"])

        let option2 = Option<String>(name: "option", shorthand: "o", defaultValue: "default")

        arguments = ["-oxy"]
        XCTAssertThrowsError(
            try option2.parse(arguments: &arguments),
            equals: OptionMissingValueError(option: "-o"))
    }
}

import XCTest
@testable import Yaap

class SubCommandTests: XCTestCase {
    func testPriority() {
        let subCommand = SubCommand(commands: [])
        XCTAssertEqual(subCommand.priority, 0.25)
    }

    func testUsage() {
        let subCommand = SubCommand(commands: [])
        subCommand.setup(withLabel: "label")
        XCTAssertEqual(subCommand.usage, "label")
    }

    func testHelp() {
        let subCommand = SubCommand(commands: [
            DummyCommand(name: "edit", documentation: "The documentation for edit"),
            DummyCommand(name: "unedit", documentation: "The documentation for unedit"),
            DummyCommand(name: "random", documentation: "")
        ])

        subCommand.setup(withLabel: "label")
        XCTAssertEqual(subCommand.info, [
            PropertyInfo(category: "SUBCOMMANDS", label: "edit", documentation: "The documentation for edit"),
            PropertyInfo(category: "SUBCOMMANDS", label: "random", documentation: ""),
            PropertyInfo(category: "SUBCOMMANDS", label: "unedit", documentation: "The documentation for unedit")
        ])
    }

    func testParseNoArguments() {
        let subCommand = SubCommand(commands: [
            DummyCommand(name: "edit"),
            DummyCommand(name: "unedit"),
            DummyCommand(name: "random")
        ])

        subCommand.setup(withLabel: "label")

        var arguments: [String] = []
        XCTAssertThrowsError(try subCommand.parse(arguments: &arguments), equals: SubCommandMissingError())
    }

    func testParseInvalidValue() {
        let subCommand = SubCommand(commands: [
            DummyCommand(name: "edit"),
            DummyCommand(name: "unedit"),
            DummyCommand(name: "random")
        ])

        subCommand.setup(withLabel: "label")

        var arguments = ["incorrect"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "incorrect", suggestion: nil))

        arguments = ["edits"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "edits", suggestion: "edit"))

        arguments = ["undit"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "undit", suggestion: "unedit"))

        arguments = ["unnedit"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "unnedit", suggestion: "unedit"))
    }

    func testParseValidCommand() throws {
        let mockCommand = MockCommand()
        let subCommand = SubCommand(commands: [mockCommand])

        subCommand.setup(withLabel: "label")

        var arguments = ["mock", "arg1", "arg2"]
        try subCommand.parse(arguments: &arguments)
        XCTAssert(subCommand.value === mockCommand)
        XCTAssertEqual(mockCommand.arguments, ["arg1", "arg2"])
    }
}

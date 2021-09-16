//
//  NaughtyStrings.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Some more or less evil strings to potentially cause troule of different types
///
/// See: [Big List of Naughty Strings]( https://github.com/minimaxir/big-list-of-naughty-strings)
struct BLNS {
    /// A small  subset of the blns
    static let testStrings = [
        "\\",
        "\\\\",
        "$USER",
        "/dev/null; touch /tmp/blns.fail ; echo",
        "`+\"`\"+`touch /tmp/blns.fail`+\"`\"+`",
        "$(touch /tmp/blns.fail)",
        "@{[system \\\"touch /tmp/blns.fail\\\"]}",
        "eval(\\\"puts 'hello world'\\\")",
        "System(\\\"ls -al /\\\")",
        "`+\"`\"+`ls -al /`+\"`\"+`",
        "Kernel.exec(\\\"ls -al /\\\")",
        "Kernel.exit(1)",
        "%x('ls -al /')",
        "<?xml version=\\\"1.0\\\" encoding=\\\"ISO-8859-1\\\"?><!DOCTYPE foo [ <!ELEMENT foo ANY ><!ENTITY xxe SYSTEM \\\"file:///etc/passwd\\\" >]><foo>&xxe;</foo>",
        "$HOME",
        "$ENV{'HOME'}",
        "%d",
        "%s%s%s%s%s",
        "{0}",
        "%*.*s",
        "%@",
        "%n",
        "File:///",
        "../../../../../../../../../../../etc/passwd%00",
        "../../../../../../../../../../../etc/hosts",
        "() { 0; }; touch /tmp/blns.shellshock1.fail;",
        "() { _; } >_[$($())] { touch /tmp/blns.shellshock2.fail; }",
        "<<< %s(un='%s') = %u",
        "+++ATH0",

        "If you're reading this, you've been in a coma for almost 20 years now. We're trying a new technique. We don't know where this message will end up in your dream, but we hope it works. Please wake up, we miss you.",
        "Roses are \\u001b[0;31mred\\u001b[0m, violets are \\u001b[0;34mblue. Hope you enjoy terminal hue",
        "But now...\\u001b[20Cfor my greatest trick...\\u001b[8m",
        "The quic\\b\\b\\b\\b\\b\\bk brown fo\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007\\u0007x... [Beeeep]",
        "Powerلُلُصّبُلُلصّبُررً ॣ ॣh ॣ ॣ冗",
        "🏳0🌈️",
        "జ్ఞ‌ా"
    ]
}

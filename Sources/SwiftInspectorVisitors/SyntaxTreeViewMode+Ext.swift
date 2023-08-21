//
//  SyntaxTreeViewMode+Ext.swift
//
//
//  Created by Pablo Cornejo on 8/21/23.
//

import SwiftSyntax

public extension SyntaxTreeViewMode {
    /// The view mode that should be used as the default for all syntax visitors.
    ///
    /// Using this variable allows to have the default centralized here
    /// so that it can be more easily changed if ever needed.
    static let visitorDefault: SyntaxTreeViewMode = .fixedUp
}

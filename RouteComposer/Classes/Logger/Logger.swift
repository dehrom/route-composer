//
// Created by Eugene Kazaev on 15/01/2018.
// Copyright (c) 2018 HBC Tech. All rights reserved.
//

import Foundation
import UIKit

/// `Logger` message representation
///
/// - info: info message
/// - `warning`: warning message
/// - error: error message
public enum LoggerMessage {

    /// info message
    case info(String)

    /// warning message
    case warning(String)

    /// error message
    case error(String)

}

/// Routing logger protocol
public protocol Logger {

    /// Will be called by the `Router` to log LoggerMessage instance
    ///
    /// - Parameter message: The `LoggerMessage` instance
    func log(_ message: LoggerMessage)

}

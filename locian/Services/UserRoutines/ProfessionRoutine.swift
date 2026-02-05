import Foundation
import Combine

/// Defines the structure for user routine data based on profession.
protocol ProfessionRoutine {
    /// Returns a dictionary where the key is the hour (0-23) and the value is a list of relevant places.
    static var data: [Int: [String]] { get }
}

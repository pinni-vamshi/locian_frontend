import Foundation
import CryptoKit

extension String {
    /// Generates an MD5 hash of the string to be used for unique filenames.
    /// This ensures that if the text or phonetics change, a new file gets downloaded automatically.
    var md5Hash: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

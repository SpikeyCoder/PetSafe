import Foundation
import Security

public final class AppSessionStore {
    private let service = "com.petsafe.session"
    private let account = "current"
    private let accessGroup: String? = nil // set if you use keychain sharing

    public init() {}

    // Generic save to support any Codable payload
    public func save<T: Codable>(_ value: T) throws {
        let data = try JSONEncoder().encode(value)
        try keychainSave(data: data)
    }

    // Generic load to a requested Codable type
    public func load<T: Codable>(as type: T.Type) throws -> T? {
        guard let data = try keychainLoad() else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    // Clear stored value
    public func clear() throws {
        try keychainDelete()
    }

    // MARK: - Keychain helpers
    private func keychainQuery() -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }

    private func keychainSave(data: Data) throws {
        var query = keychainQuery()
        // Try update first
        let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            // Add new item
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.unhandled(status: addStatus) }
        default:
            throw KeychainError.unhandled(status: status)
        }
    }

    private func keychainLoad() throws -> Data? {
        var query = keychainQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            return item as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unhandled(status: status)
        }
    }

    private func keychainDelete() throws {
        let query = keychainQuery()
        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError.unhandled(status: status)
        }
    }

    enum KeychainError: Error {
        case unhandled(status: OSStatus)
    }
}

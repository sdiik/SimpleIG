import Foundation

final class DefaultManager {
    static let shared = DefaultManager()
    private let defaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "DefaultManagerQueue", attributes: .concurrent)

    private init() {}
    
    func clear() {
        defaults.removeObject(forKey: DefaultManager.uid.raw)
    }
}

extension DefaultManager {
    struct Key<T> {
        let raw: String
        init(_ key: String) { self.raw = key }
    }
}

extension DefaultManager {
    static let uid = Key<String>("uid")
}

extension DefaultManager {
    func set<T: Codable>(_ value: T?, for key: Key<T>) {
        queue.async(flags: .barrier) {
            if let value = value {
                if value is String || value is Int || value is Bool || value is Double || value is Float {
                    self.defaults.set(value, forKey: key.raw)
                } else {
                    let data = try? JSONEncoder().encode(value)
                    self.defaults.set(data, forKey: key.raw)
                }
            } else {
                self.defaults.removeObject(forKey: key.raw)
            }
        }
    }
}

extension DefaultManager {
    func get<T: Codable>(_ key: Key<T>) -> T? {
        var result: T?
        queue.sync {
            if T.self == String.self ||
               T.self == Int.self ||
               T.self == Bool.self ||
               T.self == Double.self ||
               T.self == Float.self {

                result = defaults.object(forKey: key.raw) as? T
            } else {
                if let data = defaults.data(forKey: key.raw) {
                    result = try? JSONDecoder().decode(T.self, from: data)
                }
            }
        }
        return result
    }
}

extension DefaultManager {
    func removeAll() {
        queue.async(flags: .barrier) {
            let dictionary = self.defaults.dictionaryRepresentation()
            dictionary.keys.forEach { self.defaults.removeObject(forKey: $0) }
        }
    }
}

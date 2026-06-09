import Foundation

struct PendingRemoteDeletionStore {
    private let defaults: UserDefaults
    private let key = "pending_remote_article_deletions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func all() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func add(id: String) {
        var ids = Set(all())
        ids.insert(id)
        defaults.set(Array(ids), forKey: key)
    }

    func remove(id: String) {
        let ids = all().filter { $0 != id }
        defaults.set(ids, forKey: key)
    }
}

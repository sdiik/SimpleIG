import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SimpleIG")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Failed to save CoreData:", nserror, nserror.userInfo)
        }
    }
    
    private init() {}
}

extension CoreDataManager {
    
    func fetchUser() -> UserSaved? {
        let request: NSFetchRequest<UserSaved> = UserSaved.fetchRequest()
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch UserSaved:", error)
            return nil
        }
    }
}

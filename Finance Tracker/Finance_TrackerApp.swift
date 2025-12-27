import SwiftUI
import SwiftData

@main
struct Finance_TrackerApp: App {
    
    
    var sharedModelContainer: ModelContainer = {
        
        let schema = Schema([
            Account.self,
            Operation.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()

    var body: some Scene {
        WindowGroup {
            AccountView()
                .frame(
                    minWidth: 600, maxWidth: .infinity,
                    minHeight: 300, maxHeight: .infinity)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 800,height: 600)

    }
}

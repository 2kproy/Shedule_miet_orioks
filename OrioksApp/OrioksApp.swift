import SwiftUI

@main
struct OrioksApp: App {
    @StateObject var viewModel = OrioksViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                LoginView()
                    .environmentObject(viewModel)
            }
        }
    }
}

//
//  RecipeRealmApp.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import GoogleMobileAds

@main
struct RecipeRealmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    @State private var deepNewRecipeView: Bool = false

    // Constants for URL handling
    private let appScheme = "RecipeRealm"
    private let appHost = "app"
    private let appPath = "/recipe"

    // MARK: RecipeRealm View
    var body: some Scene {
        WindowGroup {
            ContentView(deepNewRecipeView: $deepNewRecipeView)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    handle(url: url)
                }
        }
    }

    // MARK: Open DeepLink To New Recipe View
    func handle(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == appScheme,
              components.host == appHost,
              components.path == appPath else { return }

        var recipeDetails: [String: String] = [:]
        for queryItem in components.queryItems ?? [] {
            recipeDetails[queryItem.name] = queryItem.value ?? ""
        }

        for (key, value) in recipeDetails {
            print("\(key): \(value)")
        }

        deepNewRecipeView = true
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

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
    @ObservedObject var appStates = AppStates()

    // MARK: RecipeRealm View
    var body: some Scene {
        WindowGroup {
            ContentView(deepNewRecipeView: $appStates.deepNewRecipeView)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appStates)
                .onOpenURL { url in
                    handle(url: url)
                }
        }
    }
    
    // MARK: Open DeepLink To New Recipe View
    func handle(url: URL) {
        print("Deep link activated with URL: \(url)")
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == appStates.appScheme,
              components.host == appStates.appHost,
              components.path == appStates.appPath else { return }

        var recipeDetails: [String: String] = [:]
        for queryItem in components.queryItems ?? [] {
            recipeDetails[queryItem.name] = queryItem.value ?? ""
        }

        var clipboardString = ""
        for (key, value) in recipeDetails {
//            print("\(key): \(value)")
            clipboardString += "\(key): \(value)\n"
        }
        
        appStates.deepNewRecipeView = true

        if let imageString = recipeDetails["Image"],
           let imageData = Data(base64Encoded: imageString),
           let image = UIImage(data: imageData) {
            UIPasteboard.general.setItems([
                [UIPasteboard.typeAutomatic: clipboardString],
                [UIPasteboard.typeAutomatic: image]
            ])
        } else {
            UIPasteboard.general.string = clipboardString
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //iPhone 15
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "9279d05aaca0f38b5740572b17ae0ace" ]
        //iPhone 12
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "6ee504ee7750aea70ad6ef10a5ec09e5" ]
        //iPad Air 2
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "7d4ebd112238d3f9cdd89764347d8e48" ]
        return true
    }
}

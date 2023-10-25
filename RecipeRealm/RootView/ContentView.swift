//
//  ContentView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import CoreData
import UIKit
import GoogleMobileAds

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var deepNewRecipeView: Bool
    @State private var shouldShowAd: Bool = true
    @State private var selectedTab = 0
    @ObservedObject var appStates = AppStates()

    var body: some View {
        VStack {
            if deepNewRecipeView {
                NavigationView {
                    NavigationLink("", destination: NewRecipeView(selectedTab: $selectedTab)
                        .environment(\.managedObjectContext, viewContext),
                                   isActive: $deepNewRecipeView)
                        .isDetailLink(false)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                if selectedTab == 0 {
                    RecipeHomeView()
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(appStates)
                } else if selectedTab == 1 {
                    NavigationView {
                        NewRecipeView(selectedTab: $selectedTab)
                    }
                } 
//                else if selectedTab == 2 {
//                    NavigationView {
//                        UserOptionsView()
//                    }
//                }
                
                // AdBannerView above the custom tab bar
                if shouldShowAd {
//                    1st Unit
                    AdBannerView(adUnitID: "ca-app-pub-7336849218717327/9263282007", shouldShowAd: $shouldShowAd)
//                    2nd Unit
//                    AdBannerView(adUnitID: "ca-app-pub-7336849218717327/9815199359", shouldShowAd: $shouldShowAd)
//                    Google Test Unit
//                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2435281174", shouldShowAd: $shouldShowAd)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .shadow(radius: 5)
                }
                
                TabBarView(selectedTab: $selectedTab)
                    .environmentObject(appStates)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: Content Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let recipeID = UUID().uuidString
        let recipe = Recipe(context: context)
        recipe.id = recipeID
        recipe.title = "Sample Recipe"
        recipe.cuisines = "Cuban"
        recipe.ingredients = "Ingredient 1\nIngredient 2\nIngredient 3"
        recipe.steps = "Step 1\nStep 2\nStep 3"
        recipe.prepTime = "10m"
        recipe.cookTime = "30m"
        return NavigationView {
            VStack{
                ContentView(deepNewRecipeView: .constant(false))
                    .environmentObject(AppStates())
                    .environment(\.managedObjectContext, context)
            }
        }
    }
}

// MARK: UIViewRepresentable wrapper for AdMob banner view
struct AdBannerView: View {
    let adUnitID: String
    @Binding var shouldShowAd: Bool

    var body: some View {
        GeometryReader { geometry in
            if shouldShowAd {
                GADBannerViewController(adUnitID: adUnitID, size: CGSize(width: geometry.size.width, height: 50), shouldShowAd: $shouldShowAd)
                    .frame(width: geometry.size.width, height: 50)
            }
        }
    }
}

struct GADBannerViewController: UIViewControllerRepresentable {
    let adUnitID: String
    let size: CGSize
    @Binding var shouldShowAd: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(size))
        bannerView.adUnitID = adUnitID
        let viewController = UIViewController()
        viewController.view.addSubview(bannerView)
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = viewController
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let request = GADRequest()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        bannerView.load(request)

        return viewController
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GADBannerViewDelegate {
        var parent: GADBannerViewController

        init(_ parent: GADBannerViewController) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Ad did receive")
            parent.shouldShowAd = true
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Ad failed: \(error.localizedDescription)")
            parent.shouldShowAd = false
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

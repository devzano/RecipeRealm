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
    
    // MARK: If Recognize DeepLink Else Recipe List View
    var body: some View {
        VStack {
            if deepNewRecipeView {
                NavigationView {
                    NavigationLink("", destination: NewRecipeView().environment(\.managedObjectContext, viewContext), isActive: $deepNewRecipeView)
                        .isDetailLink(false)
                }
            } else {
                RecipeListView()
                    .environment(\.managedObjectContext, viewContext)
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .overlay(
            AdBannerView(adUnitID: "ca-app-pub-7336849218717327/9263282007")
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .shadow(radius: 5)
                .offset(y: 20)
                , alignment: .bottom
        )
    }
}

// MARK: Content Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        ContentView(deepNewRecipeView: .constant(false))
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

// MARK: UIViewRepresentable wrapper for AdMob banner view
struct AdBannerView: View {
    let adUnitID: String

    var body: some View {
        GeometryReader { geometry in
            GADBannerViewController(adUnitID: adUnitID, size: CGSize(width: geometry.size.width, height: 50))
                .frame(width: geometry.size.width, height: 50)
        }
    }
}
struct GADBannerViewController: UIViewControllerRepresentable {
    let adUnitID: String
    let size: CGSize

    func makeUIViewController(context: Context) -> UIViewController {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(size))
        bannerView.adUnitID = adUnitID

        let viewController = UIViewController()
        viewController.view.addSubview(bannerView)

        bannerView.rootViewController = viewController

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let request = GADRequest()
        bannerView.load(request)

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

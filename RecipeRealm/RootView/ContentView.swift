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
    @ObservedObject var appStates = AppStates()
    @StateObject var chatModel = ChatModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            if deepNewRecipeView {
                NavigationView {
                    NavigationLink("", destination: NewRecipeView(selectedTab: $selectedTab)
                        .environment(\.managedObjectContext, viewContext),
                                   isActive: $deepNewRecipeView)
                        .isDetailLink(false)
                }.accentColor(appStates.selectedAccentColor)
            } else {
                if selectedTab == 0 {
                    RecipeHomeView()
                } else if selectedTab == 1 {
                    NewRecipeView(selectedTab: $selectedTab)
                } else if selectedTab == 2 {
                    RecipeAssistantView(cm: chatModel)
                } else if selectedTab == 3 {
                        UserOptionsView()
                }
                
                TabBarView(selectedTab: $selectedTab)
                    .environmentObject(appStates)
            }
        }
        .environment(\.managedObjectContext, viewContext)
        .environmentObject(appStates)
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

//
//  RecipeHomeView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import CoreData
import UIKit
import SafariServices
import SwiftMessages

struct RecipeHomeView: View {
    @EnvironmentObject var appStates: AppStates
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)],
        predicate: NSPredicate(format: "folder == nil"),
        animation: .default
    )
    var recipes: FetchedResults<Recipe>
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.creationDate, ascending: true)],
        animation: .default
    )
    var folders: FetchedResults<Folder>
    @State var showSearchBar = false
    @State var searchText = ""
    @State var searchingGoogle = false
    @State var googleText = ""
    @State var request:URLRequest?
    @State var isSheetPresented = false
    
    // MARK: Recipe List View
    var body: some View {
        NavigationView {
            VStack {
                if showSearchBar {
                    SearchBarView(placeholder: "search your recipes", text: $searchText)
                }
                
                if self.appStates.isColorPickerVisible {
                    CustomColorPicker(selectedAccentColor: $appStates.selectedAccentColor, isColorPickerVisible: $appStates.isColorPickerVisible)
                }
                
                if appStates.isListView {
                    CombinedRecipeListView(
                        filteredRecipes: filteredRecipes,
                        folders: folders,
                        deleteRecipes: { offsets in
                            self.deleteRecipes(offsets: offsets)
                        },
                        shareRecipe: { recipe in
                            shareRecipe(recipe: recipe)
                        }
                    )
                } else {
                    CombinedRecipeGridView(
                        filteredRecipes: filteredRecipes,
                        folders: folders,
                        deleteRecipes: { offsets in
                            self.deleteRecipes(offsets: offsets)
                        },
                        shareRecipe: { recipe in
                            shareRecipe(recipe: recipe)
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack {
                if searchingGoogle {
                    ZStack(alignment: .leading) {
                        TextField("search for recipes with Google", text: $googleText, onCommit: {
                            if !googleText.isEmpty,
                               let encodedQuery = googleText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                               let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)+recipe") {
                                request = URLRequest(url: url)
                                isSheetPresented = true
                            }
                        })
                    }
                    Button(action: {
                        searchingGoogle = false
                        googleText = ""
                        request = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                } else if let request = request {
                    WebViewWithButtonRepresentable(request: request, showScanButton: true, showCloseButton: true)
                } else {
                    Button(action: {
                        searchingGoogle = true
                    }) {
                        Image("GoogleLogo")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            }.sheet(isPresented: $isSheetPresented, onDismiss: {
                searchingGoogle = true
                request = nil
            }) {
                if let request = request {
                    WebViewWithButtonRepresentable(request: request, showScanButton: true, showCloseButton: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            },trailing: HStack {
                if !searchingGoogle {
                    Menu {
                        Button(action: {
                            self.appStates.isColorPickerVisible.toggle()
                        }) {
                            Label("Change Tint Color", systemImage: "paintbrush")
                        }
                        Button(action: {
                            appStates.isListView.toggle()
                            UserDefaults.standard.set(appStates.isListView, forKey: selectedViewKey)
                        }) {
                            Label("Toggle View", systemImage: appStates.isListView ? "square.grid.2x2.fill" : "list.bullet")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    Button(action: {
                        showAddFolderPrompt()
                    }) {
                        Label("Create A Folder", systemImage: "folder.fill.badge.plus")
                    }
                    Button(action: {
                        showSearchBar.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            })
        }
        .accentColor(appStates.selectedAccentColor)
    }
    
    private func showAddFolderPrompt() {
        let alertController = UIAlertController(title: "New Folder", message: "Enter the name for the new folder.", preferredStyle: .alert)
        alertController.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let folderName = alertController.textFields?.first?.text, !folderName.isEmpty {
                FolderView.addNewFolder(withName: folderName, in: viewContext)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        let uiColor = UIColor(appStates.selectedAccentColor)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            alertController.view.tintColor = uiColor
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: Recipe List Preview
struct RecipeHomeView_Previews: PreviewProvider {
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
                RecipeHomeView().environmentObject(AppStates())
            }
        }.environment(\.managedObjectContext, context)
    }
}

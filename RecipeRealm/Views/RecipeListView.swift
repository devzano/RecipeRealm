//
//  RecipeListView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import CoreData
import UIKit
import SafariServices
import SwiftMessages

let selectedAccentColorKey = "SelectedAccentColor"
let selectedViewKey = "SelectedView"

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Recipe.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)], animation: .default)
    private var recipes: FetchedResults<Recipe>
    @StateObject private var appStates = AppStates()
    @State private var selectedAccentColor: Color = UserDefaults.standard.color(forKey: selectedAccentColorKey) ?? .accentColor
    @AppStorage(selectedViewKey) private var selectedView: Bool = true
    @State private var isListView: Bool = UserDefaults.standard.bool(forKey: selectedViewKey)
    @State private var showSearchBar = false
    @State private var searchText = ""
    @State private var searchingGoogle = false
    @State private var googleText = ""
    @State private var request:URLRequest?
    @State private var isSheetPresented = false

    // MARK: Recipe List View
    var body: some View {
        NavigationView {
            VStack {
                if showSearchBar {
                    SearchBarView(placeholder: "search your recipes", text: $searchText)
                }
                
                if self.appStates.isColorPickerVisible {
                    CustomColorPicker(selectedAccentColor: $selectedAccentColor, isColorPickerVisible: $appStates.isColorPickerVisible)
                }
                
                if isListView {
                    List {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                HStack {
                                    if let data = recipe.imageData, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                            .frame(width: 50, height: 50)
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.gray)
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                
                                HStack {
                                    if let title = recipe.title, !title.isEmpty {
                                        Text(title)
                                    }
                                    
                                    Spacer()
                                    
                                    if let prepTime = recipe.prepTime, !prepTime.isEmpty {
                                        Image(systemName: "hands.sparkles.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.orange)
                                        Text("\(prepTime)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    if let cookTime = recipe.cookTime, !cookTime.isEmpty {
                                        Image(systemName: "flame.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.red)
                                        Text("\(cookTime)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .contextMenu {
                                    RecipeContextMenu(
                                        recipe: recipe,
                                        deleteAction: { deleteRecipes(offsets: IndexSet([recipes.firstIndex(of: recipe)!])) },
                                        shareAction: { shareRecipe(recipe: recipe) }
                                    )
                                }
                            }.listRowBackground(Color.gray.opacity(0.2))
                        }.onDelete(perform: deleteRecipes)
                    }.listStyle(InsetGroupedListStyle())
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    VStack {
                                        if let data = recipe.imageData, let image = UIImage(data: data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                                .frame(width: 100, height: 100)
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                                .frame(width: 100, height: 100)
                                        }
                                        
                                        Text(recipe.title ?? "")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            if let prepTime = recipe.prepTime, !prepTime.isEmpty {
                                                Image(systemName: "hands.sparkles.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.orange)
                                                Text("\(prepTime)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            Spacer()
                                            
                                            if let cookTime = recipe.cookTime, !cookTime.isEmpty {
                                                Image(systemName: "flame.fill")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(.red)
                                                Text("\(cookTime)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    .contextMenu {
                                        RecipeContextMenu(
                                            recipe: recipe,
                                            deleteAction: { deleteRecipes(offsets: IndexSet([recipes.firstIndex(of: recipe)!])) },
                                            shareAction: { shareRecipe(recipe: recipe) }
                                        )
                                    }
                                    .padding(10)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                        }.padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Recipes")
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
                            .frame(width: 24, height: 24)
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
                Menu {
                    Button(action: {
                        self.appStates.isColorPickerVisible.toggle()
                    }) {
                        Label("Change Tint Color", systemImage: "paintbrush")
                    }
                    
                    Button(action: {
                        isListView.toggle()
                        UserDefaults.standard.set(isListView, forKey: selectedViewKey)
                    }) {
                        Label("Toggle View", systemImage: isListView ? "square.grid.2x2.fill" : "list.bullet")
                    }
                } label: {
                    Image(systemName: "gearshape")
                }
                Button(action: {
                    showSearchBar.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                NavigationLink(destination: NewRecipeView()) {
                    Image(systemName: "plus")
                }
            })
        }.accentColor(selectedAccentColor)
    }
    
    // MARK: Filter Recipes On List
    private var filteredRecipes: [Recipe] {
        return recipes.filter {
            searchText.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.cuisines?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.prepTime?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.cookTime?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    // MARK: Delete Recipe From List
    private func deleteRecipes(offsets: IndexSet) {
        let confirmAlert = MessageView.viewFromNib(layout: .cardView)
        confirmAlert.configureTheme(.error)
        confirmAlert.configureDropShadow()
        confirmAlert.button?.setTitle("Confirm Delete", for: .normal)
        confirmAlert.buttonTapHandler = { _ in
            self.performRecipeDeletion(offsets: offsets)
        }
        confirmAlert.configureContent(title: "Confirm Deletion", body: "Are you sure you want to delete this recipe?")
        SwiftMessages.show(view: confirmAlert)
    }
    private func performRecipeDeletion(offsets: IndexSet) {
        withAnimation {
            offsets.map {
                recipes[$0]
            }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                showRecipeDeletedConfirmation()
            } catch {
                print("Unresolved error \(error)")
            }
        }
    }
    private func showRecipeDeletedConfirmation() {
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureTheme(.success)
        successMessage.configureDropShadow()
        successMessage.button?.isHidden = true
        successMessage.configureContent(title: "Success", body: "Recipe deleted successfully!")
        SwiftMessages.hideAll()
        SwiftMessages.show(view: successMessage)
    }
}

// MARK: Recipe List Preview
struct RecipeListView_Previews: PreviewProvider {
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
                RecipeListView()
            }
        }.environment(\.managedObjectContext, context)
    }
}

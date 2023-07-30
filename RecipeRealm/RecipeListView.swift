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

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Recipe.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)], animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var searchText = ""
    @State private var searchingGoogle = false
    @State private var googleText = ""
    @State private var showSearchBar = false
    @State private var request:URLRequest?
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showSearchBar {
                    SearchBarView(placeholder: "search your recipes", text: $searchText)
                }
                List {
                    ForEach(recipes.filter { searchText.isEmpty ||
                        $0.title?.localizedCaseInsensitiveContains(searchText) == true ||
                        $0.cuisines?.localizedCaseInsensitiveContains(searchText) == true ||
                        $0.prepTime?.localizedCaseInsensitiveContains(searchText) == true ||
                        $0.cookTime?.localizedCaseInsensitiveContains(searchText) == true
                    }) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack {
                                if let data = recipe.imageData, let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                        .frame(width: 50, height: 50)
                                } else if let imageURL = recipe.imageURL, !imageURL.isEmpty,
                                          let url = URL(string: imageURL) {
                                    AsyncImage(url: url) {phase in
                                        switch phase {
                                        case .empty:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 5))
                                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                        }
                                    }.frame(width: 50, height: 50)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                }
                            }
                            HStack {
                                Text(recipe.title ?? "")
                                Spacer()
                                Image(systemName: "fork.knife")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.orange)
                                Text("\(recipe.prepTime ?? "")")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.red)
                                Text("\(recipe.cookTime ?? "")")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }.contextMenu {
                                Button(action: {
                                    shareRecipe(recipe: recipe)
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }.onDelete(perform: deleteRecipes)
                }.listStyle(InsetGroupedListStyle())
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
                    WebViewWithButtonRepresentable(request: request)
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
                    WebViewWithButtonRepresentable(request: request)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            },trailing: HStack {
                Button(action: {
                    showSearchBar.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                NavigationLink(destination: NewRecipeView()) {
                    Image(systemName: "plus")
                }
            })
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map {
                recipes[$0]
            }.forEach(viewContext.delete)
            do {
                try viewContext.save()} catch {
                    print("Unresolved error \(error)")
                }
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let recipe = Recipe(context: context)
        recipe.title = "Sample Recipe"
        recipe.cuisines = "Cuban"
        recipe.ingredients = "Ingredient 1\nIngredient 2\nIngredient 3"
        recipe.steps = "Step 1\nStep 2\nStep 3"
        recipe.prepTime = "10m"
        recipe.cookTime = "30m"
        recipe.imageURL = "https://www.cook2eatwell.com/wp-content/uploads/2018/08/Vaca-Frita-Image-1.jpg"
        
        return NavigationView {
            VStack{
                RecipeListView()
            }
        }.environment(\.managedObjectContext, context)
    }
}

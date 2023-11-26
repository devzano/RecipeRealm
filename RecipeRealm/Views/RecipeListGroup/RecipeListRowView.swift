//
//  RecipeListRowView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/27/23.
//

import Foundation
import SwiftUI

struct RecipeListRowView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var appStates = AppStates()
    @State private var isShowingFolderPicker: Bool = false
    var deleteAction: () -> Void
    var shareAction: () -> Void

    var body: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return HStack {
            if let data = recipe.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                    .frame(width: isZoomed ? 75 : 50, height: isZoomed ? 75 : 50)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(width: isZoomed ? 75 : 50, height: isZoomed ? 75 : 50)
            }
            
            if let title = recipe.title, !title.isEmpty {
                Text(recipe.title ?? "")
                    .font(.system(size: textSize))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            ZStack {
                HStack {
                    if let prepTime = recipe.prepTime, !prepTime.isEmpty {
                        VStack {
                            Image(systemName: "hands.sparkles.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.orange)
                            Text("\(prepTime)")
                                .font(.system(size: textSize))
                                .foregroundColor(.primary)
                        }
                    }
                    if let cookTime = recipe.cookTime, !cookTime.isEmpty {
                        VStack {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                            Text("\(cookTime)")
                                .font(.system(size: textSize))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .contextMenu {
            ContextMenuView(recipe: recipe,
                            deleteRecipeAction: deleteAction,
                            shareRecipeAction: shareAction,
                            moveToFolderAction: {
                self.isShowingFolderPicker = true
            }, removeFromFolderAction: {
                if let currentFolder = recipe.folder {
                    currentFolder.removeFromRecipes(NSSet(object: recipe))
                }
                recipe.folder = nil
                PersistenceController.shared.saveContext()
            })
        }
        .sheet(isPresented: $isShowingFolderPicker) {
            FolderPickerView(recipe: recipe) {
                self.isShowingFolderPicker = false
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .padding(10)
        .cornerRadius(10)
    }
}

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
            RecipeListRowView(recipe: recipe, deleteAction: {}, shareAction: {})
                .environmentObject(AppStates())
                .environment(\.managedObjectContext, context)
        }
    }
}

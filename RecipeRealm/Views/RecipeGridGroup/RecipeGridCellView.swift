//
//  RecipeGridCellView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/26/23.
//

import Foundation
import SwiftUI

struct RecipeGridCellView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.sizeCategory) var sizeCategory
    var deleteAction: () -> Void
    var shareAction: () -> Void
    @State private var isShowingFolderPicker: Bool = false

    var body: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return VStack {
            if let data = recipe.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    .frame(width: isZoomed ? 100 : 120, height: isZoomed ?  100 : 120)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(width: isZoomed ? 100 : 100, height: isZoomed ? 100 : 100)
            }
            VStack {
                Text(recipe.title ?? "")
                    .font(.system(size: textSize))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack {
                    if let prepTime = recipe.prepTime, !prepTime.isEmpty {
                        Image(systemName: "hands.sparkles.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.orange)
                        Text("\(prepTime)")
                            .font(.system(size: textSize))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if let cookTime = recipe.cookTime, !cookTime.isEmpty {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.red)
                        Text("\(cookTime)")
                            .font(.system(size: textSize))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $isShowingFolderPicker) {
                FolderPickerView(recipe: recipe) {
                    self.isShowingFolderPicker = false
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
                    recipe.folder = nil
                    PersistenceController.shared.saveContext()
                }
            })
        }
        .padding(10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

// MARK: Recipe Grid Cell View
struct RecipeGridCellView_Previews: PreviewProvider {
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
            RecipeGridCellView(recipe: recipe, deleteAction: {}, shareAction: {})
        }.environment(\.managedObjectContext, context)
    }
}

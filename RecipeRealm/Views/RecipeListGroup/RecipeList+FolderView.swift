//
//  RecipeList+FolderView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/29/23.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct CombinedRecipeListView: View {
    @ObservedObject var appStates = AppStates()
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.legibilityWeight) var legibilityWeight
    
    var filteredRecipes: [Recipe]
    var folders: FetchedResults<Folder>
    var deleteRecipes: (IndexSet) -> Void
    var shareRecipe: (Recipe) -> Void
    
    func deleteFolder(folder: Folder) {
        viewContext.delete(folder)
        PersistenceController.shared.saveContext()
    }
    
    var body: some View {
        VStack {
            if !folders.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(folders, id: \.self) { folder in
                            NavigationLink(destination: FolderRecipeListView(folder: folder)) {
                                FolderListView(folderName: folder)
                            }
                            .contextMenu {
                                ContextMenuView(folder: folder, deleteFolderAction: {
                                    deleteFolder(folder: folder)
                                })
                            }
                            .onDrop(of: [UTType.plainText.identifier], delegate: FolderDropDelegate(folder: folder, viewContext: viewContext))
                        }
                    }
                    .padding()
                }
                Divider().background(appStates.selectedAccentColor)
            }
            
            List {
                ForEach(filteredRecipes, id: \.self) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeListRowView(recipe: recipe, deleteAction: {
                            deleteRecipes(IndexSet([filteredRecipes.firstIndex(of: recipe)!]))
                        }, shareAction: {
                            shareRecipe(recipe)
                        })
                    }
                    .listRowSeparator(.hidden)
                    .onDrag {
                        let idString = recipe.id ?? ""
                        return NSItemProvider(object: idString as NSString)
                    }
                }
            }
        }
    }
}

struct ListFolderImage: View {
    var images: [Image]
    
    var body: some View {
        let limitedImages = Array(images.prefix(4))
        let imageSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 55 : 35

        return VStack(spacing: 4) {
            ForEach(0..<2) { rowIndex in
                HStack(spacing: 4) {
                    ForEach(0..<2) { colIndex in
                        if limitedImages.count > (rowIndex * 2) + colIndex {
                            limitedImages[(rowIndex * 2) + colIndex]
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageSize, height: imageSize)
                                .clipped()
                                .cornerRadius(5)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? imageSize : 39, height: imageSize)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
}

struct FolderListView: View {
    @ObservedObject var folderName: Folder
    @State private var refreshView: Bool = false

    var recipeImages: [Image] {
        (folderName.recipes?.allObjects as? [Recipe] ?? []).prefix(4).compactMap {
            if let data = $0.imageData, let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack {
            if recipeImages.isEmpty {
                Image(systemName: "folder.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: isZoomed ? 40 : 70, height: isZoomed ? 20 : 50)
                    .foregroundColor(.accentColor)
            } else {
                ListFolderImage(images: recipeImages)
            }
            Text(folderName.name ?? "Unnamed Folder")
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .cornerRadius(10)
        .onChange(of: folderName.recipes, perform: { _ in
            refreshView.toggle()
        })
    }
}

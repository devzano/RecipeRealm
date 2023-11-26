//
//  FolderView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/29/23.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers
import SwiftMessages

struct FolderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Folder.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Folder.creationDate, ascending: true)]) private var folders: FetchedResults<Folder>
    @State private var newFolderName: String = ""
    @State private var showingAddFolder: Bool = false
    @State var isListView: Bool = UserDefaults.standard.bool(forKey: selectedViewKey)
    
    // MARK: Device Zoomed Check & Text Size
    var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.legibilityWeight) var legibilityWeight
    
    var body: some View {
        if isListView {
            List {
                ForEach(folders, id: \.self) { folder in
                    NavigationLink(destination: FolderRecipeListView(folder: folder)) {
                        FolderListView(folderName: folder)
                    }
                }
            }
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 16) {
                    ForEach(folders, id: \.self) { folder in
                        NavigationLink(destination: FolderRecipeGridView(folder: folder)) {
                            FolderGridView(folderName: folder)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    func deleteFolders(offsets: IndexSet) {
        withAnimation {
            offsets.map { folders[$0] }.forEach(viewContext.delete)
            PersistenceController.shared.saveContext()
        }
    }

    static func addNewFolder(withName name: String, in context: NSManagedObjectContext) {
        let newFolder = Folder(context: context)
        newFolder.id = UUID().uuidString
        newFolder.name = name
        newFolder.creationDate = Date()
        
        PersistenceController.shared.saveContext()
    }
}

struct FolderRecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var folder: Folder
    @State private var refreshRecipeID = UUID()

    var body: some View {
        List {
            ForEach(folder.recipes?.allObjects as? [Recipe] ?? [], id: \.self) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeListRowView(recipe: recipe, deleteAction: {
                        showDeleteConfirmation {
                            if (self.folder.recipes?.allObjects.firstIndex(where: { ($0 as! Recipe).id == recipe.id })) != nil {
                                if let recipes = self.folder.recipes as? Set<Recipe>, let recipeToRemove = recipes.first(where: { $0.id == recipe.id }) {
                                    self.folder.removeFromRecipes(NSSet(object: recipeToRemove))
                                }
                                self.viewContext.delete(recipe)
                                do {
                                    try self.viewContext.save()
                                    showRecipeDeletedConfirmation()
                                } catch {
                                    print("Error deleting the recipe: \(error)")
                                    showErrorDeletingMessage()
                                }
                            }
                        }
                    }, shareAction: {
                        shareRecipe(recipe: recipe)
                    })
                }.listRowSeparator(.hidden)
            }
        }
        .navigationBarTitle(folder.name ?? "Unnamed Folder", displayMode: .inline)
        .id(refreshRecipeID)
        .onAppear {
            refreshRecipeID = UUID()
        }
    }
}

struct FolderRecipeGridView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var folder: Folder
    @State private var refreshRecipeID = UUID()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 16) {
                ForEach(folder.recipes?.allObjects as? [Recipe] ?? [], id: \.self) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeGridCellView(recipe: recipe, deleteAction: {
                            showDeleteConfirmation {
                                if (self.folder.recipes?.allObjects.firstIndex(where: { ($0 as! Recipe).id == recipe.id })) != nil {
                                    if let recipes = self.folder.recipes as? Set<Recipe>, let recipeToRemove = recipes.first(where: { $0.id == recipe.id }) {
                                        self.folder.removeFromRecipes(NSSet(object: recipeToRemove))
                                    }
                                    self.viewContext.delete(recipe)
                                    do {
                                        try self.viewContext.save()
                                        showRecipeDeletedConfirmation()
                                    } catch {
                                        print("Error deleting the recipe: \(error)")
                                        showErrorDeletingMessage()
                                    }
                                }
                            }
                        }, shareAction: {
                            shareRecipe(recipe: recipe)
                        })
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitle(folder.name ?? "Unnamed Folder", displayMode: .inline)
        .id(refreshRecipeID)
        .onAppear {
            refreshRecipeID = UUID()
        }
    }
}

func showDeleteConfirmation(confirmAction: @escaping () -> Void) {
    let confirmationMessage = MessageView.viewFromNib(layout: .cardView)
    confirmationMessage.configureTheme(.error)
    confirmationMessage.configureDropShadow()
    confirmationMessage.button?.setTitle("Confirm", for: .normal)
    confirmationMessage.buttonTapHandler = { _ in
        confirmAction()
        SwiftMessages.hide()
    }
    confirmationMessage.configureContent(title: "Delete Recipe", body: "Are you sure you want to delete this recipe?")
    SwiftMessages.show(view: confirmationMessage)
}

func showRecipeDeletedConfirmation() {
    let successMessage = MessageView.viewFromNib(layout: .cardView)
    successMessage.configureTheme(.success)
    successMessage.configureDropShadow()
    successMessage.button?.isHidden = true
    successMessage.buttonTapHandler = { _ in
        SwiftMessages.hide()
    }
    successMessage.configureContent(title: "Success", body: "Recipe deleted successfully!")
    SwiftMessages.show(view: successMessage)
}

func showErrorDeletingMessage() {
    let errorMessage = MessageView.viewFromNib(layout: .cardView)
    errorMessage.configureTheme(.error)
    errorMessage.configureDropShadow()
    errorMessage.button?.setTitle("Retry", for: .normal)
    errorMessage.buttonTapHandler = { _ in
        SwiftMessages.hide()
    }
    errorMessage.configureContent(title: "Error", body: "Failed to delete the recipe.")
    SwiftMessages.show(view: errorMessage)
}

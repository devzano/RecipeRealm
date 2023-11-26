//
//  ContextMenuView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/26/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit

// MARK: ContextMenu View
struct ContextMenuView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var appStates: AppStates
    let recipe: Recipe?
    let folder: Folder?
    let deleteRecipeAction: (() -> Void)?
    let deleteFolderAction: (() -> Void)?
    let shareRecipeAction: (() -> Void)?
    let moveToFolderAction: (() -> Void)?
    let removeFromFolderAction: (() -> Void)?
    
    init(recipe: Recipe,
         deleteRecipeAction: @escaping () -> Void,
         shareRecipeAction: @escaping () -> Void,
         moveToFolderAction: @escaping () -> Void,
         removeFromFolderAction: @escaping () -> Void) {
        self.recipe = recipe
        self.folder = nil
        self.deleteRecipeAction = deleteRecipeAction
        self.shareRecipeAction = shareRecipeAction
        self.moveToFolderAction = moveToFolderAction
        self.removeFromFolderAction = removeFromFolderAction
        self.deleteFolderAction = nil
    }
        
    init(folder: Folder, deleteFolderAction: @escaping () -> Void) {
        self.folder = folder
        self.recipe = nil
        self.deleteFolderAction = deleteFolderAction
        self.deleteRecipeAction = nil
        self.shareRecipeAction = nil
        self.moveToFolderAction = nil
        self.removeFromFolderAction = nil
    }
    
    @State private var isRenameAlertPresented: Bool = false
    @State private var newFolderName: String = ""
    
    var body: some View {
        VStack {
            if let shareAction = shareRecipeAction {
                Button(action: shareAction) {
                    Label("Share Recipe", systemImage: "doc.on.doc")
                }
                Button(action: {
                    deepShareRecipe(recipe: recipe!)
                }) {
                    Label("Share Recipe Link", systemImage: "link")
                }
            }
            
            if let moveAction = moveToFolderAction, hasFolders() {
                Button(action: moveAction) {
                    Label("Move to Folder", systemImage: "folder.badge.plus")
                }
            }

            if let removeFromFolder = removeFromFolderAction, recipe?.folder != nil {
                Button(action: removeFromFolder) {
                    Label("Remove from Folder", systemImage: "folder.badge.minus")
                }
            }
            
            if let deleteRecipe = deleteRecipeAction {
                Button(role: .destructive, action: deleteRecipe) {
                    Label("Delete Recipe", systemImage: "trash")
                }
            }
            
            if let deleteFolder = deleteFolderAction {
                Button(role: .destructive, action: deleteFolder) {
                    Label("Delete Folder", systemImage: "trash")
                }
            }
            
            if folder != nil {
                Button(action: showRenameFolderPrompt) {
                    Label("Rename Folder", systemImage: "pencil")
                }
            }
        }
    }
    
    func hasFolders() -> Bool {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            let foldersCount = try viewContext.count(for: fetchRequest)
            return foldersCount > 0
        } catch {
            print("Error fetching folders: \(error)")
            return false
        }
    }
    
    func showRenameFolderPrompt() {
        guard let folder = folder else { return }
        let currentFolderName = folder.name ?? ""
        
        let alertController = UIAlertController(title: "Rename Folder", message: "Enter a new name for the folder.", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = currentFolderName
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        let saveAction = UIAlertAction(title: "Rename", style: .default) { _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                folder.name = newName
                do {
                    try viewContext.save()
                } catch {
                    print("Error renaming folder: \(error)")
                }
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

//struct RecipeContextMenu: View {
//    let recipe: Recipe
//    let deleteAction: () -> Void
//    let shareAction: () -> Void
//
//    var body: some View {
//        Button(action: shareAction) {
//            Label("Share Recipe", systemImage: "doc.on.doc")
//        }
//        Button(action: {
//            deepShareRecipe(recipe: recipe)
//        }) {
//            Label("Share Recipe Link", systemImage: "link")
//        }
//        Button(role: .destructive, action: deleteAction) {
//            Label("Delete Recipe", systemImage: "trash")
//        }
//    }
//}
//
//struct RecipeContextMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.shared.container.viewContext
//        let recipe = Recipe(context: context)
//
//        return VStack {
//            RecipeContextMenu(
//                recipe: recipe,
//                deleteAction: {},
//                shareAction: {}
//            )
//        }
//    }
//}

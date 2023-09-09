//
//  NewRecipeView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import Foundation
import SwiftUI
import UIKit
import CoreData
import PhotosUI
import MobileCoreServices
import SwiftMessages

struct NewRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var appStates = AppStates()
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var imageSearch = ""
    @State private var showWebView: Bool = false
    @State private var googleImageSearchURL: URL? = nil
    @State private var isSearchingImage = false
    @State var selectedImage: UIImage?
    // MARK: Users Inputed Recipe
    @State private var title = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var glutenFree = false
    @State private var sugarFree = false
    @State private var dairyFree = false
    @State private var gmoFree = false
    @State private var organic = false
    @State private var vegetarian = false
    @State private var selectedCuisineIndex = -1
    @State private var ingredients = ""
    @State private var steps = ""
    @State private var currentStepNumber: Int = 1
    @State private var currentBullet: String = "•"
    @State private var notes = ""
    @State private var recipeURL = ""
    // MARK: Users Imported Recipe
    @State private var isImportingData = false
    @State private var isImportingPhoto = false
    @State private var importedTitle = ""
    @State private var importedPrepTime = ""
    @State private var importedCookTime = ""
    @State private var importedGlutenFree = false
    @State private var importedSugarFree = false
    @State private var importedDairyFree = false
    @State private var importedGMOFree = false
    @State private var importedOrganic = false
    @State private var importedVegetarian = false
    @State private var importedCuisine = ""
    @State private var importedIngredients = ""
    @State private var importedSteps = ""
    @State private var importedNotes = ""
    @State private var importedURL = ""
    
    // MARK: New Recipe View
    var body: some View {
        Form {
            importSection
            recipeTitleSection
            selectedImageViewSection
            recipeTimeInfoSection
            cuisineSection
            nutritionSection
            ingredientsSection
            stepsSection
            notesSection
            recipeURLSection
        }
        .navigationTitle("New Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                addRecipe()
                if showAlert {
                    let errorMessageView = MessageView.viewFromNib(layout: .cardView)
                    errorMessageView.configureTheme(.error)
                    errorMessageView.configureDropShadow()
                    errorMessageView.button?.isHidden = true
                    errorMessageView.configureContent(title: "Blank Recipe", body: errorMessage)
                    SwiftMessages.show(view: errorMessageView)
                    showAlert = false
                }
            }) {
                Image(systemName: "plus")
            }
        })
        .sheet(isPresented: $appStates.showImagePicker) {
            ImagePickerSheetView(showImagePicker: $appStates.showImagePicker, selectedImage: $selectedImage, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
        }
    }
    
    // MARK: Import Recipe
    var dataButtonDisabled: Bool {
        return !title.isEmpty || !prepTime.isEmpty || !cookTime.isEmpty || glutenFree || sugarFree || dairyFree || gmoFree || organic || vegetarian || selectedCuisineIndex != -1 || !ingredients.isEmpty || !steps.isEmpty || !notes.isEmpty || !recipeURL.isEmpty
    }
    var photoButtonDisabled: Bool {
        return selectedImage != nil
    }
    private var importSection: some View {
        Section {
            HStack {
                Button(action: {
                    importData()
                }) {
                    Text("Import Recipe")
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.borderless)
                .disabled(dataButtonDisabled)
                
                Spacer()
                
                Button(action: {
                    importPic()
                }) {
                    Text("Import Photo")
                    Image(systemName: "photo")
                }
                .buttonStyle(.borderless)
                .disabled(photoButtonDisabled)
            }
        }
    }
    
    // MARK: Image Selection
    private var selectedImageViewSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Image")) {
            Group {
                if selectedImage == nil {
                    HStack {
                        TextField("Image Search", text: $imageSearch)
                            .onChange(of: imageSearch) { _ in
                                isSearchingImage = true
                            }
                        Button(action: {
                            showWebView.toggle()
                        }) {
                            HStack {
                                Text("Search With")
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .buttonStyle(.borderless)
                        .sheet(isPresented: $showWebView) {
                            GoogleImageSearchView(isPresented: $showWebView, searchQuery: $imageSearch)
                        }
                    }
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Photo")
                    }
                    .onTapGesture {
                        deletePhoto()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ImagePickerButton(showSourcePicker: $appStates.showSourcePicker, showImagePicker: $appStates.showImagePicker, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
                }
            }
        }.listRowSeparator(.hidden)
    }
    
    // MARK: Delete Selected Image
    private func deletePhoto() {
        let deleteAlert = MessageView.viewFromNib(layout: .cardView)
        deleteAlert.configureTheme(.warning)
        deleteAlert.configureDropShadow()
        deleteAlert.button?.setTitle("Delete", for: .normal)
        deleteAlert.buttonTapHandler = { _ in
            self.confirmPhotoDeletion()
        }
        deleteAlert.configureContent(title: "Delete Photo", body: "Are you sure you want to delete this photo?")
        SwiftMessages.show(view: deleteAlert)
    }

    private func confirmPhotoDeletion() {
        selectedImage = nil
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureTheme(.success)
        successMessage.configureDropShadow()
        successMessage.button?.isHidden = true
        successMessage.configureContent(title: "Success", body: "Photo deleted successfully!")
        SwiftMessages.hideAll()
        SwiftMessages.show(view: successMessage)
    }

    
    // MARK: Image Library Access
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                appStates.photoLibraryAuthorizationStatus = status
            }
        }
    }
    
    // MARK: Recipe Title
    private var recipeTitleSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Title")) {
            TextField("Title", text: isImportingData ? $importedTitle : $title)
        }
    }
    
    // MARK: Recipe Times
    private var recipeTimeInfoSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Prep & Cook Time")) {
            HStack(spacing: 17) {
                TextField("Prep Time", text: isImportingData ? $importedPrepTime : $prepTime)
                Divider()
                TextField("Cook Time", text: isImportingData ? $importedCookTime : $cookTime)
            }
        }
    }
    
    // MARK: Recipe Cuisines
    private var cuisineSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Cuisine")) {
            Picker("Cuisine", selection: $selectedCuisineIndex) {
                Text("Select Cuisine")
                    .foregroundColor(selectedCuisineIndex == -1 ? .gray : .primary)
                    .disabled(true)
                ForEach(0..<cuisineOptions.count, id: \.self) { index in
                    Text(cuisineOptions[index])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .pickerStyle(MenuPickerStyle())
            .onChange(of: importedCuisine) { newValue in
                if let index = cuisineOptions.firstIndex(of: newValue) {
                    selectedCuisineIndex = index
                }
            }
        }
    }
    
    // MARK: Nutrition Badges
    private var nutritionSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Nutrition Badges")) {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Toggle("Gluten-Free", isOn: isImportingData ? $importedGlutenFree : $glutenFree)
                    Toggle("Sugar-Free", isOn: isImportingData ? $importedSugarFree : $sugarFree)
                    Toggle("Dairy-Free", isOn: isImportingData ? $importedDairyFree : $dairyFree)
                }
                VStack(spacing: 8) {
                    Toggle("GMO-Free", isOn: isImportingData ? $importedGMOFree : $gmoFree)
                    Toggle("Organic", isOn: isImportingData ? $importedOrganic : $organic)
                    Toggle("Vegetarian", isOn: isImportingData ? $importedVegetarian : $vegetarian)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, 8)
        }
    }

    // MARK: Recipe Ingredients
    private var ingredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            PlaceholderTextEditorView(text: isImportingData ? $importedIngredients : $ingredients, placeholder: "(next line for new ingredient)")
                .onChange(of: isImportingData ? importedIngredients : ingredients) { newValue in
                    addBulletPoints()
                }
        }
    }
    
    //MARK: Recipe Ingredient & Note Bullet Points
    private func addBulletPoints() {
        let addedIngredients = isImportingData ? importedIngredients : ingredients
        let addedNotes = isImportingData ? importedNotes : notes
        
        var ingredientLines = addedIngredients.split(separator: "\n", omittingEmptySubsequences: false)
        var noteLines = addedNotes.split(separator: "\n", omittingEmptySubsequences: false)
        
        ingredientLines = ingredientLines.map { line in
            if !line.isEmpty {
                if !line.starts(with: currentBullet) {
                    return "\(currentBullet) \(line)"
                }
            }
            return line
        }
        
        noteLines = noteLines.map { line in
            if !line.isEmpty {
                if !line.starts(with: currentBullet) {
                    return "\(currentBullet) \(line)"
                }
            }
            return line
        }
        
        let updatedIngredientText = ingredientLines.joined(separator: "\n")
        let updatedNoteText = noteLines.joined(separator: "\n")
        
        if isImportingData {
            importedIngredients = updatedIngredientText
            importedNotes = updatedNoteText
        } else {
            ingredients = updatedIngredientText
            notes = updatedNoteText
        }
    }
    
    // MARK: Recipe Steps
    private var stepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            PlaceholderTextEditorView(text: isImportingData ? $importedSteps : $steps, placeholder: "(next line for new step)")
                .onChange(of: isImportingData ? importedSteps : steps) { newValue in
                    addStepNumbers()
                }
        }
    }
    
    // MARK: Recipe Step Numbers
    private func addStepNumbers() {
        let addedSteps = isImportingData ? importedSteps : steps
        
        var lines = addedSteps.split(separator: "\n", omittingEmptySubsequences: false)
        
        lines = lines.map { line in
            if let range = line.range(of: "^\\d+\\. ", options: .regularExpression) {
                return line[range.upperBound...]
            }
            return line
        }
        
        lines = lines.enumerated().compactMap { (index, line) -> Substring? in
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return line
            }
            let stepNumber = currentStepNumber + index
            return Substring("\(stepNumber). \(line)")
        }
        
        let updatedText = lines.joined(separator: "\n")
        
        if isImportingData {
            importedSteps = updatedText
        } else {
            steps = updatedText
        }
    }
    
    // MARK: Recipe Notes
    private var notesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
            PlaceholderTextEditorView(text: isImportingData ? $importedNotes : $notes, placeholder: "(optional)")
                .onChange(of: isImportingData ? importedNotes : notes) { newValue in
                    addBulletPoints()
                }
        }
    }
    
    // MARK: Recipe URL
    private var recipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            TextField("Recipe URL", text: isImportingData ? $importedURL : $recipeURL)
        }
    }
    
    // MARK: Add Recipe; Missing Fields
    private func addRecipe() {
        var missingFields: [String] = []
        
        let finalTitle = !importedTitle.isEmpty ? importedTitle : title
        let finalPrepTime = !importedPrepTime.isEmpty ? importedPrepTime : prepTime
        let finalCookTime = !importedCookTime.isEmpty ? importedCookTime : cookTime
        let finalGlutenFree = importedGlutenFree ? true : glutenFree
        let finalSugarFree = importedSugarFree ? true : sugarFree
        let finalDairyFree = importedDairyFree ? true : dairyFree
        let finalGMOFree = importedGMOFree ? true : gmoFree
        let finalOrganic = importedOrganic ? true : organic
        let finalVegetarian = importedVegetarian ? true : vegetarian
        let finalCuisine = !importedCuisine.isEmpty ? importedCuisine : cuisineOptions[selectedCuisineIndex]
        let finalIngredients = !importedIngredients.isEmpty ? importedIngredients : ingredients
        let finalSteps = !importedSteps.isEmpty ? importedSteps : steps
        let finalNotes = !importedNotes.isEmpty ? importedNotes : notes
        let finalURL = !importedURL.isEmpty ? importedURL : recipeURL
        
        if finalTitle.isEmpty { missingFields.append("Title") }
        if selectedCuisineIndex == -1 { missingFields.append("Cuisine") }
        if finalIngredients.isEmpty { missingFields.append("Ingredients") }
        if finalSteps.isEmpty { missingFields.append("Steps") }
        
        guard missingFields.isEmpty else {
            showAlert = true
            if missingFields.count == 1 {
                errorMessage = "Please fill in \(missingFields[0])."
            } else {
                let lastField = missingFields.removeLast()
                let joinedFields = missingFields.joined(separator: ", ")
                errorMessage = "Please fill in \(joinedFields) and \(lastField)."
            }
            return
        }
        
        let recipeID = UUID().uuidString
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = recipeID
        newRecipe.title = finalTitle
        if let image = selectedImage {
            newRecipe.imageData = image.jpegData(compressionQuality: 1.0)
        }
        newRecipe.prepTime = finalPrepTime
        newRecipe.cookTime = finalCookTime
        newRecipe.glutenFree = finalGlutenFree
        newRecipe.sugarFree = finalSugarFree
        newRecipe.dairyFree = finalDairyFree
        newRecipe.gmoFree = finalGMOFree
        newRecipe.organic = finalOrganic
        newRecipe.vegetarian = finalVegetarian
        newRecipe.cuisines = finalCuisine
        newRecipe.ingredients = finalIngredients
        newRecipe.steps = finalSteps
        newRecipe.notes = finalNotes
        newRecipe.recipeURL = finalURL

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
            let successMessage = MessageView.viewFromNib(layout: .cardView)
                successMessage.configureTheme(.success)
                successMessage.configureDropShadow()
                successMessage.button?.isHidden = true
                successMessage.configureContent(title: "Success", body: "Recipe added successfully!")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: successMessage)
        } catch {
            print("Unresolved error \(error)")
            let errorMessage = MessageView.viewFromNib(layout: .cardView)
                errorMessage.configureTheme(.error)
                errorMessage.configureDropShadow()
                errorMessage.button?.isHidden = true
                errorMessage.configureContent(title: "Error", body: "An error occurred while updating the recipe.")
                SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
                SwiftMessages.show(view: errorMessage)
        }
    }
    
    // MARK: Import Copied Recipe
    private func importData() {
        if let clipboardContent = UIPasteboard.general.string {
            var recipeFound = false
            
            var importedTitle = ""
            var importedPrepTime = ""
            var importedCookTime = ""
            var importedGlutenFree = false
            var importedSugarFree = false
            var importedDairyFree = false
            var importedGMOFree = false
            var importedOrganic = false
            var importedVegetarian = false
            var importedCuisine = ""
            var importedIngredients = ""
            var importedSteps = ""
            var importedNotes = ""
            var importedURL = ""
            
            var currentSection: String?
            for line in clipboardContent.components(separatedBy: .newlines) {
                if line.starts(with: "Title:") {
                    importedTitle = line.replacingOccurrences(of: "Title:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    currentSection = nil
                } else if line.starts(with: "Prep Time:") {
                    importedPrepTime = line.replacingOccurrences(of: "Prep Time:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "Cook Time:") {
                    importedCookTime = line.replacingOccurrences(of: "Cook Time:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "Gluten-Free:") {
                    importedGlutenFree = line.replacingOccurrences(of: "Gluten-Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Sugar-Free:") {
                    importedSugarFree = line.replacingOccurrences(of: "Sugar-Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Dairy-Free:") {
                    importedDairyFree = line.replacingOccurrences(of: "Dairy-Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "GMO-Free:") {
                    importedGMOFree = line.replacingOccurrences(of: "GMO-Free:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Organic:") {
                    importedOrganic = line.replacingOccurrences(of: "Organic:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Vegetarian:") {
                    importedVegetarian = line.replacingOccurrences(of: "Vegetarian:", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                } else if line.starts(with: "Cuisine:") {
                    importedCuisine = line.replacingOccurrences(of: "Cuisine:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "Ingredients:") {
                    currentSection = "ingredients"
                } else if line.starts(with: "Steps:") {
                    currentSection = "steps"
                } else if line.starts(with: "Notes:") {
                    currentSection = "notes"
                } else if line.starts(with: "URL:") {
                    currentSection = "url"
                } else if let section = currentSection {
                    if !line.isEmpty {
                        switch section {
                        case "ingredients":
                            importedIngredients += "\(line)\n"
                        case "steps":
                            importedSteps += "\(line)\n"
                        case "notes":
                            importedNotes += "\(line)\n"
                        case "url":
                            importedURL += "\(line)"
                        default:
                            break
                        }
                    }
                }
            }
            
            if !importedTitle.isEmpty && !importedIngredients.isEmpty && !importedSteps.isEmpty {
                recipeFound = true
            }
            
            self.importedTitle = importedTitle
            self.importedPrepTime = importedPrepTime
            self.importedCookTime = importedCookTime
            self.importedCuisine = importedCuisine
            self.importedGlutenFree = importedGlutenFree
            self.importedSugarFree = importedSugarFree
            self.importedDairyFree = importedDairyFree
            self.importedGMOFree = importedGMOFree
            self.importedOrganic = importedOrganic
            self.importedVegetarian = importedVegetarian
            self.importedIngredients = importedIngredients
            self.importedSteps = importedSteps
            self.importedNotes = importedNotes
            self.importedURL = importedURL
            
            isImportingData = true
            
            if recipeFound {
                let successMessage = MessageView.viewFromNib(layout: .cardView)
                successMessage.configureTheme(.success)
                successMessage.configureDropShadow()
                successMessage.button?.isHidden = true
                successMessage.configureContent(title: "Recipe Imported", body: "A recipe was successfully imported from the clipboard.")
                SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
                SwiftMessages.show(view: successMessage)
            } else {
                let noRecipeMessage = MessageView.viewFromNib(layout: .cardView)
                noRecipeMessage.configureTheme(.warning)
                noRecipeMessage.configureDropShadow()
                noRecipeMessage.button?.isHidden = true
                noRecipeMessage.configureContent(title: "No Recipe Found", body: "No recipe data was found in the clipboard.")
                SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
                SwiftMessages.show(view: noRecipeMessage)
            }
        }
    }
    
    // MARK: Import Copied Image
    private func importPic() {
        self.importImageFromClipboard()
    }
    private func importImageFromClipboard() {
        var imageFound = false
        
        for item in UIPasteboard.general.items {
            if let uiImage = item["public.jpeg"] as? UIImage {
                print("Image found using key: public.jpeg")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["public.png"] as? UIImage {
                print("Image found using key: public.png")
                selectedImage = uiImage
                imageFound = true
                break
            } else if let uiImage = item["com.apple.uikit.image"] as? UIImage {
                print("Image found using key: com.apple.uikit.image")
                selectedImage = uiImage
                imageFound = true
                break
            }
        }
        
        if imageFound {
            let successMessage = MessageView.viewFromNib(layout: .cardView)
            successMessage.configureTheme(.success)
            successMessage.configureDropShadow()
            successMessage.button?.isHidden = true
            successMessage.configureContent(title: "Image Imported", body: "An image was successfully imported from the clipboard.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: successMessage)
        } else {
            let noImageMessage = MessageView.viewFromNib(layout: .cardView)
            noImageMessage.configureTheme(.warning)
            noImageMessage.configureDropShadow()
            noImageMessage.button?.isHidden = true
            noImageMessage.configureContent(title: "No Image Found", body: "No image was found in the clipboard.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 1)
            SwiftMessages.show(view: noImageMessage)
        }
    }
}

// MARK: New Recipe Preview
struct NewRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        return NavigationView {
            NewRecipeView()
                .environment(\.managedObjectContext, context)
        }
    }
}

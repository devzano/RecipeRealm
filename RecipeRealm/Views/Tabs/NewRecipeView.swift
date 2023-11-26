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
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var appStates = AppStates()
    @Binding var selectedTab: Int
    @State var errorMessage = ""
    @State var selectedImage: UIImage?
    @State var showImagePicker = false
    @State var showSourcePicker = false
    @State var showWebView: Bool = false
    @State var showImageWebView = false
    @State var isSearchingImage = false
    @State var imageSource: ImageSource = .photoLibrary
    // MARK: Users Inputed Recipe
    @State var title = ""
    @State var prepTime = ""
    @State var cookTime = ""
    @State var nutritionBadges = NutritionBadges(glutenFree: false, sugarFree: false, dairyFree: false, gmoFree: false, organic: false, vegetarian: false, peanutFree: false, nutFree: false, eggFree: false, noTransFat: false, cornFree: false, soyFree: false)
    @State var selectedCuisineIndex = -1
    @State var ingredients = ""
    @State var steps = ""
    @State var notes = ""
    @State var recipeURL = ""
    // MARK: Users Imported Recipe
    @State var isImportingData = false
    @State var isImportingPhoto = false
    @State var importedTitle = ""
    @State var importedPrepTime = ""
    @State var importedCookTime = ""
    @State var importedGlutenFree = false
    @State var importedSugarFree = false
    @State var importedDairyFree = false
    @State var importedGMOFree = false
    @State var importedOrganic = false
    @State var importedVegetarian = false
    @State var importedPeanutFree = false
    @State var importedNutFree = false
    @State var importedEggFree = false
    @State var importedNoTransFat = false
    @State var importedCornFree = false
    @State var importedSoyFree = false
    @State var importedCuisine = ""
    @State var importedIngredients = ""
    @State var importedSteps = ""
    @State var importedNotes = ""
    @State var importedURL = ""

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
        .accentColor(appStates.selectedAccentColor)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerSheetView(showImagePicker: $showImagePicker, selectedImage: $selectedImage, imageSource: $imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
        }
    }
    
    // MARK: Import Recipe
    private var importSection: some View {
        let baseSize: CGFloat = 19
        let imageSize: CGFloat = 20
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section {
            if !isZoomed || isZoomed {
                HStack {
                    Button(action: {
                        importData()
                    }) {
                        VStack {
                            Text("Import")
                                .fontWeight(.medium)
                            Text("Recipe")
                                .fontWeight(.medium)
                        }
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: imageSize))
                    }
                    .foregroundColor(dataButtonDisabled ? Color.gray : appStates.selectedAccentColor)
                    .buttonStyle(.borderless)
                    .disabled(dataButtonDisabled)
                    
                    Spacer()
                    
                    Button(action: {
                        importPic()
                    }) {
                        VStack {
                            Text("Import")
                                .fontWeight(.medium)
                            Text("Photo")
                                .fontWeight(.medium)
                        }
                        Image(systemName: "photo")
                            .font(.system(size: imageSize))
                    }
                    .foregroundColor(photoButtonDisabled ? Color.gray : appStates.selectedAccentColor)
                    .buttonStyle(.borderless)
                    .disabled(photoButtonDisabled)
                    
                    Spacer()
                    
                    Button(action: {
                        addRecipe()
                        if appStates.showAlert {
                            let errorMessageView = MessageView.viewFromNib(layout: .cardView)
                            errorMessageView.configureTheme(.error)
                            errorMessageView.configureDropShadow()
                            errorMessageView.button?.isHidden = true
                            errorMessageView.configureContent(title: "Blank Recipe", body: errorMessage)
                            SwiftMessages.show(view: errorMessageView)
                            appStates.showAlert = false
                        } else {
                            selectedTab = 0
                        }
                    }) {
                        VStack {
                            Text("Add")
                                .fontWeight(.medium)
                            Text("Recipe")
                                .fontWeight(.medium)
                        }
                        Image(systemName: "plus")
                            .font(.system(size: imageSize))
                    }
                    .foregroundColor(appStates.selectedAccentColor)
                    .buttonStyle(.borderless)
                }
            }
        }.font(.system(size: textSize))
    }


    // MARK: Image Selection
    private var selectedImageViewSection: some View {
        let baseSize: CGFloat = 19
        let imageSize: CGFloat = 20
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Image")) {
            if !isZoomed || isZoomed {
                Group {
                    if selectedImage == nil {
                        HStack {
                            TextField("Image Search", text: $appStates.imageSearch)
                                .onChange(of: appStates.imageSearch) { _ in
                                    isSearchingImage = true
                                }
                            Button(action: {
                                showImageWebView.toggle()
                            }) {
                                HStack {
                                    Text("Search With")
                                    Image("GoogleLogo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .font(.system(size: imageSize))
                                }
                            }
                            .sheet(isPresented: $showImageWebView) {
                                GoogleImageSearchView(isPresented: $showImageWebView, searchQuery: $appStates.imageSearch)
                            }
                        }
                    }
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                        HStack {
                            Text("Delete Photo")
                            Image(systemName: "trash")
                        }
                        .onTapGesture {
                            deletePhoto()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ImagePickerButton(showSourcePicker: $showSourcePicker, showImagePicker: $showImagePicker, imageSource: $imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .font(.system(size: textSize))
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
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Title")) {
            if !isZoomed || isZoomed {
                TextField("Title", text: isImportingData ? $importedTitle : $title)
            }
        }.font(.system(size: textSize))
    }
    
    // MARK: Recipe Times
    private var recipeTimeInfoSection: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Prep & Cook Time")) {
            if !isZoomed || isZoomed {
                HStack(spacing: 17) {
                    TextField("Prep Time", text: isImportingData ? $importedPrepTime : $prepTime)
                    Divider()
                    TextField("Cook Time", text: isImportingData ? $importedCookTime : $cookTime)
                }
            }
        }.font(.system(size: textSize))
    }
    
    // MARK: Recipe Cuisines
    private var cuisineSection: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Cuisine")) {
            if !isZoomed || isZoomed {
                Picker("Cuisine", selection: $selectedCuisineIndex) {
                    Text("Select")
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
        }.font(.system(size: textSize))
    }
    
    // MARK: Nutrition Badges
    private var nutritionSection: some View {
        let baseSize: CGFloat = 17
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Nutrition Badges")) {
            if !isZoomed || isZoomed {
                    HStack(spacing: 8) {
                        Toggle("Gluten Free", isOn: isImportingData ? $importedGlutenFree : $nutritionBadges.glutenFree)
                        Toggle("Sugar Free", isOn: isImportingData ? $importedSugarFree : $nutritionBadges.sugarFree)
                    }
                    HStack(spacing: 8) {
                        Toggle("Dairy Free", isOn: isImportingData ? $importedDairyFree : $nutritionBadges.dairyFree)
                        Toggle("GMO Free", isOn: isImportingData ? $importedGMOFree : $nutritionBadges.gmoFree)
                    }
                    HStack(spacing: 8) {
                        Toggle("Organic", isOn: isImportingData ? $importedOrganic : $nutritionBadges.organic)
                        Toggle("Vegetarian", isOn: isImportingData ? $importedVegetarian : $nutritionBadges.vegetarian)
                    }
                    HStack(spacing: 8) {
                        Toggle("Peanut Free", isOn: isImportingData ? $importedPeanutFree : $nutritionBadges.peanutFree)
                        Toggle("Nut Free", isOn: isImportingData ? $importedNutFree : $nutritionBadges.nutFree)
                    }
                    HStack(spacing: 8) {
                        Toggle("Egg Free", isOn: isImportingData ? $importedEggFree : $nutritionBadges.eggFree)
                        Toggle("No Trans Fat", isOn: isImportingData ? $importedNoTransFat : $nutritionBadges.noTransFat)
                    }
                    HStack(spacing: 8) {
                        Toggle("Corn Free", isOn: isImportingData ? $importedCornFree : $nutritionBadges.cornFree)
                        Toggle("Soy Free", isOn: isImportingData ? $importedSoyFree : $nutritionBadges.soyFree)
                    }
            }
        }
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.vertical, 8)
        .font(.system(size: textSize))
    }

    // MARK: Recipe Ingredients
    private var ingredientsSection: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            if !isZoomed || isZoomed {
                PlaceholderTextEditorView(text: isImportingData ? $importedIngredients : $ingredients, placeholder: "(next line for new ingredient)")
                    .onChange(of: isImportingData ? importedIngredients : ingredients) { newValue in
                        addBulletPoints()
                    }
            }
        }.font(.system(size: textSize))
    }
    
    //MARK: Recipe Ingredient & Note Bullet Points
    private func addBulletPoints() {
        let addedIngredients = isImportingData ? importedIngredients : ingredients
        let addedNotes = isImportingData ? importedNotes : notes
        
        var ingredientLines = addedIngredients.split(separator: "\n", omittingEmptySubsequences: false)
        var noteLines = addedNotes.split(separator: "\n", omittingEmptySubsequences: false)
        
        ingredientLines = ingredientLines.map { line in
            if !line.isEmpty {
                if !line.starts(with: appStates.currentBullet) {
                    return "\(appStates.currentBullet) \(line)"
                }
            }
            return line
        }
        
        noteLines = noteLines.map { line in
            if !line.isEmpty {
                if !line.starts(with: appStates.currentBullet) {
                    return "\(appStates.currentBullet) \(line)"
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
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Steps")) {
            if !isZoomed || isZoomed {
                PlaceholderTextEditorView(text: isImportingData ? $importedSteps : $steps,placeholder: "(next line for new step)")
                    .onChange(of: isImportingData ? importedSteps : steps) { newValue in
                        addStepNumbers()
                    }
            }
        }.font(.system(size: textSize))
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
            let stepNumber = appStates.currentStepNumber + index
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
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Notes")) {
            if !isZoomed || isZoomed {
                PlaceholderTextEditorView(text: isImportingData ? $importedNotes : $notes, placeholder: "(optional)")
                    .onChange(of: isImportingData ? importedNotes : notes) { newValue in
                        addBulletPoints()
                    }
            }
        }.font(.system(size: textSize))
    }
    
    // MARK: Recipe URL
    private var recipeURLSection: some View {
        let baseSize: CGFloat = 19
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            if !isZoomed || isZoomed {
                TextField("URL of website", text: isImportingData ? $importedURL : $recipeURL)
            }
        }.font(.system(size: textSize))
    }
}

// MARK: New Recipe Preview
struct NewRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedTab = 0
        let context = PersistenceController.preview.container.viewContext
        
        return NavigationView {
            NewRecipeView(selectedTab: $selectedTab)
                .environment(\.managedObjectContext, context)
                .environmentObject(AppStates())
        }
    }
}

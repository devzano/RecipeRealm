//
//  RecipeDetailView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import UIKit
import PhotosUI
import TOCropViewController
import SwiftMessages

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var appStates = AppStates()
    let recipe: Recipe
    @State private var showTOCropViewController = false
    @State private var showAlert = false
    @State private var showWebView: Bool = false
    @State private var isSearchingImage = false
    @State private var imageSearch = ""
    @State private var googleImageSearchURL: URL? = nil
    @State private var detailTapped: [Substring: Bool] = [:]
    @State private var currentStepNumber: Int = 1
    @State private var currentBullet: String = "•"
    // MARK: Update Users Recipe
    @State private var editingMode = false
    @State var selectedImage: UIImage?
    @State private var updatedTitle: String
    @State private var updatedImageData: Data?
    @State private var updatedPrepTime: String
    @State private var updatedCookTime: String
    @State private var glutenFree: Bool
    @State private var sugarFree: Bool
    @State private var dairyFree: Bool
    @State private var gmoFree: Bool
    @State private var organic: Bool
    @State private var vegetarian: Bool
    @State private var selectedCuisine: Int
    @State private var updatedIngredients: String
    @State private var updatedSteps: String
    @State private var updatedNotes: String
    @State private var updatedRecipeURL: String

    // MARK: Present Recipe
    init(recipe: Recipe) {
        self.recipe = recipe
        _updatedTitle = State(initialValue: recipe.title ?? "")
        if recipe.imageData != nil {
            _selectedImage = State(initialValue: recipe.imageData != nil ? UIImage(data: recipe.imageData!) : nil)
        }
        _updatedPrepTime = State(initialValue: recipe.prepTime ?? "")
        _updatedCookTime = State(initialValue: recipe.cookTime ?? "")
        let cuisine = recipe.cuisines ?? ""
        if let cuisineIndex = cuisineOptions.firstIndex(of: cuisine) {
            _selectedCuisine = State(initialValue: cuisineIndex)
        } else {
            _selectedCuisine = State(initialValue: 0)
        }
        _glutenFree = State(initialValue: recipe.glutenFree)
        _sugarFree = State(initialValue: recipe.sugarFree)
        _dairyFree = State(initialValue: recipe.dairyFree)
        _gmoFree = State(initialValue: recipe.gmoFree)
        _organic = State(initialValue: recipe.organic)
        _vegetarian = State(initialValue: recipe.vegetarian)
        _updatedIngredients = State(initialValue: recipe.ingredients ?? "")
        _updatedSteps = State(initialValue: recipe.steps ?? "")
        _updatedNotes = State(initialValue: recipe.notes ?? "")
        _updatedRecipeURL = State(initialValue: recipe.recipeURL ?? "")
    }

    // MARK: Recipe Detail View
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Text(updatedTitle)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            List {
                imageSection
                if editingMode {
                    editTitleSection
                    editPrepAndCookTimeSection
                    editCuisineSection
                    editNutrionSection
                    editIngredientsSection
                    editStepsSection
                    editNotesSection
                    editRecipeURLSection
                } else {
                    if !updatedPrepTime.isEmpty || !updatedCookTime.isEmpty {
                        prepAndCookTimeSection
                    }
                    nutritionAndCuisineSection
                    ingredientsSection
                    stepsSection
                    if !updatedNotes.isEmpty {
                        notesSection
                    }
                    if !updatedRecipeURL.isEmpty {
                        recipeURLSection
                    }
                }
            }
            .sheet(isPresented: $appStates.showImagePicker) {
                ImagePickerSheetView(showImagePicker: $appStates.showImagePicker, selectedImage: $selectedImage, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
            }
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    if editingMode {
                        updateRecipe()
                    }
                    editingMode.toggle()
                }) {
                    Text(editingMode ? "Done" : "Edit")
                }
            )
        }
    }
    
    // MARK: Recipe's Title
    private var editTitleSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Title")) {
            TextField("Title", text: $updatedTitle)
        }
    }
    
    // MARK: Recipe's Selected Image
    private var imageSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Image")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } else if !editingMode {
                        Text("Present a picture of your recipe!")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    
                    if editingMode {
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
                            }.listRowSeparator(.hidden)
                        }
                        
                HStack {
                    if selectedImage == nil {
                        ImagePickerButton(showSourcePicker: $appStates.showSourcePicker, showImagePicker: $appStates.showImagePicker, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
                    }
                    
                    if editingMode && selectedImage != nil {
                        TOCropImageView(selectedImage: $selectedImage)
                        
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Photo")
                        }
                        .onTapGesture {
                            deletePhoto()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            }
        }
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
        updatedImageData = nil
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureTheme(.success)
        successMessage.configureDropShadow()
        successMessage.button?.isHidden = true
        successMessage.configureContent(title: "Success", body: "Photo deleted successfully!")
        SwiftMessages.hideAll()
        SwiftMessages.show(view: successMessage)
    }
    
    // MARK: Crop Selected Image
    private func cropImage() {
        showTOCropViewController = true
    }
    
    // MARK: Recipe's Time
    private var prepAndCookTimeSection: some View {
        Section(header: SectionHeaderTitlesView(title: prepAndCookTimeHeader)) {
            HStack(spacing: 13) {
                if !updatedPrepTime.isEmpty {
                    Image(systemName: "hands.sparkles.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.orange)
                    Text(updatedPrepTime)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Divider()
                }
                
                Spacer()
                
                if !updatedCookTime.isEmpty {
                    Divider()
                    Image(systemName: "flame.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                    Text(updatedCookTime)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding(EdgeInsets(top: 3.5, leading: 10, bottom: 3.5, trailing: 10))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {}
            }
        }
    }
    private var prepAndCookTimeHeader: String {
        if !updatedPrepTime.isEmpty && !updatedCookTime.isEmpty {
            return "Prep & Cook Time"
        } else if !updatedPrepTime.isEmpty {
            return "Prep Time"
        } else if !updatedCookTime.isEmpty {
            return "Cook Time"
        } else {
            return ""
        }
    }
    private var editPrepAndCookTimeSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Prep & Cook Time")) {
            HStack {
                TextField("Prep Time", text: $updatedPrepTime)
                Divider()
                TextField("Cook Time", text: $updatedCookTime)
            }
        }
    }
    
    // MARK: Recipe's Nutrition Badges & Cuisine
    private var nutritionAndCuisineSection: some View {
        Section(header: SectionHeaderTitlesView(title: nutritionHeader)) {
            if glutenFree || sugarFree || dairyFree || gmoFree || organic || vegetarian {
                HStack(spacing: -4) {
                    Spacer ()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if glutenFree {
                                nutritionBadgeImg("GlutenFree")
                            }
                            if sugarFree {
                                nutritionBadgeImg("SugarFree")
                            }
                            if dairyFree {
                                nutritionBadgeImg("DairyFree")
                            }
                            if gmoFree {
                                nutritionBadgeImg("GMOFree")
                            }
                            if organic {
                                nutritionBadgeImg("Organic")
                            }
                            if vegetarian {
                                nutritionBadgeImg("Vegetarian")
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    Spacer()
                    
                    Text(cuisineOptions[selectedCuisine])
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }.padding(.horizontal, -19)
            } else {
                Text(cuisineOptions[selectedCuisine])
                    .foregroundColor(.primary)
            }
        }
    }
    private var nutritionHeader: String {
        if glutenFree || sugarFree || dairyFree || gmoFree || organic || vegetarian {
            return "Nutrition & Cuisine"
        } else {
            return "Cuisine"
        }
    }
    private var editNutrionSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Nutrition Badges")) {
            VStack {
                HStack{
                    Toggle("Gluten-Free", isOn: $glutenFree)
                    Toggle("Sugar-Free", isOn: $sugarFree)
                }
                HStack {
                    Toggle("Dairy-Free", isOn: $dairyFree)
                    Toggle("GMO-Free", isOn: $gmoFree)
                }
                HStack {
                    Toggle("Organic", isOn: $organic)
                    Toggle("Vegetarian", isOn: $vegetarian)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    private var editCuisineSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Cuisine")) {
            Picker("Cuisine", selection: $selectedCuisine) {
                ForEach(0..<cuisineOptions.count, id: \.self) { index in
                    Text(cuisineOptions[index])
                }
            }.pickerStyle(MenuPickerStyle())
        }
    }

    // MARK: Tapped Ingredient & Step
    private func toggleIngredientTapped(_ ingredient: Substring) {
        detailTapped[ingredient, default: false].toggle()
    }
    private func toggleStepTapped(_ step: Substring) {
        detailTapped[step, default: false].toggle()
    }
    
    // MARK: Recipe's Ingredients
    private var ingredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            ForEach(updatedIngredients.split(separator: "\n", omittingEmptySubsequences: true), id: \.self) { ingredient in
                Button(action: {
                    toggleIngredientTapped(ingredient)
                }) {
                    HStack {
                        Image(systemName: detailTapped[ingredient, default: false] ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.accentColor)
                        Text(String(removeBulletPoints(from: ingredient))).foregroundColor(.white)
                    }
                }
            }
        }
    }
    private var editIngredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            PlaceholderTextEditorView(text: $updatedIngredients, placeholder: "(next line for new ingredient)")
                .onChange(of: updatedIngredients) { newValue in
                    updateBulletPoints()
                }
        }
    }
    
    //MARK: Recipe's Ingredient & Note Bullet Points
    private func updateBulletPoints() {
        var ingredientLines = updatedIngredients.split(separator: "\n", omittingEmptySubsequences: false)
        var noteLines = updatedNotes.split(separator: "\n", omittingEmptySubsequences: false)
        
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
        
        updatedIngredients = updatedIngredientText
        updatedNotes = updatedNoteText
    }
    func removeBulletPoints(from text: Substring) -> String {
        let bulletPointPattern = "^\\\(currentBullet)\\s*"
        let regex = try! NSRegularExpression(pattern: bulletPointPattern, options: .anchorsMatchLines)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: String(text), options: [], range: range, withTemplate: "")
    }
    
    // MARK: Recipe's Steps
    private var stepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            ForEach(updatedSteps.split(separator: "\n"), id: \.self) { step in
                Button(action: {
                    toggleStepTapped(step)
                }) {
                    HStack {
                        Image(systemName: detailTapped[step, default: false] ? "checkmark.circle.fill" : "circle")
                        Text(removeNumbering(from: String(step))).foregroundColor(.white)
                    }
                }
            }
        }
    }
    private var editStepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            PlaceholderTextEditorView(text: $updatedSteps, placeholder: "(next line for new step)")
                .onChange(of: updatedSteps) { newValue in
                    updateStepNumbers()
                }
        }
    }
    
    // MARK: Recipe's Step Numbers
    private func updateStepNumbers() {
        let addedSteps = updatedSteps
        
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
        
        updatedSteps = updatedText
    }
    func removeNumbering(from text: String) -> String {
        if let range = text.range(of: "^\\d+\\. ", options: .regularExpression) {
            return String(text[range.upperBound...])
        }
        return text
    }
    
    // MARK: Recipe's Notes
    private var notesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
            ForEach(updatedNotes.split(separator: "\n", omittingEmptySubsequences: true), id: \.self) { note in
                Text(String(removeBulletPoints(from: note))).foregroundColor(.white)
            }
        }
    }
    private var editNotesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
            PlaceholderTextEditorView(text: $updatedNotes, placeholder: "(optional)")
                .onChange(of: updatedNotes) { newValue in
                    updateBulletPoints()
                }
        }
    }
    
    // MARK: Recipe's URL
    private var recipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            if let url = URL(string: updatedRecipeURL), UIApplication.shared.canOpenURL(url) {
                NavigationLink(
                    destination: WebViewWithButtonRepresentable(request: URLRequest(url: url), showScanButton: true, showCloseButton: false),
                    label: {
                        Text(url.host ?? "Open Recipe URL")
                            .foregroundColor(.blue)
                            .underline()
                    }
                )
            } else {
                Text(updatedRecipeURL)
            }
        }
    }
    private var editRecipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            TextField("Recipe URL", text: $updatedRecipeURL)
        }
    }
    
    // MARK: Update Recipe
    private func updateRecipe() {
        recipe.title = updatedTitle
        recipe.prepTime = updatedPrepTime
        recipe.cookTime = updatedCookTime
        recipe.ingredients = updatedIngredients
        recipe.cuisines = cuisineOptions[selectedCuisine]
        recipe.glutenFree = glutenFree
        recipe.sugarFree = sugarFree
        recipe.dairyFree = dairyFree
        recipe.gmoFree = gmoFree
        recipe.organic = organic
        recipe.vegetarian = vegetarian
        recipe.steps = updatedSteps
        recipe.notes = updatedNotes
        recipe.recipeURL = updatedRecipeURL
        if let image = selectedImage {
            let imageData = image.jpegData(compressionQuality: 0.8)
            recipe.imageData = imageData
        } else {
            recipe.imageData = nil
        }
        do {
            try viewContext.save()
            let successMessage = MessageView.viewFromNib(layout: .cardView)
            successMessage.configureTheme(.success)
            successMessage.configureDropShadow()
            successMessage.button?.isHidden = true
            successMessage.configureContent(title: "Success", body: "Recipe updated successfully!")
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
}

// MARK: Recipe Detail Preview 
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let recipe = Recipe(context: context)
        recipe.title = "Sample Recipe"
        recipe.cuisines = "Mexican"
        recipe.glutenFree = true
        recipe.dairyFree = true
        recipe.sugarFree = true
        recipe.prepTime = "10m"
        recipe.cookTime = "30m"
        recipe.ingredients = "Ingredient 1\nIngredient 2\nIngredient 3"
        recipe.steps = "Step 1\nStep 2\nStep 3"
        recipe.notes = "Notes"
        return NavigationView {
            RecipeDetailView(recipe: recipe)
        }
        .environment(\.managedObjectContext, context)
    }
}

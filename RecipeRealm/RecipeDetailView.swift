//
//  RecipeDetailView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import UIKit
import PhotosUI

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let recipe: Recipe

    @State private var editingMode = false
    @State private var updatedTitle: String
    @State private var updatedImageURL: String
    @State private var updatedImageData: Data?
    @State private var updatedPrepTime: String
    @State private var updatedCookTime: String
    @State private var selectedCuisine: Int
    @State private var glutenFree: Bool
    @State private var sugarFree: Bool
    @State private var dairyFree: Bool
    @State private var gmoFree: Bool
    @State private var organic: Bool
    @State private var vegetarian: Bool
    @State private var updatedIngredients: String
    @State private var updatedSteps: String
    @State private var updatedNotes: String
    @State private var updatedRecipeURL: String
    @State var selectedImage: UIImage?
    @StateObject private var appStates = AppStates()

    init(recipe: Recipe) {
        self.recipe = recipe
        _updatedTitle = State(initialValue: recipe.title ?? "")
        _updatedImageURL = State(initialValue: recipe.imageURL ?? "")
        if let data = recipe.imageData {
            _selectedImage = State(initialValue: UIImage(data: data))
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
                    if selectedImage == nil {
                        editImageURL
                    }
                    HStack {
                        if updatedImageURL.isEmpty {
                            ImagePickerButton(showSourcePicker: $appStates.showSourcePicker, showImagePicker: $appStates.showImagePicker, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
                        }
                        if editingMode && (selectedImage != nil || !updatedImageURL.isEmpty) {
                            Button(action: {
                                appStates.showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Photo")
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }.alert(isPresented: $appStates.showDeleteConfirmation) {
                                Alert(
                                    title: Text("Delete Photo"),
                                    message: Text("Are you sure you want to delete this photo?"),
                                    primaryButton: .cancel(),
                                    secondaryButton: .destructive(Text("Delete")) {
                                        deletePhoto()
                                    }
                                )
                            }
                        }
                    }
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
    
    private var imageSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Image")) {
                if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else if let imageURL = URL(string: updatedImageURL), !updatedImageURL.isEmpty {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ActivityIndicatorView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    @unknown default:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            } else {
                Text("present a picture of your recipe")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    private var prepAndCookTimeSection: some View {
        Section(header: SectionHeaderTitlesView(title: prepAndCookTimeHeader)) {
            HStack(spacing: 13) {
                if !updatedPrepTime.isEmpty {
                    Image(systemName: "fork.knife")
                        .resizable()
                        .frame(width: 30, height: 30)
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
    
    private var ingredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            ForEach(updatedIngredients.split(separator: "\n"), id: \.self) { ingredient in
                Text(String(ingredient)
                )
            }
        }
    }
    
    private var stepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            ForEach(updatedSteps.split(separator: "\n"), id: \.self) { step in
                Text(String(step))
            }
        }
    }
    
    private var notesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
                Text(updatedNotes)
            }
    }
    
    private var recipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
                Text(updatedRecipeURL)
            }
    }
    
    private var editTitleSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Title")) {
            TextField("Title", text: $updatedTitle)
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
    
    private var editCuisineSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Cuisine")) {
            Picker("Cuisine", selection: $selectedCuisine) {
                ForEach(0..<cuisineOptions.count, id: \.self) { index in
                    Text(cuisineOptions[index])
                }
            }.pickerStyle(MenuPickerStyle())
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
    
    private var editIngredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            PlaceholderTextEditorView(text: $updatedIngredients, placeholder: "(next line for new ingredient)")
        }
    }
    
    private var editStepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            PlaceholderTextEditorView(text: $updatedSteps, placeholder: "(next line for new step)")
        }
    }
    
    private var editNotesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
            PlaceholderTextEditorView(text: $updatedNotes, placeholder: "(optional)")
        }
    }
    
    private var editImageURL: some View {
        Section(header: SectionHeaderTitlesView(title: "Image URL")) {
            TextField("Image URL", text: $updatedImageURL)
        }
    }
    
    private var editRecipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            TextField("Recipe URL", text: $updatedRecipeURL)
        }
    }
    
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
        recipe.imageURL = updatedImageURL
        if let image = selectedImage {
            recipe.imageData = image.jpegData(compressionQuality: 1.0)
        } else {
            recipe.imageData = nil
        }
        do {
            try viewContext.save()
        } catch {
            print("Unresolved error \(error)")
        }
    }

    private func deletePhoto() {
        selectedImage = nil
        updatedImageURL = ""
        updatedImageData = nil
    }
}

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
        recipe.imageURL = "https://example.com/sample-image.jpg"

        return NavigationView {
            RecipeDetailView(recipe: recipe)
        }
        .environment(\.managedObjectContext, context)
    }
}

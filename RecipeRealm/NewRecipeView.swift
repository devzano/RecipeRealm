//
//  NewRecipeView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 5/15/23.
//

import SwiftUI
import UIKit
import CoreData
import PhotosUI

struct NewRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var title = ""
    @State private var ingredients = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var selectedCuisineIndex = -1
    @State private var glutenFree = false
    @State private var sugarFree = false
    @State private var dairyFree = false
    @State private var gmoFree = false
    @State private var organic = false
    @State private var vegetarian = false
    @State private var steps = ""
    @State private var notes = ""
    @State private var recipeURL = ""
    @State private var imageURL = ""
    @State private var isEditingImageURL = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State var selectedImage: UIImage?
    @StateObject private var appStates = AppStates()
    
    var body: some View {
        Form {
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
        .navigationBarItems(trailing: Button(action: addRecipe) {Text("Add").fontWeight(.semibold)})
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Blank Recipe"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $appStates.showImagePicker) {
            ImagePickerSheetView(showImagePicker: $appStates.showImagePicker, selectedImage: $selectedImage, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
        }
    }
    
    private var recipeTitleSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Title")) {
            TextField("Title", text: $title)
        }
    }
    
    private var selectedImageViewSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Image")) {
            Group {
                if selectedImage == nil {
                        TextField("Image URL", text: $imageURL)
                        .onChange(of: imageURL) { _ in
                            isEditingImageURL = true
                        }
                }
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    Button(action: {
                        appStates.showDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Photo")
                        }
                        .foregroundColor(.red)
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
                } else if !imageURL.isEmpty, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ActivityIndicatorView()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ImagePickerButton(showSourcePicker: $appStates.showSourcePicker, showImagePicker: $appStates.showImagePicker, imageSource: $appStates.imageSource, photoLibraryAuthorizationStatus: $appStates.photoLibraryAuthorizationStatus, cameraAuthorizationStatus: $appStates.cameraAuthorizationStatus)
                }
            }
        }
    }
    
    private var recipeTimeInfoSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Prep & Cook Time")) {
            HStack(spacing: 17) {
                TextField("Prep Time", text: $prepTime)
                Divider()
                TextField("Cook Time", text: $cookTime)
            }
        }
    }
    
    private var cuisineSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Cuisine")) {
            Picker("Cuisine", selection: $selectedCuisineIndex) {
                Text("Select Cuisine")
                    .foregroundColor(selectedCuisineIndex == -1 ? .gray : .primary)
                    .disabled(true)
                ForEach(0..<cuisineOptions.count, id: \.self) { index in
                    Text(cuisineOptions[index])
                }
            }.pickerStyle(MenuPickerStyle())
        }
    }
    
    private var nutritionSection: some View {
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
    
    private var ingredientsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Ingredients")) {
            PlaceholderTextEditorView(text: $ingredients, placeholder: "(next line for new ingredient)")
        }
    }

    private var stepsSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Steps")) {
            PlaceholderTextEditorView(text: $steps, placeholder: "(next line for new step)")
        }
    }
    
    private var notesSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Notes")) {
            PlaceholderTextEditorView(text: $notes, placeholder: "(optional)")
        }
    }
    
    private var recipeURLSection: some View {
        Section(header: SectionHeaderTitlesView(title: "Recipe URL")) {
            TextField("Recipe URL", text: $recipeURL)
        }
    }
    
    private func addRecipe() {
        var missingFields: [String] = []
                
        if title.isEmpty {missingFields.append("the Title")}
        if ingredients.isEmpty {missingFields.append("Ingredients")}
        if steps.isEmpty {missingFields.append("Steps")}
                
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
        guard selectedCuisineIndex != -1 else {
            showAlert = true
            errorMessage = "Please select a cuisine."
            return
        }
        
        let newRecipe = Recipe(context: viewContext)
        newRecipe.title = title
        newRecipe.imageURL = imageURL
        if let image = selectedImage {
            newRecipe.imageData = image.jpegData(compressionQuality: 1.0)
        }
        newRecipe.prepTime = prepTime
        newRecipe.cookTime = cookTime
        newRecipe.cuisines = cuisineOptions[selectedCuisineIndex]
        newRecipe.glutenFree = glutenFree
        newRecipe.sugarFree = sugarFree
        newRecipe.dairyFree = dairyFree
        newRecipe.gmoFree = gmoFree
        newRecipe.organic = organic
        newRecipe.vegetarian = vegetarian
        newRecipe.ingredients = ingredients
        newRecipe.steps = steps
        newRecipe.recipeURL = recipeURL
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Unresolved error \(error)")
        }
    }
    
    private func deletePhoto() {
        selectedImage = nil
        imageURL = ""
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                appStates.photoLibraryAuthorizationStatus = status
            }
        }
    }
}

struct NewRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        return NavigationView {
            NewRecipeView()
                .environment(\.managedObjectContext, context)
        }
    }
}

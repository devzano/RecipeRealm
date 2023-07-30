//
//  RecipeSharedData.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/29/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import Photos
import AVFoundation

// MARK: - App States
class AppStates: ObservableObject {
    @Published var showDeleteConfirmation = false
    @Published var showSourcePicker = false
    @Published var showImagePicker = false
    @Published var imageSource: ImageSource = .photoLibrary
    @Published var photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
    @Published var cameraAuthorizationStatus = AVAuthorizationStatus.authorized
}

// MARK: - Placeholder Editor
struct PlaceholderTextEditorView: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding()
            }
            TextEditor(text: $text)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                .foregroundColor(Color.primary)
        }
    }
}

// MARK: - Section Header Titles
struct SectionHeaderTitlesView: View {
    let title: String

    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .listRowInsets(EdgeInsets(top: 30, leading: 0, bottom: 15, trailing: 0))
    }
}

// MARK: - Nutrition Badges & Image Struct
func nutritionBadgeImg(_ imageName: String) -> some View {
    Image(imageName)
        .resizable()
        .frame(width: 40, height: 40)
}

//struct NutritionBadges: Codable {
//    var glutenFree: Bool
//    var sugarFree: Bool
//    var dairyFree: Bool
//    var gmoFree: Bool
//    var organic: Bool
//    var vegetarian: Bool
//}


// MARK: - Cuisine Names
let cuisineOptions = [
    "Mexican",
    "Cuban",
    "American",
    "Italian",
    "Chinese",
    "BBQ (Barbecue)",
    "Brazilian",
    "Cajun/Creole",
    "Caribbean",
    "Ethiopian",
    "Filipino",
    "French",
    "German",
    "Greek",
    "Hawaiian",
    "Indian",
    "Irish",
    "Jamaican",
    "Japanese",
    "Jewish (deli food)",
    "Korean",
    "Lebanese",
    "Mediterranean",
    "Middle Eastern",
    "Moroccan",
    "Peruvian",
    "Polish",
    "Russian",
    "Southern (Soul Food)",
    "Spanish",
    "Tex-Mex",
    "Thai",
    "Turkish",
    "Vietnamese"
]

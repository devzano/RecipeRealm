//
//  RecipeAppSharedData.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/29/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import Photos
import PhotosUI
import AVFoundation
import SwiftMessages

//struct DeepLinkedRecipe {
//    var id: String?
//    var title: String?
//    var prepTime: String?
//    var cookTime: String?
//    var cuisines: String?
//    var ingredients: String?
//    var steps: String?
//    var notes: String?
//}

// MARK: - App States
class AppStates: ObservableObject {
    // MARK: Request Library & Photo Access
    @Published var photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
    @Published var cameraAuthorizationStatus = AVAuthorizationStatus.authorized
    // MARK: Image Source & Picker
    @Published var imageSource: ImageSource = .photoLibrary
    @Published var showSourcePicker = false
    @Published var showImagePicker = false
    // MARK: Text
    @Published var imageSearch = ""
    @Published var currentStepNumber: Int = 1
    @Published var currentBullet: String = "•"
    // MARK: Alerts
    @Published var showDeleteConfirmation = false
    @Published var showAlert = false
    // MARK: UIViews
    @Published var isColorPickerVisible = false
    @Published var showWebView: Bool = false
    @Published var isSearchingImage = false
    // MARK: DeepLink URL Handling
    @Published var deepNewRecipeView: Bool = false
    let appScheme = "RecipeRealm"
    let appHost = "app"
    let appPath = "/recipe"
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @Published var isListView: Bool = UserDefaults.standard.bool(forKey: selectedViewKey)
    @Published var selectedAccentColor: Color = UserDefaults.standard.color(forKey: selectedAccentColorKey) ?? .accentColor

}

let selectedAccentColorKey = "SelectedAccentColor"
let selectedViewKey = "SelectedView"

// MARK: - Device Zoomed Check & Text Size
var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
var sizeCategory: ContentSizeCategory {
    mapContentSizeCategory(UIApplication.shared.preferredContentSizeCategory)
}

func adjustedFontSize(baseSize: CGFloat, sizeCategory: ContentSizeCategory) -> CGFloat {
    switch sizeCategory {
    case .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge:
        return baseSize
    case .extraSmall: return baseSize * 0.8
    case .small: return baseSize * 0.9
    case .medium: return baseSize
    default: return baseSize
    }
}

func mapContentSizeCategory(_ uiContentSizeCategory: UIContentSizeCategory) -> ContentSizeCategory {
    switch uiContentSizeCategory {
    case .extraSmall: return .extraSmall
    case .small: return .small
    case .medium: return .medium
    case .large: return .large
    case .extraLarge: return .extraLarge
    case .extraExtraLarge: return .extraExtraLarge
    case .extraExtraExtraLarge: return .extraExtraExtraLarge
    default: return .medium
    }
}

// MARK: - Placeholder Editor
struct PlaceholderTextEditorView: View {
    @Binding var text: String
    var placeholder: String
    let baseSize: CGFloat = 19
    
    var body: some View {
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)

        return ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding()
            }
            TextEditor(text: $text)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                .foregroundColor(Color.primary)
        }.font(.system(size: textSize))
    }
}

// MARK: - Section Header Titles
struct SectionHeaderTitlesView: View {
    let title: String
    let baseSize: CGFloat = 19

    var body: some View {
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        return Text(title)
            .font(.system(size: textSize))
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
struct NutritionBadges: Codable {
    var glutenFree: Bool
    var sugarFree: Bool
    var dairyFree: Bool
    var gmoFree: Bool
    var organic: Bool
    var vegetarian: Bool
    var peanutFree: Bool
    var nutFree: Bool
    var eggFree: Bool
    var noTransFat: Bool
    var cornFree: Bool
    var soyFree: Bool
}

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

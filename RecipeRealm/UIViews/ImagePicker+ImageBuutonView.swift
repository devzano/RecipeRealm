//
//  ImagePicker+ImageBuutonView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/17/23.
//

import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

// MARK: - ImageSource Enumeration

enum ImageSource {
    case photoLibrary
    case camera
    
    var sourceType: UIImagePickerController.SourceType {
        switch self {
        case .photoLibrary:
            return .photoLibrary
        case .camera:
            return .camera
        }
    }
}

// MARK: - ImagePicker View

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    init(image: Binding<UIImage?>, source: ImageSource) {
        _image = image
        sourceType = source.sourceType
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?
        init(image: Binding<UIImage?>) {
            self._image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - ImagePicker Sheet View

struct ImagePickerSheetView: View {
    @Binding var showImagePicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var imageSource: ImageSource
    @Binding var photoLibraryAuthorizationStatus: PHAuthorizationStatus
    @Binding var cameraAuthorizationStatus: AVAuthorizationStatus

    var body: some View {
        VStack {
            if photoLibraryAuthorizationStatus == .authorized && cameraAuthorizationStatus == .authorized {
                ImagePickerView(image: $selectedImage, source: imageSource).onChange(of: selectedImage) { newValue in
                    if newValue != nil {
                        showImagePicker = false
                    }
                }
            } else {
                if photoLibraryAuthorizationStatus != .authorized && cameraAuthorizationStatus != .authorized {
                    Text("Go to Settings app to allow access to both photo library and camera.")
                } else if photoLibraryAuthorizationStatus != .authorized {
                    Text("Go to Settings app to allow photo library access.")
                } else {
                    Text("Go to Settings app to allow camera access.")
                }
                Button(action: {
                    showImagePicker = false
                    openSettings()
                }) {
                    Text("Settings")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            requestCameraAccess(cameraAuthorizationStatus: $cameraAuthorizationStatus)
            requestPhotoLibraryAccess(photoLibraryAuthorizationStatus: $photoLibraryAuthorizationStatus)
        }
    }
}

// MARK: - ImagePicker Button

struct ImagePickerButton: View {
    @Binding var showSourcePicker: Bool
    @Binding var showImagePicker: Bool
    @Binding var imageSource: ImageSource
    @Binding var photoLibraryAuthorizationStatus: PHAuthorizationStatus
    @Binding var cameraAuthorizationStatus: AVAuthorizationStatus
    
    var body: some View {
        Button(action: {
            showSourcePicker = true
            requestPhotoLibraryAccess(photoLibraryAuthorizationStatus: $photoLibraryAuthorizationStatus)
            requestCameraAccess(cameraAuthorizationStatus: $cameraAuthorizationStatus)
        }) {
            HStack {
                Image(systemName: "photo.on.rectangle")
                Text("Upload Image")
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .actionSheet(isPresented: $showSourcePicker) {
            ActionSheet(title: Text("Select Image Source"), message: nil, buttons: [
                .default(Text("Photo Library")) {
                    imageSource = .photoLibrary
                    requestPhotoLibraryAccess(photoLibraryAuthorizationStatus: $photoLibraryAuthorizationStatus)
                    showImagePicker = true
                },
                .default(Text("Camera")) {
                    imageSource = .camera
                    requestCameraAccess(cameraAuthorizationStatus: $cameraAuthorizationStatus)
                    showImagePicker = true
                },
                .cancel()
            ])
        }
    }
}

// MARK: - Image Helper Functions

func requestPhotoLibraryAccess(photoLibraryAuthorizationStatus: Binding<PHAuthorizationStatus>) {
    PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
            photoLibraryAuthorizationStatus.wrappedValue = status
        }
    }
}

func requestCameraAccess(cameraAuthorizationStatus: Binding<AVAuthorizationStatus>) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
            let status: AVAuthorizationStatus = granted ? .authorized : .denied
            cameraAuthorizationStatus.wrappedValue = status
        }
    }
}

func openSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
        return
    }
    UIApplication.shared.open(settingsURL)
}

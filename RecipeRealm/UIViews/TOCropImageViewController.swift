//
//  TOCropImageViewController.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/25/23.
//

import SwiftUI
import TOCropViewController

struct TOCropImageViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TOCropImageViewController>) -> TOCropViewController {
        guard let image = selectedImage else {
            fatalError("Image must not be nil")
        }
        let croppingStyle: TOCropViewCroppingStyle = .default
        let cropViewController = TOCropViewController(croppingStyle: croppingStyle, image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: TOCropViewController, context: UIViewControllerRepresentableContext<TOCropImageViewController>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: TOCropImageViewController
        
        init(_ parent: TOCropImageViewController) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: TOCropViewController, didCropTo selectedImage: UIImage, with cropRect: CGRect, angle: Int) {
            parent.selectedImage = selectedImage
            parent.isPresented = false
        }
        
        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            parent.isPresented = false
        }
    }
}

struct TOCropImageView: View {
    @Binding var selectedImage: UIImage?
    @State private var showTOCropViewController = false
    
    var body: some View {
        VStack {
            Button(action: {
                showTOCropViewController = true
            }) {
                HStack {
                    Image(systemName: "crop")
                    Text("Crop")
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }.sheet(isPresented: $showTOCropViewController) {
            TOCropImageViewController(selectedImage: $selectedImage, isPresented: $showTOCropViewController)
        }
    }
}

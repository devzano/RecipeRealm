//
//  TOCropImageViewController.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/25/23.
//

import SwiftUI
import TOCropViewController

struct TOCropImageViewController: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<TOCropImageViewController>) -> TOCropViewController {
        guard let image = image else {
            fatalError("Image must not be nil")
        }

        let croppingStyle: TOCropViewCroppingStyle = .default
        return TOCropViewController(croppingStyle: croppingStyle, image: image)
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

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.image = image
            parent.isPresented = false
        }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            parent.isPresented = false
        }
    }
}

//
//  TOCropImageView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/25/23.
//

import SwiftUI

struct TOCropImageView: View {
    @Binding var image: UIImage?
    @State private var showTOCropViewController = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Select an Image to crop")
            }
            Button("Crop Image") {
                showTOCropViewController = true
            }
        }.sheet(isPresented: $showTOCropViewController) {
            TOCropImageViewController(image: $image, isPresented: $showTOCropViewController)
        }
    }
}

//
//  ActivityIndicatorView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/20/23.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = UIColor(Color.accentColor)
        view.startAnimating()
        return view
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityIndicatorView()
                .previewLayout(.sizeThatFits)
                .padding()
            
            ActivityIndicatorView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
                .padding()
        }
    }
}

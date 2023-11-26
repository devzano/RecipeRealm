//
//  GoogleImageSearchView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 8/26/23.
//

import SwiftUI

struct GoogleImageSearchView: View {
    @Binding var isPresented: Bool
    @Binding var searchQuery: String
    
    var body: some View {
        if let request = constructedURLRequest {
            WebViewWithButtonRepresentable(request: request, showScanButton: false, showCloseButton: true)
        } else {
            Text("Invalid URL")
        }
    }
    
    private var constructedURLRequest: URLRequest? {
        guard let safeInput = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(safeInput)&tbm=isch") else {
            return nil
        }
        return URLRequest(url: url)
    }
}

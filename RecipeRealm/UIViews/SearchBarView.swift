//
//  SearchBarView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/17/23.
//

import SwiftUI

struct SearchBarView: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @EnvironmentObject var appStates: AppStates

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = UIColor(appStates.selectedAccentColor)
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.delegate = context.coordinator
        searchBar.tintColor = UIColor(appStates.selectedAccentColor)
        return searchBar
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: self.$text)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}

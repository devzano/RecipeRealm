//
//  TabBarView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 10/13/23.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appStates: AppStates
    
    var body: some View {
        let baseSize: CGFloat = 19
        let imageSize: CGFloat = 20
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        HStack(spacing: 25) {
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "fork.knife.circle.fill").font(.system(size: imageSize))
                    Text("Recipes")
                }
            }
            .padding()
            .foregroundColor(selectedTab == 0 ? appStates.selectedAccentColor : Color.gray)
            
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "plus.circle.fill").font(.system(size: imageSize))
                    Text("New Recipe")
                }
            }
            .padding()
            .foregroundColor(selectedTab == 1 ? appStates.selectedAccentColor : Color.gray)
            
//            Button(action: { selectedTab = 2 }) {
//                VStack {
//                    Image(systemName: "gearshape.circle.fill").font(.system(size: imageSize))
//                    Text("Options")
//                }
//            }
//            .padding()
//            .foregroundColor(selectedTab == 2 ? appStates.selectedAccentColor : Color.gray)
        }
        .font(.system(size: textSize))
        .frame(height: 40)
        .background(Color.clear)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedTab: .constant(0))
            .environmentObject(AppStates())
    }
}

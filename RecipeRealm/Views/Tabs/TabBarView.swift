//
//  TabBarView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 10/13/23.
//

import Foundation
import Combine
import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    @ObservedObject var appStates = AppStates()
    @State private var shouldShowAd: Bool = true
    @State private var isKeyboardVisible = false

    var body: some View {
        let baseSize: CGFloat = 19
        let imageSize: CGFloat = 30
        let textSize = adjustedFontSize(baseSize: baseSize, sizeCategory: sizeCategory)
        
        if !isKeyboardVisible {
            VStack {
                // AdBannerView above the custom tab bar
                if shouldShowAd {
                    AdBannerView(adUnitID: "ca-app-pub-7336849218717327/9263282007", shouldShowAd: $shouldShowAd) // AdBanner 1
                    //                    AdBannerView(adUnitID: "ca-app-pub-7336849218717327/9815199359", shouldShowAd: $shouldShowAd) // AdBanner 2
                    //                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2435281174", shouldShowAd: $shouldShowAd) // Google Test Unit
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                        .shadow(radius: 5)
                }
                
                HStack {
                    Button(action: { self.selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "fork.knife.circle.fill").font(.system(size: imageSize))
                        }
                    }
                    .padding()
                    .foregroundColor(selectedTab == 0 ? appStates.selectedAccentColor : Color.gray)
                    Spacer()
                    Button(action: { self.selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "plus.circle.fill").font(.system(size: imageSize))
                        }
                    }
                    .padding()
                    .foregroundColor(selectedTab == 1 ? appStates.selectedAccentColor : Color.gray)
                    Spacer()
                    Button(action: { self.selectedTab = 2 }) {
                        VStack {
                            Image(systemName: "message.circle.fill").font(.system(size: imageSize))
                        }
                    }
                    .padding()
                    .foregroundColor(selectedTab == 2 ? appStates.selectedAccentColor : Color.gray)
                    Spacer()
                    Button(action: { self.selectedTab = 3 }) {
                        VStack {
                            Image(systemName: "gearshape.circle.fill").font(.system(size: imageSize))
                        }
                    }
                    .padding()
                    .foregroundColor(selectedTab == 3 ? appStates.selectedAccentColor : Color.gray)
                }
                .font(.system(size: textSize))
                .frame(height: 30)
                .padding(.bottom, 0)
                .background(Color.clear)
            }.onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = true
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = false
                }
            }
        }
    }
}

#Preview {
    TabBarView(selectedTab: .constant(0))
        .environmentObject(AppStates())
}

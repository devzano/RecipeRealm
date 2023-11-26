//
//  RecipeAssistantView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 11/19/23.
//

import SwiftUI
import UIKit

struct RecipeAssistantView: View {
    @ObservedObject var cm: ChatModel
    @ObservedObject var appStates = AppStates()
    @State private var showAlert = false

    var body: some View {
        VStack {
            HStack {
                if !cm.messages.dropFirst().isEmpty {
                    Button(action: {
                        showStartNewChatAlert()
                    }) {
                        Image(systemName: "plus.message.fill")
                            .foregroundColor(.red)
                    }
                }
                Spacer()
            }.padding(.horizontal)

            ScrollViewReader { scrollView in
                ScrollView {
                    ForEach(cm.messages, id: \.id) { message in
                        if message.id != "prompt" {
                            messageView(message: message)
                        }
                    }
                }
                .onChange(of: cm.messages) { _ in
                    if let lastMessage = cm.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Ask about a recipe or cooking tip!", text: $cm.text)
                    .padding()
                    .background(appStates.selectedAccentColor.opacity(0.3)).cornerRadius(13.0)
                    .ignoresSafeArea()
                Button(action: {
                    cm.sendMessage()
                }) {
                    Image(systemName: "arrow.forward")
                        .foregroundColor(appStates.selectedAccentColor)
                }
            }
        }.padding()
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .foregroundColor(message.role == .user ? .primary : .primary)
                .padding()
                .background(message.role == .user ? appStates.selectedAccentColor.opacity(0.3) : .gray.opacity(0.1))
                .cornerRadius(16)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = message.content
                    }) {
                        Text("Copy")
                        Image(systemName: "doc.on.doc")
                    }
                }
            if message.role == .assistant { Spacer() }
        }
    }
    
    func clearChat() {
        cm.messages.removeAll()
    }
    
    func showStartNewChatAlert() {
        let alertController = UIAlertController(title: "New Chat", message: "Starting a new chat will clear the current chat. Are you sure you want to proceed?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        let startNewChatAction = UIAlertAction(title: "Yes", style: .default) { _ in
            clearChat()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(startNewChatAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            let uiColor = UIColor(appStates.selectedAccentColor)
            alertController.view.tintColor = uiColor
            viewController.present(alertController, animated: true)
        }
    }
}

#Preview {
    RecipeAssistantView(cm: ChatModel())
        .environmentObject(AppStates())
}

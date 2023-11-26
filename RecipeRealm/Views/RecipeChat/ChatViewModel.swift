//
//  ChatViewModel.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 11/19/23.
//

import Foundation
import SwiftUI
import UIKit
import SwiftMessages

class ChatModel: ObservableObject {
    @Published var messages: [Message] = [Message(id: "prompt", role: .system, content: "You are a chef assistant. You will help in all needs in the kitchen. You are strictly made to only answer anything cooking or recipe related. ONLY and ONLY if the user mentions 'RecipeRealm It' convert the recipe or create a recipe to be in this format: \nTitle:\nCuisine:\nPrep Time:\nCook Time:\nIngredients:\nSteps:\nNotes:\n. When giving the Ingredients:\nSteps:\nNotes:\n do not put dashes or numbers before the text, just display the text. ALSO for Prep Time:\nCook Time:\n abbreviate hours to 'hrs' and minutes to 'm'.", createdAt: Date())]
    @Published var text: String = ""
    
    private let openAIService = OpenAIService()
    private let maxDailyMessages: Int = 12
    private var dailyMessageCount: Int {
        get {
            let currentDate = Date()
            let lastResetDate = UserDefaults.standard.object(forKey: "DailyMessageResetDate") as? Date
            
            if let lastResetDate = lastResetDate, !Calendar.current.isDate(currentDate, inSameDayAs: lastResetDate) {
                UserDefaults.standard.set(currentDate, forKey: "DailyMessageResetDate")
                UserDefaults.standard.set(0, forKey: "DailyMessageCount")
                return 0
            } else {
                return UserDefaults.standard.integer(forKey: "DailyMessageCount")
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "DailyMessageCount")
        }
    }

    func sendMessage() {
        if dailyMessageCount >= maxDailyMessages {
            let dailyLimitMessage = MessageView.viewFromNib(layout: .cardView)
            dailyLimitMessage.configureTheme(.warning)
            dailyLimitMessage.configureDropShadow()
            dailyLimitMessage.button?.isHidden = true
            dailyLimitMessage.configureContent(title: "Message Limit Reached", body: "You've hit the maximum number of messages allowed for today.")
            SwiftMessages.defaultConfig.duration = .seconds(seconds: 4)
            SwiftMessages.show(view: dailyLimitMessage)
            
            return
        }
        
        let newMessage = Message(id: UUID().uuidString, role: .user, content: text, createdAt: Date())
        messages.append(newMessage)
        text = ""
        
        dailyMessageCount += 1
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        openAIService.sendStreamMessage(messages: messages).responseStreamString { [weak self] stream in
            guard let self = self else { return }
            switch stream.event {
            case .stream(let response):
                switch response {
                case .success(let string):
                    let streamResponse = self.parseStreamData(string)
                    streamResponse.forEach { newMessageResponse in
                        guard let messageContent = newMessageResponse.choices.first?.delta.content else {
                            return
                        }
                        guard let existingMessageIndex = self.messages.lastIndex(where: { $0.id == newMessageResponse.id }) else {
                            let newMessage = Message(id: newMessageResponse.id, role: .assistant, content: messageContent, createdAt: Date())
                            self.messages.append(newMessage)
                            return
                        }
                        let newMessage = Message(id: newMessageResponse.id, role: .assistant, content: self.messages[existingMessageIndex].content + messageContent, createdAt: Date())
                        self.messages[existingMessageIndex] = newMessage
                    }
                case .failure(_):
                    print("FAILURE")
                }
            case .complete(_):
                print("COMPLETE")
            }
        }
    }
    
    func parseStreamData(_ data: String) -> [ChatStreamCompletionResponse] {
        let responseStrings = data.components(separatedBy: "data:").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter({ !$0.isEmpty })

        let jsonDecoder = JSONDecoder()
        
        return responseStrings.compactMap { jsonString in
            guard let jsonData = jsonString.data(using: .utf8),
                  let streamResponse = try? jsonDecoder.decode(ChatStreamCompletionResponse.self, from: jsonData) else {
                return nil
            }
            return streamResponse
        }
    }
}

struct Message: Decodable, Equatable {
    let id: String
    let role: SenderRole
    let content: String
    let createdAt: Date
}

struct ChatStreamCompletionResponse: Decodable {
    let id: String
    let choices: [ChatStreamChoice]
}

struct ChatStreamChoice: Decodable {
    let delta: ChatStreamContent
}

struct ChatStreamContent: Decodable {
    let content: String
}

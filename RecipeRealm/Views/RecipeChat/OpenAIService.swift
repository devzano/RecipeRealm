//
//  OpenAIService.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 11/19/23.
//

import Foundation
import Alamofire

class OpenAIService {
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(messages: [Message]) async -> OpenAIChatReponse? {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-4", messages: openAIMessages, stream: false)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        return try? await AF.request(endpoint, method: .post, parameters: body, encoder: .json, headers: headers).serializingDecodable(OpenAIChatReponse.self).value
    }
    
    func sendStreamMessage(messages: [Message]) -> DataStreamRequest {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-4", messages: openAIMessages, stream: true)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        return AF.streamRequest(endpoint, method: .post, parameters: body, encoder: .json, headers: headers)
    }
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
    let stream: Bool
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct OpenAIChatReponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}

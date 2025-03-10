//
//  ContentView.swift
//  ChatReaction
//
//  Created by Vincent on 10/03/2025.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var reactions: [String] = []
}

struct ChatBubble: View {
    let message: Message
    var onReactionAdded: (String) -> Void
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            VStack(alignment: message.isUser ? .trailing : .leading) {
                // Wrap in ZStack to customize appearance
                Text(message.content)
                    .padding()
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.isUser ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .contentShape(
                        .contextMenuPreview,
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .contextMenu {
                        Button(action: { onReactionAdded("❤️") }) {
                            Text("❤️ Love")
                        }
                        Button(action: { onReactionAdded("👍") }) {
                            Text("👍 Like")
                        }
                        Button(action: { onReactionAdded("😂") }) {
                            Text("😂 Laugh")
                        }
                        Button(action: { onReactionAdded("😮") }) {
                            Text("😮 Wow")
                        }
                    }
                
                if !message.reactions.isEmpty {
                    HStack {
                        ForEach(message.reactions, id: \.self) { reaction in
                            Text(reaction)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @State private var timer: Timer? = nil
    @State private var scrolledToBottom = false
    private let sampleResponses = [
        "How's your day going?",
        "That's interesting!",
        "Tell me more about that.",
        "I see what you mean.",
        "That's a great point!",
        "What do you think about that?"
    ]
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages.indices, id: \.self) { index in
                            ChatBubble(message: messages[index]) { reaction in
                                addReaction(to: index, reaction: reaction)
                            }
                            .id(index)
                        }
                    }
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(
                            messages.count - 1,
                            anchor: .bottom
                        )
                    }
                }
                .onAppear {
                    if !scrolledToBottom && !messages.isEmpty {
                        DispatchQueue.main.async {
                            withAnimation(nil) {
                                proxy.scrollTo(
                                    messages.count - 1,
                                    anchor: .bottom
                                )
                            }
                            scrolledToBottom = true
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
        .onAppear {
            generateMockConversation()
            startMessageTimer()
        }
        .onDisappear {
            stopMessageTimer()
        }
    }
    
    private func addReaction(to index: Int, reaction: String) {
        messages[index].reactions.append(reaction)
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let newMessage = Message(
            content: inputText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(newMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = Message(
                content: "Thanks for your message!",
                isUser: false,
                timestamp: Date()
            )
            messages.append(botResponse)
        }
        
        inputText = ""
    }
    
    private func startMessageTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true
        ) { _ in
            simulateIncomingMessage()
        }
    }
    
    private func stopMessageTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func simulateIncomingMessage() {
        let randomMessage = sampleResponses.randomElement() ?? "Hello there!"
        let botMessage = Message(
            content: randomMessage,
            isUser: false,
            timestamp: Date()
        )
        messages.append(botMessage)
    }
    
    private func generateMockConversation() {
        // Initial messages
        let mockConversation: [Message] = [
            Message(content: "Hello!", isUser: false, timestamp: Date().addingTimeInterval(-3600)),
            Message(content: "Hi there! How are you?", isUser: true, timestamp: Date().addingTimeInterval(-3550)),
            Message(content: "I'm doing great! Thanks for asking.", isUser: false, timestamp: Date().addingTimeInterval(-3500)),
            Message(content: "What can I help you with today?", isUser: false, timestamp: Date().addingTimeInterval(-3450)),
            Message(content: "I was wondering if you could help me with a project.", isUser: true, timestamp: Date().addingTimeInterval(-3400)),
            Message(content: "Of course! What kind of project are you working on?", isUser: false, timestamp: Date().addingTimeInterval(-3350)),
            Message(content: "I'm building a chat app with SwiftUI.", isUser: true, timestamp: Date().addingTimeInterval(-3300)),
            Message(content: "That sounds exciting! SwiftUI is great for building interactive UIs.", isUser: false, timestamp: Date().addingTimeInterval(-3250)),
            Message(content: "Yes, I'm particularly interested in adding reactions to messages.", isUser: true, timestamp: Date().addingTimeInterval(-3200)),
            Message(content: "That's a good feature! Similar to how iMessage and other chat apps work.", isUser: false, timestamp: Date().addingTimeInterval(-3150)),
            Message(content: "Exactly! I want users to be able to react with emojis.", isUser: true, timestamp: Date().addingTimeInterval(-3100)),
            Message(content: "Have you thought about how you'll implement that feature?", isUser: false, timestamp: Date().addingTimeInterval(-3050)),
            Message(content: "I'm thinking of using a context menu or maybe a custom gesture.", isUser: true, timestamp: Date().addingTimeInterval(-3000)),
            Message(content: "Both approaches could work well. Context menus are built into SwiftUI.", isUser: false, timestamp: Date().addingTimeInterval(-2950))
        ]
        
        // Add some reactions to make it more realistic
        var messagesWithReactions = mockConversation
        messagesWithReactions[1].reactions = ["👍"]
        messagesWithReactions[3].reactions = ["❤️"]
        messagesWithReactions[8].reactions = ["😂", "👍"]
        messagesWithReactions[11].reactions = ["😮"]
        
        self.messages = messagesWithReactions
    }
}

#Preview {
    ContentView()
}

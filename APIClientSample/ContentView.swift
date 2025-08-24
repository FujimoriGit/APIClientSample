//
//  ContentView.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  SampleWidget
//
//  Created by Noriyuki Yoshida on 2024/12/03.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var inputText = ""
    
    private let locationManagerHelper = LocationManagerHelper()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            HStack {
                TextField("適当な文字列を入力してください", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button(action: {
                    saveText()
                }, label: {
                    Text("保存")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                })
                .tint(.white)
                .background(.blue)
                .clipShape(.capsule)
            }
            
            Button(action: {
                requestLocationPermission()
            }, label: {
                Text("request location")
            })
        }
        .padding()
    }
    
    func saveText() {
        let userdefaults = UserDefaults(suiteName: "group.net.noricoffee.SampleWidget.widget")
        userdefaults?.set(inputText, forKey: "sampleAppInputText")
    }
    
    private func requestLocationPermission() {
        locationManagerHelper.requestPermission()
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  ModelViewer
//
//  Created by Sergio Barrio on 31/1/23.
//

import SwiftUI
import SceneKit
import AVFoundation

struct ContentView: View {
    @State private var modelIndex = 0
    @State private var currentModel: String?
    private var modelList: [String]
    private var audioPlayer: AVAudioPlayer!

    init() {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            modelList = files.filter { $0.hasSuffix(".obj") }
        } else {
            modelList = []
        }
                
        if !modelList.isEmpty {
            _currentModel = State(initialValue: modelList[modelIndex])
        }
        
        playMusic()
    }

    var body: some View {
        VStack {
            HStack {
                Text("Model Viewer")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    goLeft()
                }) {
                    Image(systemName: "arrow.left")
                }
                Spacer()
                if let currentModel = currentModel {
                    Text(currentModel)
                        .font(.title3)
                        .foregroundColor(.blue)
                } else {
                    Text("No models found")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: {
                    goRight()
                }) {
                    Image(systemName: "arrow.right")
                }
                Spacer()
            }
            if let currentModel = currentModel {
                ModelView(filename: currentModel)
                .gesture(
                    DragGesture(minimumDistance: 100)
                        .onEnded { value in
                            if value.translation.width < 0 {
                                goRight()
                            } else {
                                goLeft()
                            }
                        }
                    )
            }
        }
    }

    func goLeft() {
        if modelIndex > 0 {
            modelIndex -= 1
            currentModel = modelList[modelIndex]
        }
    }

    func goRight() {
        if modelIndex < modelList.count - 1 {
            modelIndex += 1
            currentModel = modelList[modelIndex]
        }
    }
    
    mutating func playMusic() {
        // Audio player setup
        if let soundURL = Bundle.main.url(forResource: "bg_music", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer.numberOfLoops = -1 // Loop indefinitely
                audioPlayer.play()
            } catch {
                print("Failed to initialize audio player: \(error.localizedDescription)")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


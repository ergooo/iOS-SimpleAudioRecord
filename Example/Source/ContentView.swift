//
//  ContentView.swift
//  Example
//  
//  Created by masato on 2020/05/06
//  Copyright © 2020 masato. All rights reserved.
//

import SwiftUI
import SimpleAudioRecord

struct ContentView: View {
    @State var pcm: Data = Data()

    private let audioRecord = SimpleAudioRecord(audioConfig: AudioConfig(sampleRate: 16000, bitsPerChannel: 16, channelsPerFrame: 1))

    var body: some View {
        VStack {
            Button(action: {
                self.audioRecord.onBufferReceived = { data in
                    self.pcm.append(data)
                }
                self.audioRecord.startRecording()
            }) {
                Text("Start")
            }
            Button(action: {
                self.audioRecord.stopRecording()
                self.save()
            }) {
                Text("Stop")
            }
        }
    }
    
    private func save() {
        let file = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SimpleAudioRecord.raw")
        print(file)
        do {
            try pcm.write(to: file)
            print("success")
        } catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

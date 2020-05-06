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
    let audioRecord = SimpleAudioRecord()
    let callback: (Data) -> Void = { data in
        print(data)
    }
    var body: some View {
        VStack {
            Button(action: {
                self.audioRecord.onBufferReceived = self.callback
                self.audioRecord.startRecording()
            }) {
                Text("Start")
            }
            Button(action: {
                self.audioRecord.stopRecording()
            }) {
                Text("Stop")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

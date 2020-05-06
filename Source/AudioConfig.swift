//
//  AudioConfig.swift
//  SimpleAudioRecord
//  
//  Created by masato on 2020/05/06
//  Copyright © 2020 masato. All rights reserved.
//

import Foundation

public struct AudioConfig {
    let sampleRate: Int
    let bitsParChannel: Int
    let channelsPerFrame: Int
    
    let framesPerPacket = 1
    let bytesPerFrame :Int
    let bytesPerPacket :Int

    public init(sampleRate: Int, bitsParChannel: Int, channelsPerFrame: Int) {
        self.sampleRate = sampleRate
        self.bitsParChannel = bitsParChannel
        self.channelsPerFrame = channelsPerFrame
        
        bytesPerFrame = bitsParChannel / 8 * channelsPerFrame
        bytesPerPacket = bytesPerFrame * framesPerPacket
    }
}

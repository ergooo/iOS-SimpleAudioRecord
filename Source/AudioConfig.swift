//
//  AudioConfig.swift
//  SimpleAudioRecord
//  
//  Created by masato on 2020/05/06
//  Copyright © 2020 masato. All rights reserved.
//

import Foundation

///
/// Configuration about audio source.
///
public struct AudioConfig {
    let sampleRate: Int
    let bitsPerChannel: Int
    let channelsPerFrame: Int
    
    let framesPerPacket = 1
    let bytesPerFrame :Int
    let bytesPerPacket :Int

    ///
    /// - Parameter sampleRate: Sampling rate in Hz like 16000, 48000.
    /// - Parameter bitsPerChannel: Like 8bits, 16bits.
    /// - Parameter channelsPerFrame: Number of input channels. You may increase this number depending on the number of microphones in each device.
    public init(sampleRate: Int, bitsPerChannel: Int, channelsPerFrame: Int) {
        self.sampleRate = sampleRate
        self.bitsPerChannel = bitsPerChannel
        self.channelsPerFrame = channelsPerFrame
        
        bytesPerFrame = bitsPerChannel / 8 * channelsPerFrame
        bytesPerPacket = bytesPerFrame * framesPerPacket
    }
}

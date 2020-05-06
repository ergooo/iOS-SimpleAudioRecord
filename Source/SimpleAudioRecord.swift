//
//  SimpleAudioRecord.swift
//  SimpleAudioRecord
//  
//  Created by masato on 2020/05/05
//  Copyright © 2020 masato. All rights reserved.
//

import Foundation
import AVFoundation

public class SimpleAudioRecord {
    public var onBufferReceived: (Data) -> Void = { _ in }
    private let audioConfig: AudioConfig
    private var audioQueue: AudioQueueRef?

    public init(audioConfig: AudioConfig) {
        self.audioConfig = audioConfig
    }

    public func startRecording() {
        if audioQueue != nil {
            return
        }
        prepare()

        if let audioQueue = audioQueue {
            AudioQueueStart(audioQueue, nil)
        }
    }
    
    public func stopRecording() {
        if let audioQueue = audioQueue {
            AudioQueueStop(audioQueue, true)
            AudioQueueDispose(audioQueue, true)
            self.audioQueue = nil
        }
    }
    
    private func prepare() {
         var format = AudioStreamBasicDescription(
            mSampleRate: Float64(audioConfig.sampleRate),
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
            mBytesPerPacket: UInt32(audioConfig.bytesPerPacket),
            mFramesPerPacket: UInt32(audioConfig.framesPerPacket),
            mBytesPerFrame: UInt32(audioConfig.bytesPerFrame),
            mChannelsPerFrame: UInt32(audioConfig.channelsPerFrame),
            mBitsPerChannel: UInt32(audioConfig.bitsParChannel),
            mReserved: 0
         )
                
        AudioQueueNewInput(
            &format,
            callback,
            Unmanaged<SimpleAudioRecord>.passUnretained(self).toOpaque(),
            nil,
            nil,
            0,
            &audioQueue
        )
        
        guard let audioQueue = audioQueue else { return }
        
        let bufferSize = getBufferSize()
        for _ in 0..<3 {
            let bufferRef = UnsafeMutablePointer<AudioQueueBufferRef?>.allocate(capacity: 1)
            AudioQueueAllocateBuffer(audioQueue, UInt32(bufferSize), bufferRef)
            if let buffer = bufferRef.pointee {
                AudioQueueEnqueueBuffer(audioQueue, buffer, 0, nil)
            }
        }
    }
    
    private func getBufferSize() -> Int {
        return 1024 * audioConfig.bytesPerPacket
    }
    
    private let callback: AudioQueueInputCallback = { inUserData,inAQ,inBuffer,_,_,_ in
        guard let inUserData = inUserData else { return }

        let inputCallback = Unmanaged<SimpleAudioRecord>.fromOpaque(inUserData).takeUnretainedValue()
        
        let pcm = Data(bytes: inBuffer.pointee.mAudioData, count: Int(inBuffer.pointee.mAudioDataByteSize))
        inputCallback.onBufferReceived(pcm)

        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    }
}

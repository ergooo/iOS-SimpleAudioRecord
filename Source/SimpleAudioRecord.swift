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
    public init() {}
    
    public var onBufferReceived: (Data) -> Void = { _ in }

    private var audioQueue: AudioQueueRef?

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
             mSampleRate: 48000.0,
             mFormatID: kAudioFormatLinearPCM,
             mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
             mBytesPerPacket: 2,
             mFramesPerPacket: 1,
             mBytesPerFrame: 2,
             mChannelsPerFrame: 1,
             mBitsPerChannel: 16,
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
            AudioQueueAllocateBuffer(audioQueue, bufferSize, bufferRef)
            if let buffer = bufferRef.pointee {
                AudioQueueEnqueueBuffer(audioQueue, buffer, 0, nil)
            }
        }
    }
    
    private func getBufferSize() -> UInt32 {
        return 1024 * 2
    }
    
    private let callback: AudioQueueInputCallback = { inUserData,inAQ,inBuffer,_,_,_ in
        guard let inUserData = inUserData else { return }

        let inputCallback = Unmanaged<SimpleAudioRecord>.fromOpaque(inUserData).takeUnretainedValue()
        
        let pcm = Data(bytes: inBuffer.pointee.mAudioData, count: Int(inBuffer.pointee.mAudioDataByteSize))
        inputCallback.onBufferReceived(pcm)

        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    }
}

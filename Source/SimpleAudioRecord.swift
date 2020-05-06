//
//  SimpleAudioRecord.swift
//  SimpleAudioRecord
//  
//  Created by masato on 2020/05/05
//  Copyright © 2020 masato. All rights reserved.
//

import Foundation
import AVFoundation

class SimpleAudioRecord {
    class InputCallback {
        let onBufferReceived: (Data) -> Void
        init(onBufferReceived: @escaping (Data) -> Void) {
            self.onBufferReceived = onBufferReceived
        }
    }

    private var audioQueue: AudioQueueRef?

    func startRecording(onBufferReceived: @escaping (Data) -> Void) {
        prepare(inputCallback: InputCallback(onBufferReceived: onBufferReceived))

        if let audioQueue = audioQueue {
            AudioQueueStart(audioQueue, nil)
        }
    }
    
    func stopRecording() {
        if let audioQueue = audioQueue {
            AudioQueueStop(audioQueue, true)
            AudioQueueDispose(audioQueue, true)
        }
    }
    
    private func prepare(inputCallback: InputCallback) {
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
            Unmanaged<InputCallback>.passUnretained(inputCallback).toOpaque(),
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
    
    private func setupAudioQueueNewInput(audioQueue: AudioQueueRef?, inputCallback: InputCallback) -> AudioQueueRef?{
        var audioQueue = audioQueue
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
           Unmanaged<InputCallback>.passUnretained(inputCallback).toOpaque(),
           nil,
           nil,
           0,
           &audioQueue
       )
        return audioQueue
    }
    
    private func allocateAndEnqueueBuffer(audioQueue: AudioQueueRef, bufferCount: Int = 3) {
        let bufferSize = getBufferSize()
        for _ in 0..<bufferCount {
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

        let inputCallback = Unmanaged<InputCallback>.fromOpaque(inUserData).takeUnretainedValue()
        
        let pcm = Data(bytes: inBuffer.pointee.mAudioData, count: Int(inBuffer.pointee.mAudioDataByteSize))
        inputCallback.onBufferReceived(pcm)

        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    }
    
        
}

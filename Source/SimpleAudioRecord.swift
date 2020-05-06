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
    private var isRecording = false

    public init(audioConfig: AudioConfig) {
        self.audioConfig = audioConfig
    }

    /// Start recording. Do nothing when it called during recording.
    public func startRecording() {
        synchronized(self) {
            if isRecording { return }
            prepare()

            if let audioQueue = audioQueue {
                AudioQueueStart(audioQueue, nil)
                isRecording = true
            }
        }
    }
    
    /// Stop recording. Do nothing if not recording.
    public func stopRecording() {
        synchronized(self) {
            if !isRecording { return }
            isRecording = false

            if let audioQueue = audioQueue {
                AudioQueueStop(audioQueue, true)
                AudioQueueDispose(audioQueue, true)
                self.audioQueue = nil
            }
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
            mBitsPerChannel: UInt32(audioConfig.bitsPerChannel),
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

        let audioRecord = Unmanaged<SimpleAudioRecord>.fromOpaque(inUserData).takeUnretainedValue()
        if !audioRecord.isRecording { return }
        let pcm = Data(bytes: inBuffer.pointee.mAudioData, count: Int(inBuffer.pointee.mAudioDataByteSize))
        audioRecord.onBufferReceived(pcm)

        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    }
    
    private func synchronized(_ obj: AnyObject, f: () -> Void) {
        objc_sync_enter(obj)
        f()
        objc_sync_exit(obj)
    }
}

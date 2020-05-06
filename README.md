# SimpleAudioRecord

## Installation

### Carthage

TBD

## Code examples

### Initialize

```swift
let audioConfig = AudioConfig(sampleRate: 16000, bitsPerChannel: 16, channelsPerFrame: 1)
let audioRecord = SimpleAudioRecord(audioConfig: audioConfig)
```

### Start recording

Before you start recording, you can set a callback function. This function will be called sequentially when it starts.

```swift
// set callback
audioRecord.onBufferReceived = { data in
    // do something
}
audioRecord.startRecording()
```

### Stop recording

```
audioRecord.stopRecording()
```

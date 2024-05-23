//
//  AudioStreamManager.swift
//  EasyInterview
//
//  Created by Anna Lerner on 5/15/24.
//

import Foundation
import AVFoundation
import SoundAnalysis

class AudioStreamManager {
    
    private var engine = AVAudioEngine()
    private var inputBus: AVAudioNodeBus = 0
    private var inputFormat: AVAudioFormat
    private var streamAnalyzer: SNAudioStreamAnalyzer
    private var classifyRequest: SNClassifySoundRequest?
    private var resultObserver = AudioStreamObserver()

    init() {
        inputFormat = engine.inputNode.inputFormat(forBus: inputBus)
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        startEngine()
        setupClassifier()
    }

    private func startEngine() {
        do {
            try engine.start()
        } catch {
            print("error starting engine")
        }
    }
    
    private func setupClassifier() {
        let defaultConfig = MLModelConfiguration()
        if let soundClassifier = try? BadSpeechClassifier10(configuration: defaultConfig) {
            classifyRequest = try? SNClassifySoundRequest(mlModel: soundClassifier.model)
        }
    }

    public func resultObservation(with observer: SNResultsObserving) {
        if let classifyRequest = classifyRequest {
            try? streamAnalyzer.add(classifyRequest, withObserver: observer)
        }
    }

    public func installTap() {
        engine.inputNode.installTap(onBus: inputBus, bufferSize: 1024, format: inputFormat, block: analyzeAudio(buffer:at:)) // may have to change buffer size in future
    }

    public func removeTap() {
        engine.inputNode.removeTap(onBus: inputBus)
    }

    public func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }
}

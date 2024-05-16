//
//  AudioStreamObserver.swift
//  EasyInterview
//
//  Created by Anna Lerner on 5/15/24.
//

import Foundation
import SoundAnalysis
import Combine

class AudioStreamObserver: NSObject, SNResultsObserving, ObservableObject {
    
    @Published var currentSound: String = ""
    @Published var confidence: Double = 0.0

    func request(_ request: SNRequest, didProduce result: SNResult) {
            if let result = result as? SNClassificationResult, let classification = result.classifications.first {
                        print("Classified Sound: \(classification.identifier)")
                        DispatchQueue.main.async {
                            self.currentSound = classification.identifier
                            self.confidence = classification.confidence
                    }
        }
    }
}

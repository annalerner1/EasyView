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
    @Published var warning:  String = ""
    
    @Published var direWarning: Bool = false
    
    private var warningStart: Date?
    private var warningTimer = Timer()
    

    func request(_ request: SNRequest, didProduce result: SNResult) {
            if let result = result as? SNClassificationResult, let classification = result.classifications.first {
                        print("Classified Sound: \(classification.identifier)")
                        DispatchQueue.main.async {
                            self.currentSound = classification.identifier
                            self.confidence = classification.confidence
                            self.checkWarnings()
                    }
        }
    }
    
    func checkWarnings() {
        if self.currentSound != "Talking" && self.currentSound != "Ambient" &&  self.confidence > 0.7 {
            self.warning = "Bad audio quality due to \(currentSound.lowercased())"
        } else {
            self.warning = ""
        }
    }
    
    func startWarningTimer() {
        self.warningTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { _ in
            if !self.warning.isEmpty {
                if self.warningStart == nil {
                    self.warningStart = Date()
                } else if let startTime = self.warningStart {
                    if Date().timeIntervalSince(startTime) >= 10 { // right now seeing if bad audio for 10 secs
                        self.direWarning = true
                    }
                }
            } else {
                self.warningStart = nil
                self.direWarning = false
            }
        })
    }
    
    
}

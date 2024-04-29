//
//  Recorder.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/26/24.
//

import Foundation
import AVFoundation

class Recorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    
    private let movieOutput = AVCaptureMovieFileOutput()
    
    override init() {
        Task(priority: .background) {
            if await AuthorizationChecker().checkAuthStatus() {
                // deal with permission allows
            } else {
                // deal with permissions denied
            }
        }
    }
    
    func startRecording() {
        guard session.canAddOutput(movieOutput) else {
            // need to add specific error later
            return
        }
        session
            .addOutput(movieOutput)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            // some problem with saving video file
            print(error)
        }
        //add code to save file
    }
    
}

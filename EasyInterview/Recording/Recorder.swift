//
//  Recorder.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/26/24.
//

import AVFoundation
import Photos

class Recorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    
    private let movieOutput = AVCaptureMovieFileOutput()
    
    override init() {
        super .init()
        Task(priority: .high) {
            if await AuthorizationChecker().checkAuthStatus() {
                addAudioInput()
                addVideoInput()
            } else {
                // deal with permissions denied
            }
        }
    }
    
    
    private func addAudioInput() {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            return // throw error instead
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return // throw error instead
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
    }
    
    private func addVideoInput() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return // throw error instead
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return // throw error instead
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
    }
    
    private func addFileOutput() {
        guard session.canAddOutput(movieOutput) else {
            return
        }
        session.addOutput(movieOutput)
    }
    
    
    func startRecording() {
        if !self.isRecording {
            isRecording = true
            session.startRunning()
        }
    }
    
    func stopRecording() {
        if self.isRecording {
            session.stopRunning()
            isRecording = false
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            // some problem with saving video file
            print(error)
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            
        }) { _, error in
            if let error = error {
                // error saving video, print something
            }
        }
    }
    
}

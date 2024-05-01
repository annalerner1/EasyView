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
        Task(priority: .background) {
            if await AuthorizationChecker().checkAuthStatus() {
                addAudioInput()
                addVideoInput()
                
                if session.canAddOutput(movieOutput) {
                    session.addOutput(movieOutput)
                } else {
                    print("Could not add movie output")
                }
                
                self.session.startRunning()
            } else {
                print("Authorization not working")
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
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("easyinterview.mp4") else {
                print("error generating url for user")
                return
                
            }
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
                movieOutput.startRecording(to: url, recordingDelegate: self)
                self.isRecording = true
                }
    }
    
    func stopRecording() {
        if self.isRecording {
            Task(priority: .background) {
                movieOutput.stopRecording()
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
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

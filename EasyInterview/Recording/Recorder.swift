//
//  Recorder.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/26/24.
//

import AVFoundation
import Photos
import Vision

class Recorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    
    private let movieOutput = AVCaptureMovieFileOutput()
    
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private var faceDetectionHandler: VNSequenceRequestHandler?
    
    override init() {
        super .init()
        faceDetectionHandler = VNSequenceRequestHandler()

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
        // new stuff
        let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                print("Could not add video data output")
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


extension Recorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        do {
            let request = VNDetectFaceRectanglesRequest {request, error in
                if let error = error {
                    print("Error performing face detection: \(error)")
                    return
                }
                
                guard let results = request.results as? [VNFaceObservation] else {
                    // need to throw an error here
                    return
                }
                
                if results.isEmpty {
                    print("No face detected")
                    // need to display a warning that the person is not in frame
                } else {
                    print("Face detected")
                        
                }
            }
            
            try faceDetectionHandler?.perform([request], on: pixelBuffer)
        } catch {
            print("Error performing face detection")
        }
    }
}

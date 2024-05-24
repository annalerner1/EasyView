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
    @Published var faceNotInFrame = false
    @Published var frontCamera = true
    
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
                    print("could not add movie output")
                }
                
                self.session.startRunning()
            } else {
                print("authorization not working")
            }
        }
    }
    
    
    private func addAudioInput() {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            print("cannot find audio for device")
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("trouble creating input for audio")
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("cannot add audio input")
        }
        
    }
    
    private func addVideoInput() {
        session.beginConfiguration()
        

        var currentInput: AVCaptureDeviceInput?
        for input in session.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput,
               deviceInput.device.hasMediaType(.video) {
                currentInput = deviceInput
                break
            }
        }
        
        if let unwrappedCurrentInput = currentInput {
                session.removeInput(unwrappedCurrentInput)
        }
                
   
        let position: AVCaptureDevice.Position = frontCamera ? .front : .back
           guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
               print("No video device available")
               session.commitConfiguration()
               return
           }
        session.commitConfiguration()

        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("could not add video input")
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("cannot add video input")
        }
        
        
        // for face detection
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
    
    func switchCamera() {
        self.frontCamera.toggle()
        if session.isRunning {
            self.addVideoInput()
        }
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
               print(error)
            }
        }
    }
    
    
}


extension Recorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if self.isRecording { // only need to monitor face if recording
            do {
                let request = VNDetectFaceRectanglesRequest {request, error in
                    if let error = error {
                        print("\(error)")
                        return
                    }
                    
                    guard let results = request.results as? [VNFaceObservation] else {
                        print("could properly cast face observations")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.faceNotInFrame = results.isEmpty
                    }
                }
                
                try faceDetectionHandler?.perform([request], on: pixelBuffer)
            } catch {
                print("error performing face detection")
            }
        }
    }
}

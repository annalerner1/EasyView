//
//  ContentView.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/26/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var recorder = Recorder()
    @StateObject private var motionManager = MotionManager()
    @ObservedObject private var audioStreamObserver = AudioStreamObserver()
    
    private var audioStreamManager = AudioStreamManager()
    
    @State private var warnings: [String : String] = [:]
    
    init() {
        audioStreamManager.resultObservation(with: audioStreamObserver)
    }
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    ZStack {
                        PreviewView(session: $recorder.session)
                            .clipped()
                            .cornerRadius(10)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if !recorder.isRecording {
                                    Button {
                                        recorder.switchCamera()
                                    } label: {
                                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                                            .resizable()
                                            .frame(width: 30, height: 25)
                                            .padding()
                                    }
                                }
                            }
                        }
                    }
                }
                HStack {
                    if !recorder.isRecording {
                        Button {
                            recorder.startRecording()
                            audioStreamManager.installTap()
                        } label: {
                            Image(systemName: "record.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.blue)
                                
                        }
                    } else {
                        Button {
                            recorder.stopRecording()
                            audioStreamManager.removeTap()
                        } label: {
                            Image(systemName: "stop.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    
                }
        
            }
            .padding()
            if recorder.isRecording {
                WarningView(warnings: .constant(Array(warnings.values)))
            }
        }
        
        .onChange(of: recorder.faceNotInFrame) { faceNotInFrame in
            if faceNotInFrame {
                updateWarning(warning: "Face not in frame", type: "FaceDetection")
            } else {
                updateWarning(warning: "", type: "FaceDetection")
            }
                }
        .onChange(of: motionManager.warning) { warning in
            if warning {
                updateWarning(warning: "Shaky video quality", type: "Motion")
            } else {
                updateWarning(warning: "", type: "Motion")
                
            }
        }
        .onChange(of: audioStreamObserver.warning) { warning in
            updateWarning(warning: warning, type: "Audio")
        }
        .onChange(of: motionManager.direWarning) { direWarning in
            if direWarning {
                print("dire motion warning")
                WarningSounds.playSound(file: "Motionwarning2.m4a")
            }
        }
        .onChange(of: audioStreamObserver.direWarning) { direWarning in
            if direWarning {
                if recorder.isRecording {
                    print("dire sounds warning")
                    WarningSounds.playSound(file: "Soundwarning2.m4a")
                }
            }
        }
         
    }
    private func updateWarning(warning: String, type: String) {
        if warning.isEmpty {
            warnings.removeValue(forKey: type)
        } else {
            warnings[type] = warning
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

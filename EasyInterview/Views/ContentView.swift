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
    
    @State private var warnings: [String] = []
    
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
                        if !recorder.isRecording {
                            Button {
                                recorder.switchCamera()
                            } label: {
                                Text("testing testing")
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
                if recorder.isRecording {
                                    Text("Classified Sound: \(audioStreamObserver.currentSound)")
                                        .padding()
                        }
            }
            .padding()
            if recorder.isRecording {
                WarningView(warnings: $warnings)
            }
        }
        
        .onChange(of: recorder.faceNotInFrame) { faceNotInFrame in
                    if faceNotInFrame {
                        warnings.append("Face not detected")
                    } else {
                        warnings.removeAll(where: { $0 == "Face not detected" })
                    }
                }
        .onChange(of: motionManager.warning) { warning in
            if warning {
                warnings.append("Shaky video quality")
            } else {
                warnings.removeAll(where: {$0 == "Shaky video quality"})
                
            }
        }
        .onChange(of: audioStreamObserver.warning) { warning in
            if warning.isEmpty {
                warnings.removeAll(where: {$0 == "Bad audio quality"}) // need to add specific wanring for 
            } else {
                warnings.append("Bad audio quality")
            }
        }
         
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

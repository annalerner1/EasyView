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
    @State private var warnings: [String] = []
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    PreviewView(session: $recorder.session)
                        .clipped()
                        .cornerRadius(10)
                }
                HStack {
                    if !recorder.isRecording {
                        Button {
                            recorder.startRecording()
                        } label: {
                            Image(systemName: "record.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.blue)
                                
                        }
                    } else {
                        Button {
                            recorder.stopRecording()
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
         
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

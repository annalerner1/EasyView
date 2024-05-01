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
    
    var body: some View {
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
                        Text("Start Recording")
                    }
                } else {
                    Button {
                        recorder.stopRecording()
                    } label: {
                        Text("Stop Recording")
                    }
                }
                

            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

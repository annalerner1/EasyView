//
//  PreviewView.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/30/24.
//

import SwiftUI
import AVFoundation


struct PreviewView: UIViewRepresentable {
    @Binding var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
      }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // maybe change something if user is record?
    }
}


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
        print("preview view created")
        
        
        return view
      }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
              layer.session = session
            layer.videoGravity = .resizeAspectFill
              layer.frame = uiView.bounds
          }
        print("preview view updated")
        // maybe change something if user is record?
    }
}


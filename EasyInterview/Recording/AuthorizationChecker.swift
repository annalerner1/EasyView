//
//  AuthorizationChecker.swift
//  EasyInterview
//
//  Created by Anna Lerner on 4/29/24.
//

import Foundation
import AVFoundation

struct AuthorizationChecker {
    
    func checkAuthStatus() async -> Bool {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        var vidAuth = videoStatus == .authorized
        var audAuth = audioStatus == .authorized
        
        if videoStatus == .notDetermined {
            vidAuth = await AVCaptureDevice.requestAccess(for: .video)
        } else if videoStatus == .denied {
            print("user needs to go to settings")
        }
            
        if audioStatus == .notDetermined {
            audAuth = await AVCaptureDevice.requestAccess(for: .audio)
        } else if audioStatus == .denied {
            print("user needs to go to settings")
        }
        
            
            return vidAuth && audAuth
        }
    
}

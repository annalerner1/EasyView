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
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio) // not sure if i need to include audio too? will test later
        var vidAuth = videoStatus == .authorized
        var audAuth = audioStatus == .authorized
        
        if videoStatus == .notDetermined {
            vidAuth = await AVCaptureDevice.requestAccess(for: .video)
        } else if videoStatus == .denied {
            // need to alert user to go to settings
        }
            
        if audioStatus == .notDetermined {
            audAuth = await AVCaptureDevice.requestAccess(for: .audio)
        } else if audioStatus == .denied {
            // need to alert user to go to settings
        }
        
            
            return vidAuth && audAuth
        }
    
}

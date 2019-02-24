//
//  CameraPage.swift
//  CustomVision
//
//  Created by henrylai on 24/2/19.
//  Copyright © 2019 Adam Behringer. All rights reserved.
//

import AVFoundation
import UIKit
import Photos

class CameraPage : UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        <#code#>
    }
    
    
    @IBOutlet var Screen: UIView!
    
    @IBAction func linkGallery(_ sender: Any) {
    }
    @IBAction func PhotoBtn(_ sender: Any) {
    }
    override func viewDidLoad() {
        
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() { }
        func configureCaptureDevices() throws { }
        func configureDeviceInputs() throws { }
        func configurePhotoOutput() throws { }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        
    }
    
    var captureSession: AVCaptureSession?
    self.captureSession = AVCaptureSession()
    var rearCamera: AVCaptureDevice?
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
    lazy var cameras = session.devices
    if cameras.isEmpty {
    
        throw CameraControllerError.noCamerasAvailable
    
    }
    //2
    for camera in cameras {
    if camera.position == .front {
    self.frontCamera = camera
    }
    
    if camera.position == .back {
    self.rearCamera = camera
    
    try camera.lockForConfiguration()
    camera.focusMode = .continuousAutoFocus
    camera.unlockForConfiguration()
    }
    }
    
}

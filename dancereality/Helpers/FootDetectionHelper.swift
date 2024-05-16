//
//  FootDetectionHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 24.07.23.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import AVKit
import Lottie
import Vision
import CoreMotion
import CoreML

class FootDetectiondHelper {
    private var timer: Timer?
    private var footstepsFrameData: [[Double]] = []
    private let sceneView: ARSCNView?
    
    init(timer: Timer? = nil, footstepsFrameData: [[Double]], sceneView: ARSCNView) {
        self.timer = timer
        self.footstepsFrameData = footstepsFrameData
        self.sceneView = sceneView
    }
    
    public func startStepDetection(){
        
    }
    
    private func captureScreenshot(image: @escaping(UIImage)->()){
        DispatchQueue.main.async {
            UIGraphicsBeginImageContext(self.sceneView!.frame.size)
            self.sceneView!.drawHierarchy(in: self.sceneView!.bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let screenshotFinal = screenshot {
                image(screenshotFinal)
            }
        }
    }
    
    private func pixelBuffer(from image: UIImage, width: Int, height: Int) -> CVPixelBuffer? {
        let attributes: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return unwrappedPixelBuffer
    }
}

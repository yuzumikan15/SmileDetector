//
//  ViewController.swift
//  SmileDetector
//
//  Created by Yuki Ishii on 2015/07/19.
//  Copyright (c) 2015年 Yuki Ishii. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	
	// for animation (SpriteKit)
	lazy var skView = SKView()
	lazy var smileView = SmileView(size: CGSizeMake(0, 0))
	
	// for face detection (CIFaceFeature)
	lazy var session = AVCaptureSession()
//	lazy var device = AVCaptureDevice()
	lazy var output = AVCaptureVideoDataOutput()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		setupSKView()
		setupSmileView()
		
		if initCamera() {
			session.startRunning()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setupSKView () {
		skView = SKView(frame: self.view.frame)
		self.view.addSubview(skView)
		skView.multipleTouchEnabled = false
	}
	
	func setupSmileView () {
		let size = skView.bounds.size
		smileView = SmileView(size: size)
		smileView.scaleMode = SKSceneScaleMode.AspectFill
		skView.presentScene(smileView)
	}
	
	func initCamera () -> Bool {
		session.sessionPreset = AVCaptureSessionPresetMedium
		if let device = initDevice(),
			input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as? AVCaptureDeviceInput {
				
				// set session input
				if !session.canAddInput(input) {
					return false
				}
				session.addInput(input)
					
				output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
				
				// set FPS
				if !setupFPS(device) {
					return false
				}
				
				// set delegate
				let queue : dispatch_queue_t = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL)
				output.setSampleBufferDelegate(self, queue: queue)
				output.alwaysDiscardsLateVideoFrames = true
				
				// set session output
				if !session.canAddOutput(output) {
					return false
				}
				session.addOutput(output)
				
				// set camera orientation
				setupCameraOrientation()
				
				return true
		}
		else {
			return false
		}
		
	}
	
	func initDevice () -> AVCaptureDevice? {
		let devices = AVCaptureDevice.devices()
		for d in devices {
			if d.position == AVCaptureDevicePosition.Front {
				return d as? AVCaptureDevice
			}
		}
		return nil
	}
	
	func setupFPS (device : AVCaptureDevice) -> Bool {
		var lockError : NSError?
		if device.lockForConfiguration(&lockError) {
			if let error = lockError {
				return false
			}
			device.activeVideoMinFrameDuration = CMTimeMake(1, 15)
			device.unlockForConfiguration()
			return true
		}
		else {
			return false
		}
	}
	
	func setupCameraOrientation () {
		for c in output.connections {
			if let connection = c as? AVCaptureConnection {
				if connection.supportsVideoOrientation {
					connection.videoOrientation = AVCaptureVideoOrientation.Portrait
				}
			}
		}
	}
	
	func detectFace (srcImage : CIImage) {
		let options = [CIDetectorEyeBlink:true, CIDetectorSmile:true]
		let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
		let features = detector.featuresInImage(srcImage, options: options)
		
		for f in features {
			if let feature = f as? CIFaceFeature {
				if feature.hasMouthPosition {
					if isSmile(feature) {
						println("good smile!")
						smileView.showSmile()
						NSThread.sleepForTimeInterval(1.5)
						smileView.showYokokumesi()
						NSThread.sleepForTimeInterval(2.0)
						smileView.showMesi()
					}
				}
			}
		}
	}
	
	func isSmile (feature : CIFaceFeature) -> Bool {
		return feature.hasSmile
	}
	
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		let srcImage = imageFromSampleBuffer(sampleBuffer)
		detectFace(srcImage)
	}
	
	func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> CIImage {
		let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
		
		CVPixelBufferLockBaseAddress(imageBuffer, 0)
		
		let baseAddress : UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
		
		let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
		let width = CVPixelBufferGetWidth(imageBuffer)
		let height = CVPixelBufferGetHeight(imageBuffer)
		
		let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
		
		let bitsPerCompornent = 8
		let bitmapInfo = CGBitmapInfo((CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)
		let newContext: CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo) as CGContextRef
		
		let imageRef : CGImageRef = CGBitmapContextCreateImage(newContext)
		
		var resultImage = CIImage(CGImage : imageRef)
		
		return resultImage
	}

}

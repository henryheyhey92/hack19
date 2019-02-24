import UIKit
import AVFoundation
import Vision

private let reuseIdentifier = "Cell"

// controlling the pace of the machine vision analysis
var lastAnalysis: TimeInterval = 0
var pace: TimeInterval = 0.33 // in seconds, classification will not repeat faster than this value

// performance tracking
let trackPerformance = false // use "true" for performance logging
var frameCount = 0
let framesPerSample = 10
var startDate = NSDate.timeIntervalSinceReferenceDate
var captureSession: AVCaptureSession?
var captureSession2: AVCaptureSession?
var stillImageOutput: AVCaptureStillImageOutput?
var videoPreviewLayer: AVCaptureVideoPreviewLayer?
var currentCaptureDevice: AVCaptureDevice?


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
  let ixora = "This ixora flower"
  let frangpani = "This frangpani"
  var ans = String()
    var choice: Bool = false
    
  
    @IBAction func tap(_ sender: Any) {
       //var image = String()
       //takeSnapshotOfView(view: previewView)
       //saveImage(imageName: image)
        takeScreenshot()
    }
    
    open func takeScreenshot(_ shouldSave: Bool = true) {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        let context = UIGraphicsGetCurrentContext() 
        layer.render(in:context!)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        UIImageWriteToSavedPhotosAlbum(screenshotImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        //saveImage(imageName: "test", resultBuffer: resultBuffer!)

        //return screenshotImage
    }
    
//    func takeSnapshotOfView(view:UIView) {
//        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
//        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        //get the PNG data for this image
//        //saveImage(imageName: "Test", resultBuffer: resultBuffer!)
//        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//        saveImage(imageName: "test", resultBuffer: resultBuffer!)
//
//    }
//
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
//    func saveImage(imageName: String, resultBuffer: CVImageBuffer){
//        //create an instance of the FileManager
//        let fileManager = FileManager.default
//        //get the image path
//        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
//        //get the image we took with camera
//        let image = imageBufferToUIImage(resultBuffer)
//        //get the PNG data for this image
//        let data = UIImagePNGRepresentation(image)
//        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
//    }
    
    
    
    
    @IBAction func pushbtn(_ sender: Any) {
        choice = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (ans == "Vanda Miss Joaquim" && choice == false){
            let ans2 = ans.components(separatedBy: " ")
            ans = ans2[0]
        }
        if choice == false {
        let controller = storyboard.instantiateViewController(withIdentifier: ans)
        self.present(controller, animated: true, completion: nil)
        }
        
    }
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var lowerView: UIView!
  var imagePickerController : UIImagePickerController!
//    @IBAction func captureBtn(_ sender: Any) {
//        self.captureSession.stopRunning()
//        self.captureSession2.startRunning()
//        choice = true
//        ///let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
//        imagePickerController.sourceType = .camera
//        present(imagePickerController, animated: true, completion: nil)
//
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.captureSession2.stopRunning()
        beginSession()
        //imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
        self.captureSession2.stopRunning()
        beginSession()
        
    }

    var previewLayer: AVCaptureVideoPreviewLayer!
  let bubbleLayer = BubbleLayer(string: "")
  
  let queue = DispatchQueue(label: "videoQueue")
  var captureSession = AVCaptureSession()
  var captureSession2 = AVCaptureSession()
  var captureDevice: AVCaptureDevice?
  let videoOutput = AVCaptureVideoDataOutput()
  var unknownCounter = 0 // used to track how many unclassified images in a row
  let confidence: Float = 0.7
  // Camera feature
   
    
    
  // MARK: Load the Model
  let targetImageSize = CGSize(width: 227, height: 227) // must match model data input
  
  lazy var classificationRequest: [VNRequest] = {
    do {
      // Load the Custom Vision model.
      // To add a new model, drag it to the Xcode project browser making sure that the "Target Membership" is checked.
      // Then update the following line with the name of your new model.
      let model = try VNCoreMLModel(for: flowerSec().model)
      let classificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
      return [ classificationRequest ]
    } catch {
      fatalError("Can't load Vision ML model: \(error)")
    }
  }()
  
  // MARK: Handle image classification results
  
  func handleClassification(request: VNRequest, error: Error?) {
    guard let observations = request.results as? [VNClassificationObservation]
      else { fatalError("unexpected result type from VNCoreMLRequest") }
    
    guard let best = observations.first else {
      fatalError("classification didn't return any results")
    }
    // Prepare for segue
//    func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        let dest : ViewTwo = segue.destination as! ViewTwo
//        print("it did get in")
//        if(ans == ixora) {
//        dest.Labeltext = ixora
//        }else{
//            dest.Labeltext = frangpani
//        }
//    }
    // Use results to update user interface (includes basic filtering)
    print("\(best.identifier): \(best.confidence)")
    if best.identifier.starts(with: "Unknown") || best.confidence < confidence {
      if self.unknownCounter < 3 { // a bit of a low-pass filter to avoid flickering
        self.unknownCounter += 1
      } else {
        self.unknownCounter = 0
        DispatchQueue.main.async {
          self.bubbleLayer.string = nil
        }
      }
    } else {
      self.unknownCounter = 0
      DispatchQueue.main.async {
        // Trimming labels because they sometimes have unexpected line endings which show up in the GUI
        self.bubbleLayer.string = best.identifier.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        if(self.ans == "Ixora"){
//            self.LabelOne.text = "This ixora flower"
//        }else if (self.ans == "Frangipani"){
//            self.LabelOne.text = "This frangpani"
//        }else{
//            self.LabelOne.text = " "
//        }
        print("This is ", self.ans)
        self.ans =  self.bubbleLayer.string!
        
        //prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?)
      }
    }
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewView.layer.addSublayer(previewLayer)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    bubbleLayer.opacity = 0.0
    bubbleLayer.position.x = self.view.frame.width / 2.0
    bubbleLayer.position.y = lowerView.frame.height / 2
    lowerView.layer.addSublayer(bubbleLayer)
    
    setupCamera()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer.frame = previewView.bounds;
  }
  
  // MARK: Camera handling
  
  func setupCamera() {
    let deviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    
    if let device = deviceDiscovery.devices.last {
      captureDevice = device
      beginSession()
    }
  }
  
  func beginSession() {
    do {
      videoOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : (NSNumber(value: kCVPixelFormatType_32BGRA) as! UInt32)]
      videoOutput.alwaysDiscardsLateVideoFrames = true
      videoOutput.setSampleBufferDelegate(self, queue: queue)
      
      captureSession.sessionPreset = .hd1920x1080
      captureSession.addOutput(videoOutput)
      
      let input = try AVCaptureDeviceInput(device: captureDevice!)
      captureSession.addInput(input)
      
      captureSession.startRunning()
    } catch {
      print("error connecting to capture device")
    }
  }
}

// MARK: Video Data Delegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  // called for each frame of video
  func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    let currentDate = NSDate.timeIntervalSinceReferenceDate
    
    // control the pace of the machine vision to protect battery life
    if currentDate - lastAnalysis >= pace {
      lastAnalysis = currentDate
    } else {
      return // don't run the classifier more often than we need
    }
    
    // keep track of performance and log the frame rate
    if trackPerformance {
      frameCount = frameCount + 1
      if frameCount % framesPerSample == 0 {
        let diff = currentDate - startDate
        if (diff > 0) {
          if pace > 0.0 {
            print("WARNING: Frame rate of image classification is being limited by \"pace\" setting. Set to 0.0 for fastest possible rate.")
          }
          print("\(String.localizedStringWithFormat("%0.2f", (diff/Double(framesPerSample))))s per frame (average)")
        }
        startDate = currentDate
      }
    }
    
    // Crop and resize the image data.
    // Note, this uses a Core Image pipeline that could be appended with other pre-processing.
    // If we don't want to do anything custom, we can remove this step and let the Vision framework handle
    // crop and resize as long as we are careful to pass the orientation properly.
    guard let croppedBuffer = croppedSampleBuffer(sampleBuffer, targetSize: targetImageSize) else {
      return
    }
    
    do {
      let classifierRequestHandler = VNImageRequestHandler(cvPixelBuffer: croppedBuffer, options: [:])
      try classifierRequestHandler.perform(classificationRequest)
    } catch {
      print(error)
    }
  }
}

let context = CIContext()
var rotateTransform: CGAffineTransform?
var scaleTransform: CGAffineTransform?
var cropTransform: CGAffineTransform?
var resultBuffer: CVPixelBuffer?

func croppedSampleBuffer(_ sampleBuffer: CMSampleBuffer, targetSize: CGSize) -> CVPixelBuffer? {
  
  guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
    fatalError("Can't convert to CVImageBuffer.")
  }
  
  // Only doing these calculations once for efficiency.
  // If the incoming images could change orientation or size during a session, this would need to be reset when that happens.
  if rotateTransform == nil {
    let imageSize = CVImageBufferGetEncodedSize(imageBuffer)
    let rotatedSize = CGSize(width: imageSize.height, height: imageSize.width)
    
    guard targetSize.width < rotatedSize.width, targetSize.height < rotatedSize.height else {
      fatalError("Captured image is smaller than image size for model.")
    }
    
    let shorterSize = (rotatedSize.width < rotatedSize.height) ? rotatedSize.width : rotatedSize.height
    rotateTransform = CGAffineTransform(translationX: imageSize.width / 2.0, y: imageSize.height / 2.0).rotated(by: -CGFloat.pi / 2.0).translatedBy(x: -imageSize.height / 2.0, y: -imageSize.width / 2.0)
    
    let scale = targetSize.width / shorterSize
    scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
    
    // Crop input image to output size
    let xDiff = rotatedSize.width * scale - targetSize.width
    let yDiff = rotatedSize.height * scale - targetSize.height
    cropTransform = CGAffineTransform(translationX: xDiff/2.0, y: yDiff/2.0)
  }
  
  // Convert to CIImage because it is easier to manipulate
  let ciImage = CIImage(cvImageBuffer: imageBuffer)
  let rotated = ciImage.transformed(by: rotateTransform!)
  let scaled = rotated.transformed(by: scaleTransform!)
  let cropped = scaled.transformed(by: cropTransform!)
  
  // Note that the above pipeline could be easily appended with other image manipulations.
  // For example, to change the image contrast. It would be most efficient to handle all of
  // the image manipulation in a single Core Image pipeline because it can be hardware optimized.
  
  // Only need to create this buffer one time and then we can reuse it for every frame
  if resultBuffer == nil {
    let result = CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32BGRA, nil, &resultBuffer)
    
    guard result == kCVReturnSuccess else {
      fatalError("Can't allocate pixel buffer.")
    }
  }
  
  // Render the Core Image pipeline to the buffer
  context.render(cropped, to: resultBuffer!)
  
  //  For debugging
  //  let image = imageBufferToUIImage(resultBuffer!)
  //  print(image.size) // set breakpoint to see image being provided to CoreML
  
  return resultBuffer
}

// Only used for debugging.
// Turns an image buffer into a UIImage that is easier to display in the UI or debugger.
func imageBufferToUIImage(_ imageBuffer: CVImageBuffer) -> UIImage {
  
  CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
  
  let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
  let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
  
  let width = CVPixelBufferGetWidth(imageBuffer)
  let height = CVPixelBufferGetHeight(imageBuffer)
  
  let colorSpace = CGColorSpaceCreateDeviceRGB()
  let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
  
  let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
  
  let quartzImage = context!.makeImage()
  CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
  
  let image = UIImage(cgImage: quartzImage!, scale: 1.0, orientation: .right)
  
  return image
}

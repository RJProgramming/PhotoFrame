//
//  ViewController.swift
//  Lil Memer
//
//  Created by Robert Perez on 1/6/17.
//  Copyright © 2017 Robert Perez. All rights reserved.
//

import UIKit
import StoreKit
import Metal

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sciFrame: UIImageView!
    @IBOutlet weak var youtubeFrame: UIImageView!
    @IBOutlet weak var youtubeTitle: UITextField!
    @IBOutlet weak var youtubeLabel: NSLayoutConstraint!
    @IBOutlet weak var saveNav: UIBarButtonItem!
    @IBOutlet weak var shareNav: UIBarButtonItem!
    @IBOutlet weak var frameButtonBot: NSLayoutConstraint!
    @IBOutlet weak var filterButtonBot: NSLayoutConstraint!
    @IBOutlet weak var youtubeFrameWidth: NSLayoutConstraint!
    @IBOutlet weak var frameButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var chooseImageLabel: UILabel!
    
    @IBOutlet weak var frameButtonTitle: UILabel!
    @IBOutlet weak var filterButtonTitle: UILabel!
    let screenSize: CGRect = UIScreen.main.bounds
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var xCord:CGFloat = 0.0
    var yCord:CGFloat = 0.0
    var limitLength = 39
    var number: CGFloat = 0
    var currentFrame: Int = 1
    var imageView = UIImageView()
    var image: UIImage!
    var origImage: UIImage!
    var font: UIFont?
    var movementValue: CGFloat = 175
    var canSetFilterCenter:Bool = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Share Frame"
        
        frameButtonBot.constant = -200
        filterButtonBot.constant = -200
        shareNav.isEnabled = false
        
        filterButton.layer.cornerRadius = 10
        frameButton.layer.cornerRadius = 10
        filterButton.clipsToBounds = true
        frameButton.clipsToBounds = true
        
        //sets the delegate for the textfield
        youtubeTitle.delegate = self
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        scrollView.delegate = self
        
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        //tap to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        //tap to center a filter
        let imageTouch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapImage))
        imageView.addGestureRecognizer(imageTouch)
        imageTouch.cancelsTouchesInView = false
     
        //set the deletes for both gestures at same time
        tap.delegate = self
        imageTouch.delegate = self
    
       //these font sizes along with screen width and writing the string at size 15 seems to line everything up nicely.
        if screenWidth == Constants.iPhoneElseWidth{
            textView.font = UIFont(name: "Roboto-Regular", size: 13)
            textView.textContainerInset = UIEdgeInsets.init(top: 0.0, left: -5.0, bottom: 0.0, right: 0.0)
            limitLength = 200
            self.youtubeLabel.constant = -13
        }else if screenWidth == Constants.iPhone6Width{
            textView.font = UIFont(name: "Roboto-Regular", size: 15)
            textView.textContainerInset = UIEdgeInsets.init(top: 0.0, left: -5.0, bottom: 0.0, right: 0.0)
            limitLength = 200
            self.youtubeLabel.constant = -18
            if screenHeight == Constants.iPhoneXHeight{
                self.youtubeLabel.constant = -29
                youtubeFrame.image = UIImage(named: "youtubeframeiphonex")
            }
        }else if screenWidth >= Constants.iPhone6PlusWidth{
            textView.font = UIFont(name: "Roboto-Regular", size: 17)
            textView.textContainerInset = UIEdgeInsets.init(top: 0.0, left: -5.0, bottom: 0.0, right: 0.0)
            limitLength = 200
            self.youtubeLabel.constant = -20
        }
        // place holder text for textview
        textView.text = "Tap here to enter text"
        textView.textColor = UIColor.lightGray
        self.textView.delegate = self
        scrollView.isHidden = true
       
        
        
        
    }
    
    //added this to allow custom filter centers and tap keyboard to dismiss on imageview
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
    }
    
    func textFieldShouldReturn(_ youtubeTitle: UITextField) -> Bool
    {
        youtubeTitle.resignFirstResponder()
        return true
    }

    @objc func didTapImage(gesture: UIGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        print(point)
        xCord = point.x
        yCord = point.y
        print ("\(point) and x\(xCord) and \(yCord)")
        
        
    }
    
    //limits youtube textfield characters so it doesnt scroll
    // left this but made the limit huge essenitally removing it
    func textField(_ youtubeTitle: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = youtubeTitle.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }
    //allows view to move when keyboard comes out for textfield pt1
    func textFieldDidBeginEditing(_ youtubeTitle: UITextField) {
        animateViewMoving(up: true, moveValue: movementValue)
    }
    //allows view to move when keyboard comes out for textfield pt2
    func textFieldDidEndEditing(_ youtubeTitle: UITextField) {
        animateViewMoving(up: false, moveValue: movementValue)
    }
    //allows view to move when keyboard comes out for textfield pt3
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
    }
    
    struct Constants {
        static let iPhone6Width = CGFloat(375)
        static let iPhone6PlusWidth = CGFloat(414)
        static let iPhoneElseWidth = CGFloat(320)
        static let iPhone4Height = CGFloat(480)
        static let iPhoneXHeight = CGFloat(812)
        static let iPhoneXsRHeight = CGFloat(896)
        
    }
        
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //adds placeholder text for textview pt 1
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    //placeholder text for textview pt 2
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tap here to enter text"
            textView.textColor = UIColor.lightGray
        }
    }

    // part 1 of calcing string length to limit text view lines
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]),
                                                 context: nil).size
    }
    //part 2 of calcing string length to keep textview at certain number of lines
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
       // let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = textView.frame.inset(by: textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        if screenHeight == Constants.iPhoneXHeight || screenHeight == Constants.iPhoneXsRHeight {
           return numberOfLines <= 6
        }else{
           return numberOfLines <= 5
        }
    }

    //picker once user taps plus
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        
        xCord = image.size.width / 2
        yCord = image.size.height / 2
        
        //below fixes image orietnation when before filter is applied. If these arent here to set image orientation after filters are applied
        //some PNGs with rotate 90 degrees.
        origImage = image.fixedOrientation()
        image = image.fixedOrientation()
        
        scrollView.isHidden = false
        chooseImageLabel.isHidden = true
        imageView.image = image
        imageView.contentMode = UIView.ContentMode.center
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        
        scrollView.minimumZoomScale = minScale / 2
        scrollView.maximumZoomScale = 5
        scrollView.zoomScale = minScale
        
        //recenters image if selected after first image was choosen
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width * minScale, height: image.size.height  * minScale)
        scrollView.contentSize = CGSize(width: image.size.width * minScale, height: image.size.height * minScale)
        
        centerScrollViewContents()
        
        youtubeTitle.text = ""
        textView.text = ""
        textViewDidBeginEditing(textView)
        textViewDidEndEditing(textView)

        picker.dismiss(animated: true, completion:{
            
            self.shareNav.isEnabled = true
            let screenHeight = self.screenSize.height
            if screenHeight == Constants.iPhoneXHeight || screenHeight == Constants.iPhoneXsRHeight{
                
                self.view.layoutIfNeeded()
                
                self.filterButtonBot.constant = 5
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    
                    self.view.layoutIfNeeded()
                })
                self.frameButtonBot.constant = 5
                UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    
                    self.view.layoutIfNeeded()
                })
                
            }else{

                self.view.layoutIfNeeded()
                
                self.filterButtonBot.constant = 30
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
                
                self.frameButtonBot.constant = 30
                UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    
                    self.view.layoutIfNeeded()
                })
                
                
            }
            
        })
        
        //activates skreview controller after 5 launches of the app
        if #available(iOS 10.3, *) {
            let reviewCount = defaults.integer(forKey: "launchCount")
            if reviewCount == 2 {
                SKStoreReviewController.requestReview()
            }
        }
    }
   
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
    
        if contentsFrame.size.height < boundsSize.height{
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        imageView.frame = contentsFrame
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func filter(_ sender: Any) {
        
        guard (self.imageView.image?.cgImage) != nil else { return }
        
        let ac = UIAlertController(title: "Tap anywhere on the image to set new a filter center", message: nil, preferredStyle: .actionSheet)
        
        filterButtonTitle.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.filterButtonTitle.alpha = 0.5})
        
        self.filterButtonTitle.alpha = 1.0
        
        filterButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.filterButton.transform = CGAffineTransform.identity
           
        }, completion:{ finish in
            
            ac.addAction(UIAlertAction(title: "Bump", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Linear Bump", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Pinch", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Spiral", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Pixelate", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Black and White", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Motion Blur", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Deep Fry 👌", style: .default, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Remove Filters", style: .destructive, handler: self.setFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(ac, animated: true)})
    }

    func setFilter(action: UIAlertAction) {
        // make sure we have a valid image before continuing!
       
        guard let image = self.imageView.image?.cgImage else { return }
        
        var actionSheetFilter = "CIPixellate"
        var pinchCheck = 0
        
        if action.title == "Bump"{
            pinchCheck = 0
            actionSheetFilter = "CIBumpDistortion"
        }else if action.title == "Linear Bump"{
            actionSheetFilter = "CIBumpDistortionLinear"
        }else if action.title == "Spiral"{
            actionSheetFilter = "CITwirlDistortion"
        }else if action.title == "Pixelate"{
            actionSheetFilter = "CIPixellate"
        }else if action.title == "Pinch"{
            pinchCheck = 1
            actionSheetFilter = "CIBumpDistortion"
        }else if action.title == "Remove Filters"{
            actionSheetFilter = "Remove All"
        }else if action.title == "Black and White"{
            actionSheetFilter = "CIPhotoEffectMono"
        }else if action.title == "Motion Blur"{
            actionSheetFilter = "CIMotionBlur"
        }else if action.title == "Deep Fry 👌"{
            actionSheetFilter = "CITemperatureAndTint"
        }

        //changed .openGLES3 to S2 to accomodate ios 9
        //let openGLContext = EAGLContext(api: .openGLES3)
        //let context = CIContext(eaglContext: openGLContext!)
        //switched to metal for better performance
        let device: MTLDevice? = MTLCreateSystemDefaultDevice()
        let context = CIContext(mtlDevice: device!)
        let ciImage = CIImage(cgImage: image)

        //Had to do the below radiusValue because radiuskey wouldnt accept (image.height * image.width) / 4 for some reason
        var radiusValue = 1
        if image.height >= image.width{
            radiusValue = image.height
        }else{
            radiusValue = image.width
        }
        
        if actionSheetFilter == "Remove All"{
            imageView.image = origImage
            
        }else{
            
        let currentFilter = CIFilter(name: actionSheetFilter)
        currentFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        let inputKeys = currentFilter?.inputKeys
        
        if (inputKeys?.contains(kCIInputIntensityKey))! { currentFilter?.setValue(100, forKey: kCIInputIntensityKey) }
        if (inputKeys?.contains(kCIInputRadiusKey))! { currentFilter?.setValue((radiusValue / 4), forKey: kCIInputRadiusKey) }
        if ((inputKeys?.contains(kCIInputRadiusKey))! && actionSheetFilter == "CIBumpDistortion" ) { currentFilter?.setValue((radiusValue / 4), forKey: kCIInputRadiusKey) }
            
            if ((inputKeys?.contains(kCIInputRadiusKey))! && actionSheetFilter == "CIMotionBlur" ) { currentFilter?.setValue(radiusValue / 40, forKey: kCIInputRadiusKey) }
            
            
        if ((inputKeys?.contains(kCIInputScaleKey))! && actionSheetFilter == "CIBumpDistortion") { currentFilter?.setValue(0.50, forKey: kCIInputScaleKey) }
         if ((inputKeys?.contains(kCIInputScaleKey))! && actionSheetFilter == "CIBumpDistortion" && pinchCheck == 1) { currentFilter?.setValue(-0.50, forKey: kCIInputScaleKey) }
            
        if ((inputKeys?.contains(kCIInputScaleKey))! && actionSheetFilter == "CIBumpDistortionLinear") { currentFilter?.setValue(0.50, forKey: kCIInputScaleKey) }
        if ((inputKeys?.contains(kCIInputScaleKey))! && actionSheetFilter == "CIPixellate") { currentFilter?.setValue(radiusValue / 50, forKey: kCIInputScaleKey) }
            if (inputKeys?.contains(kCIInputCenterKey))! { currentFilter?.setValue(CIVector(x: xCord, y: CGFloat(image.height) - yCord), forKey: kCIInputCenterKey) }
            
            if (inputKeys?.contains(kCIInputAngleKey))! { currentFilter?.setValue(1.5, forKey: kCIInputAngleKey) }
            
        if ((inputKeys?.contains(kCIInputAngleKey))! && actionSheetFilter == "CIBumpDistortionLinear") { currentFilter?.setValue(0.0, forKey: kCIInputAngleKey) }
            
//            if ((inputKeys?.contains(kCIInputN))! && actionSheetFilter == "CITemperatureAndTint") {
//                currentFilter?.setValue(0.0, forKey: kCIInputTargetImageKey)
//
//            }
        
      if let output = currentFilter?.value(forKey: kCIOutputImageKey) as? CIImage{
        
        let outputImage = UIImage(cgImage: context.createCGImage(output, from: output.extent)!)
        
        self.imageView.image = outputImage
            }
        }
    }

    @IBAction func navSave(_ sender: UIBarButtonItem) {
        
        guard image != nil else { return }
        let offset = scrollView.contentOffset
        let screenHeight = screenSize.height

        //added -2 to get rid of a  1 pixel high black line only appeared with zoomed out images + textview and zoomed in portrait images
        let normalSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height - 2)
        
        let textViewWithImageSize = CGSize(width: scrollView.bounds.size.width, height: ((screenHeight * 0.17) + scrollView.bounds.size.height - 2))
        let youtubeFrameImageSize = CGSize(width: scrollView.bounds.size.width, height: ((screenHeight * 0.15) + scrollView.bounds.size.height - 36))
        var yPos: Int = Int(-offset.y)
        
        //if textView is active or not and the different y position for saved image to include the textview if it is active
        // screenHeight * 0.17 is the dynamic height of the textview per device.
        
        if textView.isHidden == true {
            UIGraphicsBeginImageContextWithOptions(normalSize, true, UIScreen.main.scale)
            textView.text = ""
            
            // -2 here along with the var normalSize gets rid of the thin black/grey line that appears on top of images sometimes. I think.
            yPos = Int(-offset.y - 2)
            
            
        }else if textView.isHidden == false {
            yPos = Int(-offset.y + (screenHeight * 0.17))
            UIGraphicsBeginImageContextWithOptions(textViewWithImageSize, true, UIScreen.main.scale)
            
            //sets saves text area background to white, extendind the image area on its own colored the void black.
            let backgroundColor: UIColor = UIColor.white
            backgroundColor.setFill()
            
            UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: (0 - (screenHeight * 0.17)), width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
            
        }
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: CGFloat(yPos))
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        if sciFrame.isHidden == false{
            
            //the offsets put the frame right over the image regardless off how the image is zoomed
            UIGraphicsGetCurrentContext()!.translateBy(x: offset.x, y: offset.y)
            sciFrame.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        let textColor = UIColor.black
        let screenWidth = screenSize.width
        var textFont = UIFont(name: "Roboto-Regular", size: 15)
        // I thoght I neede different sized string fonts to make the saved image line up correctly. it seems i dont but im going
        // to leave it there just in case i find another bug with it.
        if screenWidth == Constants.iPhoneElseWidth{
            textFont = UIFont(name: "Roboto-Regular", size: 13)
        }else if screenWidth == Constants.iPhone6Width{
            textFont = UIFont(name: "Roboto-Regular", size: 15)
        }else if screenWidth >= Constants.iPhone6PlusWidth{
            textFont = UIFont(name: "Roboto-Regular", size: 17)
        }
        
        //let textFont = UIFont(name: "Courier", size: 15)!
        let textFontAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): textFont!,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor] as [String : Any]
        
        //-10 to .width to line up the drawn text to the actual typed textview
        let rect = CGRect(x: offset.x, y: (offset.y + 5 - (screenHeight * 0.17)), width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        
        textView.text.draw(in: rect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(textFontAttributes))
        
        if youtubeFrame.isHidden == false{
            
            //using graphics context extended for youtube frame
            UIGraphicsBeginImageContextWithOptions(youtubeFrameImageSize, true, UIScreen.main.scale)
            
            UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
            scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            //   number allows different screen sizes to export youtube frame properly
            if screenWidth == Constants.iPhoneElseWidth{
                number = 2.45
            }else if screenWidth == Constants.iPhone6Width{
                number = 2.54
                if screenHeight == Constants.iPhoneXHeight{
                    number = 2.6
                }
            }else if screenWidth >= Constants.iPhone6PlusWidth{
                number = 2.6
            }

            //adds correct font on youtube title output
            let myAttribute = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "Roboto", size: 12.0)!]
            UIGraphicsGetCurrentContext()!.translateBy(x: offset.x, y: offset.y + ((screenHeight * 0.16) * number))
            youtubeFrame.layer.render(in: UIGraphicsGetCurrentContext()!)
            youtubeTitle.font = UIFont(name: "Roboto-Regular", size: 12)
            let labelRect = CGRect(x: 5, y: (self.youtubeLabel.constant * -1), width: youtubeFrame.bounds.size.width, height: youtubeFrame.bounds.size.height)
            youtubeTitle.text?.draw(in: labelRect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(myAttribute))
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if  image != nil {
            //brings out the share menu
            let vc = UIActivityViewController(activityItems: [image as Any], applicationActivities: [])
            present(vc, animated: true)
        }
    }

    @IBAction func navChooseImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func frame(_ sender: Any) {
        guard image != nil else { return }
        
        frameButtonTitle.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.frameButtonTitle.alpha = 0.5})
        
        frameButtonTitle.alpha = 1.0
        
        frameButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {self.frameButton.transform = CGAffineTransform.identity}, completion: nil)

        switch currentFrame{
        case 0:
            //no textView
            textView.isHidden = true
            sciFrame.isHidden = true
            youtubeFrame.isHidden = true
            youtubeTitle.isHidden = true
        case 1:
            //textView
            textViewDidBeginEditing(textView)
            textViewDidEndEditing(textView)
            textView.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.textView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.textView.alpha = 0.0
            })
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.textView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.textView.alpha = 1.0
            })
        case 2:
            
            textView.text = ""
            textView.isHidden = true
            sciFrame.isHidden = true
            youtubeFrame.isHidden = false
            youtubeTitle.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.youtubeFrame.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.youtubeTitle.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.youtubeFrame.alpha = 0.0
                self.youtubeTitle.alpha = 0.0
            })
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.youtubeFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.youtubeTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.youtubeFrame.alpha = 1.0
                self.youtubeTitle.alpha = 1.0
            })
            
            
        case 3:
            
            youtubeTitle.text = ""
            youtubeFrame.isHidden = true
            youtubeTitle.isHidden = true
            textView.isHidden = true
            sciFrame.isHidden = false
            sciFrame.image = UIImage(named: "LionFrameNew")
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.sciFrame.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.sciFrame.alpha = 0.0
            })
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.sciFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.sciFrame.alpha = 1.0
            })
        case 4:
            
            //sciFrame
            sciFrame.image = UIImage(named: "sciFrameSmaller")
            textView.isHidden = true
            sciFrame.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.sciFrame.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.sciFrame.alpha = 0.0
            })
            UIView.animate(withDuration: 0.4, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
                self.sciFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.sciFrame.alpha = 1.0
            })
           
          default:
            break
        }
        currentFrame += 1
        if currentFrame > 4 {
            currentFrame = 0
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

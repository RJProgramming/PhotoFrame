//
//  ViewController.swift
//  Lil Memer
//
//  Created by Robert Perez on 1/6/17.
//  Copyright © 2017 Robert Perez. All rights reserved.
//

import UIKit
//import CoreImage

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var noImageHolder: UIImageView!
    @IBOutlet weak var sciFrame: UIImageView!
    @IBOutlet weak var youtubeFrame: UIImageView!
    @IBOutlet weak var youtubeTitle: UITextField!
    @IBOutlet weak var youtubeLabel: NSLayoutConstraint!
    
    @IBOutlet weak var youtubeFrameWidth: NSLayoutConstraint!
    @IBOutlet weak var frameButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var xCord:CGFloat = 0.0
    var yCord:CGFloat = 0.0
    var limitLength = 39
    var number: CGFloat = 0
    var currentFrame: Int = 1
    var imageView = UIImageView()
    var image: UIImage!
    var origImage: UIImage!
    var font: UIFont?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textView.delegate = self
        //sets the delegate for the textfield
        youtubeTitle.delegate = self
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        scrollView.delegate = self
        
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let imageTouch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapImage))
        imageView.addGestureRecognizer(imageTouch)
     
    
       //these font sizes along with screen width and writing the string at size 15 seems to line everything up nicely.
        if screenWidth == Constants.iPhoneElseWidth{
            textView.font = UIFont(name: "Courier", size: 15)
            textView.textContainerInset = UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)
            limitLength = 32
            self.youtubeLabel.constant = -25
            if screenHeight == Constants.iPhone4Height{
                self.youtubeFrameWidth.constant = 12
                self.youtubeLabel.constant = -22
        }
            
        }else if screenWidth == Constants.iPhone6Width{
            textView.font = UIFont(name: "Courier", size: 17)
            textView.textContainerInset = UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)
            limitLength = 36
            self.youtubeLabel.constant = -30
        }else if screenWidth >= Constants.iPhone6PlusWidth{
            textView.font = UIFont(name: "Courier", size: 19)
            textView.textContainerInset = UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)
            limitLength = 40
            self.youtubeLabel.constant = -35
        }
        
        // place holder text for textview
        textView.text = "Tap here to enter text"
        textView.textColor = UIColor.lightGray
        
        self.textView.delegate = self
        scrollView.isHidden = true
        
        

    }
    
    func didTapImage(gesture: UIGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        print(point)
        
        xCord = point.x
        yCord = point.y
        
        print ("\(point) and x\(xCord) and \(yCord)")
    }
    
    //limits youtube textfield characters so it doesnt scroll
    func textField(_ youtubeTitle: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = youtubeTitle.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    //allows view to move when keyboard comes out for textfield pt1
    func textFieldDidBeginEditing(_ youtubeTitle: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    //allows view to move when keyboard comes out for textfield pt2
    func textFieldDidEndEditing(_ youtubeTitle: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
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
        
    }
        
    func dismissKeyboard() {
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
            //textView.font = UIFont(name: "Courier", size: 15)
            textView.text = "Tap here to enter text"
            textView.textColor = UIColor.lightGray
        }
    }

    // part 1 of calcing string length to limit text view lines
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName: font],
                                                 context: nil).size
    }
    //part 2 of calcing string length to keep textview at certain number of lines
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let screenWidth = screenSize.width
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        
        if screenWidth == Constants.iPhone6Width || screenWidth == Constants.iPhone6PlusWidth {
           return numberOfLines <= 6
        }else{
           return numberOfLines <= 5
        }
        
        
    }

    //picker once user taps imageview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
       origImage = image
        
        scrollView.isHidden = false
        noImageHolder.isHidden = true
        imageView.image = image
        imageView.contentMode = UIViewContentMode.center
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
        
        picker.dismiss(animated: true, completion: nil)
        
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

        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBumpDistortionLinear", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Remove All", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
     
    }
    
    func setFilter(action: UIAlertAction) {
        // make sure we have a valid image before continuing!
        //guard currentImage != nil else { return }
        
        
        guard let image = self.imageView.image?.cgImage else { return }
        
        
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        let ciImage = CIImage(cgImage: image)
        
        
        
        if action.title == "Remove All"{
            imageView.image = origImage
            
            
        }else{
            
        let currentFilter = CIFilter(name: action.title!)
        
        currentFilter?.setValue(ciImage, forKey: kCIInputImageKey)

        let inputKeys = currentFilter?.inputKeys
        
        if (inputKeys?.contains(kCIInputIntensityKey))! { currentFilter?.setValue(100, forKey: kCIInputIntensityKey) }
        if (inputKeys?.contains(kCIInputRadiusKey))! { currentFilter?.setValue((image.width / 4), forKey: kCIInputRadiusKey) }
        if ((inputKeys?.contains(kCIInputScaleKey))! && action.title == "CIBumpDistortion") { currentFilter?.setValue(0.70, forKey: kCIInputScaleKey) }
        if ((inputKeys?.contains(kCIInputScaleKey))! && action.title == "CIBumpDistortionLinear") { currentFilter?.setValue(2, forKey: kCIInputScaleKey) }
        if ((inputKeys?.contains(kCIInputScaleKey))! && action.title == "CIPixellate") { currentFilter?.setValue(20, forKey: kCIInputScaleKey) }
if (inputKeys?.contains(kCIInputCenterKey))! { currentFilter?.setValue(CIVector(x: xCord, y: CGFloat(image.height) - yCord), forKey: kCIInputCenterKey) }
            
            if (inputKeys?.contains(kCIInputAngleKey))! { currentFilter?.setValue(1.0, forKey: kCIInputAngleKey) }
        
        
      if let output = currentFilter?.value(forKey: kCIOutputImageKey) as? CIImage{
            self.imageView.image = UIImage(cgImage: context.createCGImage(output, from: output.extent)!)
            
             //centerScrollViewContents()
        }
        
        }
    }
    
    
   
    @IBAction func navSave(_ sender: UIBarButtonItem) {
        
        guard image != nil else { return }
        
        let offset = scrollView.contentOffset
        let screenHeight = screenSize.height
        
        
        //added -1 to get rid of a black line tht only appeared with zoomed out images and textview
        let normalSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        let textViewWithImageSize = CGSize(width: scrollView.bounds.size.width, height: ((screenHeight * 0.17) + scrollView.bounds.size.height - 1))
        let youtubeFrameImageSize = CGSize(width: scrollView.bounds.size.width, height: ((screenHeight * 0.15) + scrollView.bounds.size.height - 36))
        var yPos: Int = Int(-offset.y)
        
        //if textView is active or not and the different y position for saved image to include the textview if it is active
        // screenHeight * 0.17 is the dynamic height of the textview per device.
        
        if textView.isHidden == true {
            UIGraphicsBeginImageContextWithOptions(normalSize, true, UIScreen.main.scale)
            textView.text = ""
            yPos = Int(-offset.y)
            
            
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
        var textFont = UIFont(name: "Courier", size: 15)
        // I thoght I neede different sized string fonts to make the saved image line up correctly. it seems i dont but im going
        // to leave it there just in case i find another bug with it.
        if screenWidth == Constants.iPhoneElseWidth{
            textFont = UIFont(name: "Courier", size: 15)
        }else if screenWidth == Constants.iPhone6Width{
            textFont = UIFont(name: "Courier", size: 17)
        }else if screenWidth >= Constants.iPhone6PlusWidth{
            textFont = UIFont(name: "Courier", size: 19)
        }
        
        //let textFont = UIFont(name: "Courier", size: 15)!
        let textFontAttributes = [NSFontAttributeName: textFont!,NSForegroundColorAttributeName: textColor] as [String : Any]
        
        //-10 to .width to line up the drawn text to the actual typed textview
        let rect = CGRect(x: offset.x, y: (offset.y + 5 - (screenHeight * 0.17)), width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        
        textView.text.draw(in: rect, withAttributes: textFontAttributes)
        
        if youtubeFrame.isHidden == false{
            
            //using graphics context extended for youtube frame
            UIGraphicsBeginImageContextWithOptions(youtubeFrameImageSize, true, UIScreen.main.scale)
            
            UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
            scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            //   number allows different screen sizes to export youtube frame properly
            if screenWidth == Constants.iPhoneElseWidth{
                number = 2.26
                
                if screenHeight == Constants.iPhone4Height{
                    number = 2
                }
                
            }else if screenWidth == Constants.iPhone6Width{
                number = 2.33
            }else if screenWidth >= Constants.iPhone6PlusWidth{
                number = 2.35
            }
            
            
            //adds correct font on youtube title output
            let myAttribute = [ NSFontAttributeName: UIFont(name: "Roboto", size: 12.0)!]
            
            UIGraphicsGetCurrentContext()!.translateBy(x: offset.x, y: offset.y + ((screenHeight * 0.15) * number))
            youtubeFrame.layer.render(in: UIGraphicsGetCurrentContext()!)
            youtubeTitle.font = UIFont(name: "Roboto-Regular", size: 12)
            let labelRect = CGRect(x: 5, y: (self.youtubeLabel.constant * -1), width: youtubeFrame.bounds.size.width, height: youtubeFrame.bounds.size.height)
            youtubeTitle.text?.draw(in: labelRect, withAttributes: myAttribute)
            
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if  image != nil {
            //brings out the share menu
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            present(vc, animated: true)
            
        }

        
    }
    

    @IBAction func navChooseImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
  
    @IBAction func frame(_ sender: Any) {
        guard image != nil else { return }
        
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
            
        case 2:
            //sciFrame
            sciFrame.image = UIImage(named: "sciFrameSmaller")
            textView.isHidden = true
            sciFrame.isHidden = false
        case 3:
            sciFrame.image = UIImage(named: "fbFrame")
            
        case 4:
            textView.isHidden = true
            sciFrame.isHidden = true
            youtubeFrame.isHidden = false
            youtubeTitle.isHidden = false
          default:
            break
        }
        currentFrame += 1
        if currentFrame > 4 {
            currentFrame = 0
        }
}
    
   
    
    
}


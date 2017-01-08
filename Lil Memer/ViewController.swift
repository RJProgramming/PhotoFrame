//
//  ViewController.swift
//  Lil Memer
//
//  Created by Robert Perez on 1/6/17.
//  Copyright © 2017 Robert Perez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var currentFrame = 1
    var imageView = UIImageView()
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        //imageView.image = UIImage(named: "tapHere")
        imageView.isUserInteractionEnabled = true
       
       
        scrollView.addSubview(imageView)
        
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.loadImage))
        tapGestureRecongnizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecongnizer)
        
        textView.contentInset = UIEdgeInsetsMake(-5,0,0,0)
        textView.font = UIFont(name: "Helvetica", size: 14)
        
        
        // place holder text for textview
        textView.text = "Tap here to enter text"
        textView.textColor = UIColor.lightGray
        
        self.textView.delegate = self

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
            textView.font = UIFont(name: "Helvetica", size: 14)
            textView.text = "Tap here to enter text"
            textView.textColor = UIColor.lightGray
        }
    }

    // part 1 of calcing string length to limit text view to 4 lines
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName: font],
                                                 context: nil).size
    }
    //part 2 of calcing string length to keep textview at 4 lines
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        
        
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        
        return numberOfLines <= 5
    }

    //tap imageview to load image
    func loadImage(recognizer: UITapGestureRecognizer){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imageView.contentMode = UIViewContentMode.center
        centerScrollViewContents()
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    //picker once user taps imageview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
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
        centerScrollViewContents()
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
    

    @IBAction func save(_ sender: Any) {
         guard image != nil else { return }
        let offset = scrollView.contentOffset
        //let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let normalSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        let textViewWithImageSize = CGSize(width: scrollView.bounds.size.width, height: ((screenHeight * 0.17) + scrollView.bounds.size.height))
        var yPos: Int
        //if textView is active or not and the different y position for saved image to include the textview if it is active
        // screenHeight * 0.17 is the dynamic height of the textview per device.
        if textView.isHidden == true{
            UIGraphicsBeginImageContextWithOptions(normalSize, true, UIScreen.main.scale)
            textView.text = ""
            yPos = Int(-offset.y)
        }else{
            yPos = Int(-offset.y + screenHeight * 0.17)
            UIGraphicsBeginImageContextWithOptions(textViewWithImageSize, true, UIScreen.main.scale)
            
            //sets saves text area background to white, extendind the image area on its own colored the void black.
            let backgroundColor: UIColor = UIColor.white
            backgroundColor.setFill()
            UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: (offset.y - screenHeight * 0.17), width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
        }
        
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: CGFloat(yPos))
    
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica", size: 14)!
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        let rect = CGRect(x: offset.x + 5, y: (offset.y + 5 - screenHeight * 0.17), width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        
        textView.text.draw(in: rect, withAttributes: textFontAttributes)
       
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        centerScrollViewContents()
        
    let alert = UIAlertController(title: "Image Saved", message: "your image has been saved", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Neat", style: .default, handler: nil))
    }
    
        
    @IBAction func Filter(_ sender: Any) {
         guard image != nil else { return }
    }
    
    @IBAction func frame(_ sender: Any) {
         guard image != nil else { return }
        
        switch currentFrame{
        case 0:
            textView.isHidden = true
           
        case 1:
            textView.isHidden = false
        default:
            break
        }
        currentFrame += 1
        if currentFrame > 1 {
            currentFrame = 0
        }
}
    

}


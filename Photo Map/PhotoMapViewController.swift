//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import MessageUI
import Photos

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let vc = UIImagePickerController()
    var imageToView: UIImage!
    var annotations: [PhotoAnnotation] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageToView = image
        }
        self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
//        self.tabBarController?.selectedIndex = 0
    }

    // Mark: – LocationsViewControllerDelegate
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        //var image = controller
        // let annotation = MKPointAnnotation()
        let annotation = PhotoAnnotation()
        annotation.coordinate = locationCoordinate
        //annotation.title = "Picture!"
        mapView.addAnnotation(annotation)
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    // Mark: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x:0, y:0, width:45, height:45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        // resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        if let photoAnnotation = annotation as? PhotoAnnotation{
            resizeRenderImageView.image = imageToView
            UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
            resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()

            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: photoAnnotation, reuseIdentifier: reuseID)
                annotationView!.canShowCallout = true
                annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
                
                annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            }
            // UIGraphicsEndImageContext()
            let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
            // imageView.image = #imageLiteral(resourceName: "camera")
            // return annotationView
            imageView.image = thumbnail
            annotationView?.image = thumbnail
            
            UIGraphicsEndImageContext()
            //return annotationView
        }
        return annotationView
    }
    

    @IBAction func didTapCameraButton(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let imageView = view.leftCalloutAccessoryView as! UIImageView
//        imageToView = imageView.image
        
        self.performSegue(withIdentifier: "fullImageSegue", sender: nil)
    }
    
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "tagSegue" {
            let vc: LocationsViewController = segue.destination as! LocationsViewController
            vc.delegate = self 
        } else if segue.identifier == "fullImageSegue" {
            let imageDetailVC = segue.destination as! FullImageViewController
            imageDetailVC.photoImage = imageToView
        }        // Pass the selected object to the new view controller.
    }
}

//
//  ViewController.swift
//  TravekBook
//
//  Created by sıfa on 27.01.2020.
//  Copyright © 2020 sıfa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

  class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var chosenLongitute = Double()
    var chosenLatitute = Double()
    
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitute = Double()
    var annotationLongitute = Double()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        //Konumun doğruluğunun derecesi- en iyisi en çok pil tüketir
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Pin oluşturma Kaç sn basılı tut
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        // eğer + butonu ile giderse yeni bi şey, tabview ile giderse eskisini göster
        if selectedTitle != ""{
            //coredata
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchrequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchrequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchrequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subTittle = result.value(forKey: "subtitle") as? String {
                            annotationSubtitle = subTittle
                                
                                if let latitute = result.value(forKey: "latitute") as? Double{
                                                           annotationLatitute = latitute
                                    
                                    if let longitute = result.value(forKey: "longitute") as? Double {
                                    annotationLongitute = longitute
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitute, longitude: annotationLongitute)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                    }
                }
            }
        }
                        
    }
        }
            }catch {
                
                print("error")
            
            }
            
            
            } else{
                // add new data
            }
       
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let touchedPoint  = gestureRecognizer.location(in: self.mapView)
            //Dokunulannoktayı koordinata çevir
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            chosenLatitute = touchedCoordinate.latitude
            chosenLongitute = touchedCoordinate.longitude
            
        }
        
    }
    
    //update edilen lokasyonları bir dizinin içine atan fonk
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //zoom derecesi
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    @IBAction func SaveBttn(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLongitute, forKey: "longitute")
        newPlace.setValue(chosenLatitute, forKey: "latitute")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("success")
            
        }catch{
            print("error")
        }
        
    }
    
}


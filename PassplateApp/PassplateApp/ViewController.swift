//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    let settingsSegueIdentifier = "HomeToSettingsSegue"
    var userAllergens: [String] = []
    var userName: String = ""
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let countryToLocationMap = [
        "American": "New York, USA",
        "British": "London, England",
        "Canadian": "Ottawa, Canada",
        "Chinese": "Beijing, China",
        "Croatian": "Zagreb, Croatia",
        "Dutch": "Amsterdam, Netherlands",
        "Egyptian": "Cairo, Egypt",
        "Filipino": "Manila, Philippines",
        "French": "Paris, France",
        "Greek": "Athens, Greece",
        "Indian": "New Delhi, India",
        "Irish": "Dublin, Ireland",
        "Italian": "Rome, Italy",
        "Jamaican": "Kingston, Jamaica",
        "Japanese": "Tokyo, Japan",
        "Kenyan": "Nairobi, Kenya",
        "Malaysian": "Kuala Lumpur, Malaysia",
        "Mexican": "Mexico City, Mexico",
        "Moroccan": "Rabat, Morocco",
        "Polish": "Warsaw, Poland",
        "Portuguese": "Lisbon, Portugal",
        "Russian": "Moscow, Russia",
        "Spanish": "Madrid, Spain",
        "Thai": "Bangkok, Thailand",
        "Tunisian": "Tunis, Tunisia",
        "Turkish": "Ankara, Turkey",
        "Vietnamese": "Hanoi, Vietnam"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        fetchUserData()
        // Add annotations for countries on the map
        for (country, location) in countryToLocationMap {
            addAnnotationForCountry(country, atLocation: location)
        }
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = SettingsManager.shared.selectedSegment
    }

    @objc func segmentedControlValueChanged() {
        SettingsManager.shared.selectedSegment = segmentedControl.selectedSegmentIndex
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "SearchSegueIdentifier", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let country = view.annotation?.title,
           let location = countryToLocationMap[country!] {
            initiateRecipeSearch(forLocation: location)
        }
    }
    
    func addAnnotationForCountry(_ country: String, atLocation locationName: String) {
        let annotation = MKPointAnnotation()
        annotation.title = country
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            if let placemark = placemarks?.first {
                annotation.coordinate = placemark.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func initiateRecipeSearch(forLocation location: String) {
        for (country, loc) in countryToLocationMap {
            if loc == location {
                searchBar.text = country
            }
        }
        performSegue(withIdentifier: "SearchSegueIdentifier", sender: location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegueIdentifier" {
            if let destinationVC = segue.destination as? SearchViewController {
//                if let searchQuery = sender as? String {
                    destinationVC.inputSearchText = searchBar.text ?? ""
//                }
            }
        }
        if segue.identifier == settingsSegueIdentifier,
           let destination = segue.destination as? SettingsViewController {
            // When the user goes to create a new pizza, these fields should not be populated.
            destination.name = userName
            destination.allergyList = userAllergens
        }
    }
    
    func fetchUserData() {
        let uid = Auth.auth().currentUser?.uid
        Firestore.firestore().collection("users").document(uid!).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data from Firestore: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                // User document exists, and you can access its data
                if let userData = document.data() {
                    // Access specific fields from userData
                    self.userName = (userData["name"] as? String)!
                    self.userAllergens = (userData["allergies"] as? [String])!
                }
            } else {
                print("User document does not exist in Firestore.")
            }
        }
    }
}

class SettingsManager {
    static let shared = SettingsManager()
    var selectedSegment: Int = 0
}

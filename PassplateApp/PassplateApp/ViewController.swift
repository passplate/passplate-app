//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    
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

        // Add annotations for countries on the map
        for (country, location) in countryToLocationMap {
            addAnnotationForCountry(country, atLocation: location)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "SearchSegueIdentifier", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let country = view.annotation?.title,
           let location = countryToLocationMap[country!] {
            // You've tapped on a country, and now you can search recipes based on the selected location.
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
    }
}


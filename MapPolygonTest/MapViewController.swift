//
//  MapViewController.swift
//  MapPolygonTest
//
//  Created by Paul Peelen on 2019-06-02.
//  Copyright © 2019 ICA Gruppen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  var locations: [Location] = [] {
    didSet {
      showListing.isEnabled = locations.count > 0
      saveToFile()
    }
  }

  var points: [CLLocationCoordinate2D] = [] {
    didSet {
      print(points)
      resetButton.isEnabled = points.count > 0
      completeButton.isEnabled = points.count > 0
      undoButton.isEnabled = points.count > 0
    }
  }

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var resetButton: UIBarButtonItem!
  @IBOutlet weak var actionView: UIView!
  @IBOutlet weak var showListing: UIBarButtonItem!

  @IBOutlet weak var completeButton: UIButton!
  @IBOutlet weak var undoButton: UIButton!

  @IBAction func completePolygon(_ sender: UIButton) {
    let polygon = MKPolygon(coordinates: &points, count: points.count)
    mapView.addOverlay(polygon) //Add polygon areas

    var coordinates: [Coordinate] = []
    for point in points {
      coordinates.append(Coordinate(coordinate: point))
    }
    let location = Location(name: nil, points: coordinates)
    locations.append(location)
    points = []
    reset()
    showListing.title = "Show lists (\(locations.count))"

    drawCompletedLocatios()
  }

  @IBAction func undoLast(_ sender: UIButton) {
    if points.count > 0 {
      points.removeLast()
      updatePolylines()
    }
  }

  @IBAction func resetButtonPressed(_ sender: Any) {
    points = []
    reset()
  }

  @IBAction func updateSegment(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      mapView.mapType = .standard
    } else {
      mapView.mapType = .satellite
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? ListingViewController {
      vc.loadView()
      vc.setup(withLocations: locations)
      vc.didUpdateLocation = { locations in
        self.locations = locations
        self.fullReset()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    centerOnVenue()
    resetButton.isEnabled = false
    showListing.isEnabled = false
    completeButton.isEnabled = false
    undoButton.isEnabled = false

    locations = loadFromFile()
    fullReset()
  }

  func fullReset() {
    reset()
    showListing.title = "Show lists (\(locations.count))"

    drawCompletedLocatios()
  }

  func reset() {
    mapView.removeOverlays(mapView.overlays) //Reset shapes
  }

  func drawCompletedLocatios() {
    for location in locations {
      let locationPoints = location.points.compactMap({ $0.coordinate })
      let polygon = MKPolygon(coordinates: locationPoints, count: locationPoints.count)
      mapView.addOverlay(polygon)
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
      points.append(coordinate)
      updatePolylines()
    }
  }

  func updatePolylines() {
    let polyline = MKPolyline(coordinates: points, count: points.count)
    mapView.addOverlay(polyline) //Add lines
  }

  private func centerOnVenue() {
    let location = CLLocation(latitude: 53.11492071953518, longitude: 4.89718462979863)
    centerMapOnLocation(location: location)
  }

  func centerMapOnLocation(location: CLLocation) {
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    DispatchQueue.main.async {
      self.mapView.setRegion(region, animated: true)
      let annotation = MKPointAnnotation()
      annotation.coordinate = location.coordinate
      self.mapView.addAnnotation(annotation)
    }
  }

  private func saveToFile() {
    guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("locations.json") else { debugPrint("Could not make path"); return }

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonText = try encoder.encode(locations)
      try jsonText.write(to: url)
      debugPrint("Saved to file: \(url.path)")
    } catch {
      debugPrint("Could not encode! Error: \(error.localizedDescription)")
      return
    }
  }

  private func loadFromFile() -> [Location] {
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("locations.json") else { debugPrint("Could not make path"); return [] }
    guard let data = FileManager.default.contents(atPath: path.path) else { debugPrint("File has no content!"); return [] }

    do {
      return try JSONDecoder().decode([Location].self, from: data)
    } catch {
      debugPrint("Could not decode! Error: \(error.localizedDescription)")
      return []
    }
  }
}

extension MapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = .orange
      polylineRenderer.lineWidth = 5
      return polylineRenderer
    } else if overlay is MKPolygon {
      let polygonView = MKPolygonRenderer(overlay: overlay)
      polygonView.fillColor = .magenta
      return polygonView
    }
    return MKPolylineRenderer(overlay: overlay)
  }
}

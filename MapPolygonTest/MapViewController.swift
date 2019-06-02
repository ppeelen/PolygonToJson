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
  @IBOutlet weak var generateJson: UIBarButtonItem!

  @IBOutlet weak var completeButton: UIButton!
  @IBOutlet weak var undoButton: UIButton!

  @IBAction func completePolygon(_ sender: UIButton) {
    let polygon = MKPolygon(coordinates: &points, count: points.count)
    mapView.addOverlay(polygon) //Add polygon areas
    generateJson.isEnabled = true
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
    if let vc = segue.destination as? JSONViewController {
      vc.loadView()
      vc.setup(withPoints: points)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    centerOnVenue()
    resetButton.isEnabled = false
    generateJson.isEnabled = false
    completeButton.isEnabled = false
    undoButton.isEnabled = false
  }

  func reset() {
    mapView.removeOverlays(mapView.overlays) //Reset shapes
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
      points.append(coordinate)
      updatePolylines()
    }
  }

  func updatePolylines() {
    reset()
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

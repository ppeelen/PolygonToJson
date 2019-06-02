//
//  JSONViewController.swift
//  MapPolygonTest
//
//  Created by Paul Peelen on 2019-06-02.
//  Copyright © 2019 ICA Gruppen. All rights reserved.
//

import UIKit
import CoreLocation

class JSONViewController: UIViewController {

  @IBOutlet weak var textView: UITextView!

  private var points: [CLLocationCoordinate2D] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func setup(withPoints points: [CLLocationCoordinate2D]) {
    self.points = points
    makeJsonData()
  }

  func makeJsonData() {
    var locations: [Location] = []

    for point in points {
      locations.append(Location(coordinate: point))
    }

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonText = try encoder.encode(locations)
      textView.text = String(data: jsonText, encoding: .utf8)
    } catch {
      debugPrint("Error while encoding: \(error.localizedDescription)")
    }
  }
}

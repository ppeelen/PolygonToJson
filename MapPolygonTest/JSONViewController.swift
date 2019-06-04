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
  private var locations: [Location] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func setup(withLocations locations: [Location]) {
    self.locations = locations
    makeJsonData()
  }

  func makeJsonData() {
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

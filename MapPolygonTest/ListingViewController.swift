//
//  ListingViewController.swift
//  MapPolygonTest
//
//  Created by Paul Peelen on 2019-06-04.
//  Copyright © 2019 ICA Gruppen. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController {

  private var locations: [Location] = [] {
    didSet {
      didUpdateLocation?(locations)
    }
  }
  @IBOutlet weak var tableView: UITableView!

  var didUpdateLocation: (([Location]) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func setup(withLocations locations: [Location]) {
    self.locations = locations
    tableView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? JSONViewController {
      vc.loadView()
      vc.setup(withLocations: locations)
    }
  }
}

extension ListingViewController: UITableViewDelegate { }

extension ListingViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locations.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as? TextFieldCell else { debugPrint("NO CELL!"); return UITableViewCell() }
    let location = locations[indexPath.row]
    cell.setup(withLocation: location)

    cell.textfieldValueDidChange = { text in
      var location = self.locations[indexPath.row]
      location.name = text
      self.locations[indexPath.row] = location
    }

    return cell
  }
}

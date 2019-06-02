//
//  Location.swift
//  MapPolygonTest
//
//  Created by Paul Peelen on 2019-06-02.
//  Copyright © 2019 ICA Gruppen. All rights reserved.
//

import CoreLocation

struct Locations: Codable {
  var points: [Location]
}

struct Location: Codable {

  var latitude: Double {
    return coordinate.latitude
  }
  var longitude: Double {
    return coordinate.longitude
  }
  var coordinate: CLLocationCoordinate2D

  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }

  public enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let latitude = try values.decode(Double.self, forKey: .latitude)
    let longitude = try values.decode(Double.self, forKey: .longitude)

    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

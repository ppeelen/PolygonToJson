//
//  TextFieldCell.swift
//  MapPolygonTest
//
//  Created by Paul Peelen on 2019-06-04.
//  Copyright © 2019 ICA Gruppen. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

  @IBOutlet weak var textField: UITextField!

  var location: Location?
  var textfieldValueDidChange: ((String) -> Void)?

  func setup(withLocation location: Location) {
    self.location = location
    textField.text = location.name
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    textField.text = ""
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

extension TextFieldCell: UITextFieldDelegate {

  func textFieldDidEndEditing(_ textField: UITextField) {
    textfieldValueDidChange?(textField.text ?? "")
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text {
      textfieldValueDidChange?(text)
    }
    return true
  }
}

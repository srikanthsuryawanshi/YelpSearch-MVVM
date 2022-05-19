//
//  AlertHandler.swift
//  YelpSearch
//
//  Created by Srikanth SP on 01/04/22.
//

import Foundation
import UIKit


extension UIViewController {
    func throwErrorAlert(title:String, text:String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func throwEmptyAlert(title:String) {
        let text = "No Restaurant found!"
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
}

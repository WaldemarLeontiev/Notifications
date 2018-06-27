//
//  ViewController.swift
//  notifications
//
//  Created by Waldemar on 20/06/2018.
//  Copyright © 2018 h7.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func showNotificationButtonPressed(_ sender: Any) {
        let viewController = NotificationViewController(title: "You’re about to enable AR!",
                                                        text: "Augmented Reality (AR) is an exciting new but experimental feature. Please be aware of eventual issues and app crashes. Enjoy new Live Masks and Filters but also let us know if something goes wrong. \n\nShake your %@ when a problem occurs and follow instructions. Thank you!")
        self.add(viewController)
        viewController.view.makeSuperviewInsetConstraints(top: 0, bottom: 0, left: 0, right: 0)
        viewController.addAction(NotificationAction(title: "Button 1", handler: {print("Button 1")}))
        viewController.addAction(NotificationAction(title: "Button 2", handler: {print("Button 2")}))
        viewController.addAction(NotificationAction(title: "Button 3", handler: {print("Button 3")}))
        viewController.addAction(NotificationAction(title: "Button 4", handler: {print("Button 4")}))
        viewController.addAction(NotificationAction(title: "Button 5", handler: {print("Button 5")}))
        viewController.show()
    }
}

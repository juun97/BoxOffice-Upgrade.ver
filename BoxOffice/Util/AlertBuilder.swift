//
//  AlertBuilder.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/09/07.
//

import UIKit

final class AlertBuilder {
    private var preferredStyle: UIAlertController.Style = .alert
    private var title: String? = nil
    private var message: String? = nil
    private var actions: [UIAlertAction] = [UIAlertAction]()

    
    func preferredStyle(_ style: UIAlertController.Style) -> AlertBuilder {
        self.preferredStyle = style
        return self
    }
    
    func withTitle(_ title: String?) -> AlertBuilder {
        self.title = title
        return self
    }
    
    func withMessage(_ message: String?) -> AlertBuilder {
        self.message = message
        return self
    }
    
    func addAction(_ title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> AlertBuilder {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        actions.append(action)
        return self
    }
    
    func show(in viewController: UIViewController, animated: Bool = true) {
        viewController.present(build(), animated: animated)
    }
    
    private func build() -> UIAlertController {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.preferredStyle)
        
  
        actions.forEach { action in
            alert.addAction(action)
        }
        
        return alert
    }
}

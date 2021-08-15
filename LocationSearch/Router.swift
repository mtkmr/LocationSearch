//
//  Router.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/08/15.
//

import UIKit

final class Router {
    static let shared = Router()
    private init() {}

    private var window: UIWindow?
    
    func showRoot(window: UIWindow?) {
        let searchMapVC = SearchMapViewController()
        window?.rootViewController = UINavigationController(rootViewController: searchMapVC)
        window?.makeKeyAndVisible()
        self.window = window
    }
    
}

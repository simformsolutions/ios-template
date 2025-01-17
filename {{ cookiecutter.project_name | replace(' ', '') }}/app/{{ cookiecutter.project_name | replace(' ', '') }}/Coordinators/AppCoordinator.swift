//
//  AppCoordinator.swift
//  {{ cookiecutter.project_name | replace(' ', '') }}
//
//  Created by {{ cookiecutter.lead_dev }} on {% now 'utc', '%D' %}.
//  Copyright © {% now 'utc', '%Y' %} {{ cookiecutter.company_name }}. All rights reserved.
//

import UIKit
import Services

class AppCoordinator: Coordinator {

    private let window: UIWindow
    fileprivate let rootController: UIViewController
    var childCoordinator: Coordinator?

    init(window: UIWindow) {
        self.window = window
        let rootController = UIViewController()
        rootController.view.backgroundColor = .white
        self.rootController = rootController
    }

    func start(animated: Bool, completion: VoidClosure?) {
        // Configure window/root view controller
        window.setRootViewController(rootController, animated: false, completion: {
            self.window.makeKeyAndVisible()

            // Spin off auth coordinator
            let authCoordinator = AuthCoordinator(self.rootController)
            authCoordinator.delegate = self
            self.childCoordinator = authCoordinator
            authCoordinator.start(animated: animated, completion: completion)
        })
    }

    func cleanup(animated: Bool, completion: VoidClosure?) {
        completion?()
    }

}

extension AppCoordinator: AuthCoordinatorDelegate {

    func authCoordinator(_ coordinator: AuthCoordinator, didNotify action: AuthCoordinator.Action) {
        switch action {
        case .didSignIn:
            guard let authCoordinator = childCoordinator as? AuthCoordinator else {
                preconditionFailure("Upon signing in, AppCoordinator should have an AuthCoordinator as a child.")
            }
            childCoordinator = nil
            authCoordinator.cleanup(animated: true) {
                let contentCoordinator = ContentCoordinator(self.rootController)
                self.childCoordinator = contentCoordinator
                contentCoordinator.start(animated: true, completion: nil)
            }
        case .didSkipAuth:
            guard let authCoordinator = childCoordinator as? AuthCoordinator else {
                preconditionFailure("Upon signing in, AppCoordinator should have an AuthCoordinator as a child.")
            }
            childCoordinator = nil
            authCoordinator.cleanup(animated: false) {
                let contentCoordinator = ContentCoordinator(self.rootController)
                self.childCoordinator = contentCoordinator
                contentCoordinator.start(animated: true, completion: nil)
            }
        }
    }

}

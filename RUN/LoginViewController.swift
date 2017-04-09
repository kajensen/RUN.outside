//
//  LoginViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import SafariServices

protocol LoginDelegate: class {
    func didCompleteLogin(_ login: Login)
    func didGetSession(_ login: Login, session: Session?)
}

class Login: NSObject {
    
    static var login: Login?
    
    enum App {
        case mapMyRun
        var path: String {
            switch self {
            case .mapMyRun:
                return "mapmyrun"
            }
        }
    }
    
    weak var vc: SFSafariViewController?
    var app: App = .mapMyRun
    var completion: ((_ success: Bool, _ workouts: [Workout]?) -> Void)?
    weak var delegate: LoginDelegate?
    
    convenience init(app: App, vc: SFSafariViewController) {
        self.init()
        self.app = app
        self.vc = vc
    }
    
    class func handleLogin(_ url: URL) {
        let app = url.lastPathComponent
        guard let code = url.queryParameters["code"] else { return }
        if let login = Login.login, login.app.path == app {
            login.handleCode(code)
        }
    }
    
    func handleCode(_ code: String) {
        delegate?.didCompleteLogin(self)
        switch app {
        case .mapMyRun:
            API.MapMyRun.getToken(code, completion: { [weak self] (success, session, error) in
                guard let login = self else { return }
                login.delegate?.didGetSession(login, session: session)
            })
        }
    }
    
}

extension UIViewController {
    
    func presentMapMyRun(_ delegate: LoginDelegate) {
        guard let url = Constants.MapMyRun.oauthURL else { return }
        let svc = RUNSafariViewController(url: url)
        let login = Login(app: .mapMyRun, vc: svc)
        login.delegate = delegate
        Login.login = login
        present(svc, animated: true, completion: nil)
    }
    
}

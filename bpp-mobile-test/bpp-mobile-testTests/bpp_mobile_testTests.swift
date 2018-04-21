//
//  bpp_mobile_testTests.swift
//  bpp-mobile-testTests
//
//  Created by Gustavo Galembeck on 4/20/18.
//  Copyright © 2018 Gustavo Galembeck. All rights reserved.
//

import XCTest
@testable import bpp_mobile_test

class bpp_mobile_testTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func loginTest() {
        let app = UIApplication.shared
        
        let loginViewController: LoginViewController = app.keyWindow?.rootViewController as! LoginViewController!
        
        loginViewController.emailTextField.text = "waldisney@brasilprepagos.com.br"
        loginViewController.passwordTextField.text = "Br@silPP123"
        loginViewController.loginButton.sendActions(for: UIControlEvents.touchUpInside)
    }
}

//
//  ViewController.swift
//  bpp-mobile-test
//
//  Created by Gustavo Galembeck on 4/20/18.
//  Copyright © 2018 Gustavo Galembeck. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginAction(sender: UIButton!) {
        
        let email: String = emailTextField.text!
        let password: String = passwordTextField.text!
        
        if ((email.trimmingCharacters(in: CharacterSet.whitespaces) == "") || (password.trimmingCharacters(in: CharacterSet.whitespaces) == "")) {
            showError(message: "Dados inválidos")
            return
        }
        
        let passwordData: Data = password.data(using: String.Encoding.utf8)!
        let passwordBase64: String = passwordData.base64EncodedString()
        
        let url: String = "http://test-mobile.dev-bpp.com.br/login"
        var urlRequest = URLRequest(url: URL(string: url)!)
        
        let requestBody: [String: String] = ["email": email, "password": passwordBase64]
        var requestJsonBody: Data
        
        if (JSONSerialization.isValidJSONObject(requestBody)) {
            do {
                requestJsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                showError(message: "Dados inválidos")
                return
            }
        }
        else {
            showError(message: "Dados inválidos")
            return
        }
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = requestJsonBody
        urlRequest.timeoutInterval = 60
        
        let urlSession = URLSession.shared
        
        let request = urlSession.dataTask(with: urlRequest) { (data, response, error) in
        
            var responseJson: Any
            
            if (error != nil) {
                self.showError(message: "Erro de login")
                return
            }
            
            do {
                responseJson = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                self.showError(message: "Erro de login")
                return
            }
            
            let response = responseJson as! [String: String]
            
            //if (response["status"] == "error")
            if (false)
            {
                self.showError(message: String.init(format: "Erro %@: %@", response["code"]!, response["message"]!))
            }
            else
            {
                self.showTimeline()
            }
        }
        
        request.resume()
    }
    
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
        }
    }
    
    func showTimeline() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
}


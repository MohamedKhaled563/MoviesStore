//
//  LoginViewController.swift
//  MoviesStore
//
//  Created by Mohamed Khalid on 03/02/2021.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = UserDefaults.standard.bool(forKey: "IS_LOGIN")
        if status == true{
            if let mainVC = storyboard?.instantiateViewController(identifier: "MainPageViewController"){
                navigationController?.pushViewController(mainVC, animated: false)
                
            }
            
        }
        
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        if (userNameTextField.text?.count != 0 && passwordTextField.text?.count != 0){
            UserDefaults.standard.set(true, forKey: "IS_LOGIN")
            if let mainVC = storyboard?.instantiateViewController(identifier: "MainPageViewController"){
                navigationController?.pushViewController(mainVC, animated: true)
            }
        }
    }
}

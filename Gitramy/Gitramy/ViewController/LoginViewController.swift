//
//  ViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    var provider = OAuthProvider(providerID: "github.com")
    
    @IBOutlet weak var githubLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        githubLoginButton.layer.borderWidth = 1
        githubLoginButton.layer.borderColor = UIColor.white.cgColor
        githubLoginButton.layer.cornerRadius = 30
    }

    @IBAction func LoginButtonTapped(_ sender: Any) {
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                print("getCredential Error : \(error!.localizedDescription)")
            }
            
            if credential != nil {
                Auth().signIn(with: credential) { authResult, error in
                    if error != nil {
                        print("sign In Error : \(error.localizedDescription)")
                    }
                    
                    guard let oauthCredential = authResult.credential as? OAuthCredential else {return}
                }
            }
            
            
            
        }
        
    }
    
}


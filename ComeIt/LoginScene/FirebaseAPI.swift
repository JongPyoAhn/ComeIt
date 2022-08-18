//
//  LoginManager.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit
import FirebaseAuth
import Combine
import Moya

class FirebaseAPI{
    static let shared = FirebaseAPI()
    private init() {}
    var user: User?
    var userAccessToken: String?
    private var firebaseAuth = Auth.auth()
    private var provider: OAuthProvider!
    private var subscription = Set<AnyCancellable>()
    
    func logIn(){
        getCredentialAndSignIn()
            .sink { completion in
                switch completion{
                case .finished:
                    print("getCredentialAndSignIn - finished")
                case .failure(let err):
                    print("getCredentialAndSignIn - \(err)")
                }
            } receiveValue: {[weak self] authDataResult in
                guard let self = self else {return}
                guard let oAuthCredential = authDataResult.credential as? OAuthCredential else {return}
                self.userAccessToken = oAuthCredential.accessToken
                UserDefaults.standard.set(oAuthCredential.accessToken, forKey: "userAccessToken")
            }.store(in: &subscription)
    }
    
    private func getCredentialAndSignIn() -> AnyPublisher<AuthDataResult, Error>{
        provider = OAuthProvider(providerID: "github.com")
        firebaseAuth = Auth.auth()
        
        provider.scopes = ["repo, user"]
        return provider.getCredentialWith(nil)
            .flatMap {[weak self] authCredential in
                return (self?.signIn(with: authCredential).eraseToAnyPublisher())!
            }
            .eraseToAnyPublisher()
    }
    
    private func signIn(with credential: AuthCredential) -> Future<AuthDataResult, Error> {
          Future<AuthDataResult, Error> {[weak self] promise in
              guard let self = self else {return}
              self.firebaseAuth.signIn(with: credential) { authDataResult, error in
              if let error = error {
                promise(.failure(error))
              } else if let authDataResult = authDataResult {
                promise(.success(authDataResult))
              }
            }
          }
        }
    
    func logout(){
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        UserDefaults.standard.removeObject(forKey: "userAccessToken")
    }
    func tokenValidate(_ response: Response, success:(()->())){
        if 200..<300 ~= response.statusCode{
            success()
        }else if response.statusCode == 401 || response.statusCode == 403{//토큰관련 에러
            logout()
        }
    }
}



//https://firebase.google.com/docs/auth/ios/github-auth?hl=ko
//https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
//
public extension OAuthProvider {
     func getCredentialWith(_ uiDelegate: AuthUIDelegate?)
       -> Future<AuthCredential, Error> {
       Future<AuthCredential, Error> { promise in
         self.getCredentialWith(uiDelegate) { authCredential, error in
           if let error = error {
             promise(.failure(error))
           } else if let authCredential = authCredential {
               promise(.success(authCredential))
           }
         }
       }
     }
   }

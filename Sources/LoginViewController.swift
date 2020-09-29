import UIKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailField.delegate = self
        passwordField.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        signInButton.colorScheme = GIDSignInButtonColorScheme.dark
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    
    func validatePassword() -> Bool {
        passwordErrorLabel.isHidden = false
        guard let password = passwordField.text, !password.isEmpty else {
            passwordErrorLabel.text = "Please enter a valid password!"
            return false
        }
        
        guard password.count >= 6 else {
            passwordErrorLabel.text = "Password must be less than 6 characters!"
            return false
        }
        
        passwordErrorLabel.isHidden = true
        return true
    }
    
    func validateEmail() -> Bool {
        emailErrorLabel.isHidden = false
        guard let email = emailField.text, !email.isEmpty else {
            emailErrorLabel.text = "Enter a valid email ID!"
            return false
        }
        
        guard isValid(email) else {
            emailErrorLabel.text = "Please enter a valid email!"
            return false
        }
        
        emailErrorLabel.isHidden = true
        return true
    }
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(_ sender: Any) {
        guard validatePassword() && validateEmail() else {
            return
        }
        guard let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        AuthService.instance.firebaseAuth(email: email, password: password) { (success) in
            if success {
                self.performSegue(withIdentifier: "Login", sender: self)
            } else {
                print("error")
            }
        }
        
    }
}

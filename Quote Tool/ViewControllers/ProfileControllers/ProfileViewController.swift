//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   ProfileViewController.swift     //
//                                              //
//  Desc:       Edit the profile                //
//                                              //
//  Creation:   04Nov19                         //
//**********************************************//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var roleField: UILabel!
    @IBOutlet weak var numQuotesField: UILabel!
    @IBOutlet weak var numAccountsField: UILabel!
    @IBOutlet weak var ChangeProfButton: UIButton!
    @IBOutlet weak var logout: UIButton!
    var defaults = UserDefaults.standard
    
    //**********************************************//
    //                                              //
    //  func:   viewDidLoad                         //
    //                                              //
    //  Desc:   Function that takes care of         //
    //          initializing the view and all of its//
    //          components. Many styling adjustments//
    //          exist here.                         //
    //                                              //
    //  args:                                       //
    //**********************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set fields
        usernameField.text = User.current_user.email
        roleField.text = User.current_user.role
    }
    
    //**********************************************//
    //                                              //
    //  func:   viewDidAppear                       //
    //                                              //
    //  Desc:   Populates the user's statistics when//
    //          the view is presented to the user   //
    //                                              //
    //  args:   animated - Bool                     //
    //**********************************************//
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .default).async {
            let account_array = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
            let quote_array = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
            DispatchQueue.main.async {
                // UI updates must be on main thread
                self.numAccountsField.text = String(account_array.count)
                self.numQuotesField.text = String(quote_array.count)
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   logoutClicked                       //
    //                                              //
    //  Desc:   Performs several logout functions.  //
    //          Removes all user info and the jwt.  //
    //          Returns the view to the login page  //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func logoutClicked(_ sender: Any) {
        defaults.removeObject(forKey: "jwt")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "id")
        User.current_user.id = 0
        User.current_user.email = ""
        User.current_user.jwt = ""
        for v in self.view.subviews{
            v.removeFromSuperview()
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginViewController
        loginController.modalPresentationStyle = .fullScreen
        self.present(loginController, animated:true, completion:nil)
    }
    
    //**********************************************//
    //                                              //
    //  func:   profChangeClicked                   //
    //                                              //
    //  Desc:   Populates a message box to ask the  //
    //          user what they want to update, if   //
    //          anything, and proceeds to segue to  //
    //          the view                            //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func profChangeClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Change Profile", message:
            "Please select what you'd like to change.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Change Email", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "emailSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Change Password", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "passSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

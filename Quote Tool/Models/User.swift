//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   User.swift                      //
//                                              //
//  Desc:       Data model for user             //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class User {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    
    //Singleton
    static let current_user = User()
    //MARK: Properties
    var email : String!      //the users email
    var jwt : String!        //jwt retrieved from login and used for following requests
    var id : Int!            //users id
    var group_id : Int?      //the group id the user belongs to
    var role : String?       //User,admin
    
    //Initializer
    private init(){
        self.email = ""
        self.jwt = ""
        self.id = 0
    }
    
    func setCurrentUser(email: String, jwt: String, id: Int) {
        User.current_user.email = email
        User.current_user.jwt = jwt
        User.current_user.id = id
    }
    
}

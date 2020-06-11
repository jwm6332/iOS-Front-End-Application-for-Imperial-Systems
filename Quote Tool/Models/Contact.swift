//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Contact.swift                   //
//                                              //
//  Desc:       Data model for Contact          //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class Contact {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on. Expected to have a value
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    //MARK: Properties
    var first_name : String!
    var last_name : String!
    var email : String?
    var fax : String?
    var notes : String?
    var phone : String?
    var title : String?
    var id : Int!
    var account_id : Int!
    var modified_dates : DateHandler
    
    //Initializer with optional values
    init(first_name: String, last_name: String, email: String, fax: String, phone: String, title: String, notes: String, id: Int, account_id: Int, created: String, updated: String){
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.fax = fax
        self.notes = notes
        self.phone = phone
        self.title = title
        self.id = id
        self.account_id = account_id
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
    }
    
    //Initializer with default values
    init(){
        self.first_name = ""
        self.last_name = ""
        self.email = ""
        self.fax = ""
        self.notes = ""
        self.phone = ""
        self.title = ""
        self.id = 0
        self.account_id = 0
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
    }
    
    //Checks if two contacts are equal
    func equals(contact: Contact) -> Bool {
        var flag: Bool = true
        if(contact.first_name != self.first_name){
            flag = false
        }
        if(contact.last_name != self.last_name){
            flag = false
        }
        if(contact.email != self.email){
            flag = false
        }
        if(contact.fax != self.fax){
            flag = false
        }
        if(contact.notes != self.notes){
            flag = false
        }
        if(contact.phone != self.phone){
            flag = false
        }
        if(contact.title != self.title){
            flag = false
        }
        return flag
    }
    
}

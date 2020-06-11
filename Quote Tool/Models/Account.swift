//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Account.swift                   //
//                                              //
//  Desc:       Data model for Account          //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class Account {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on. Expected to have a value
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    //MARK: Properties
    var city : String
    var country : String
    var fax : String
    var name : String
    var phone : String
    var postal_code : String
    var state : String
    var street_1 : String
    var street_2 : String
    var website : String
    var contacts = [Int]()
    var id : Int!
    var modified_dates : DateHandler
    var group_id : Int
    
    //Initializer with required values
    init(){
        self.name = ""
        self.state = ""
        self.city = ""
        self.country = ""
        self.street_1 = ""
        self.street_2 = ""
        self.postal_code = ""
        self.fax = ""
        self.phone = ""
        self.website = ""
        self.id = 0
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
        self.group_id = 1
    }
    
    //Overloaded Initializer with most optionals
    init(name: String, state: String, city: String, country: String, street_1: String, postal_code: String, fax: String, phone: String, website: String){
        self.name = name
        self.state = state
        self.city = city
        self.country = country
        self.street_1 = street_1
        self.street_2 = ""
        self.postal_code = postal_code
        self.fax = fax
        self.phone = phone
        self.website = website
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
        self.group_id = 1
    }
    
    //Overloaded Initializer
    init(name: String, state: String, city: String, country: String, street_1: String, street_2: String, postal_code: String, fax: String, phone: String, website: String, id : Int, created_at: String, updated_at: String, group_id: Int){
        self.name = name
        self.state = state
        self.city = city
        self.country = country
        self.street_1 = street_1
        self.street_2 = street_2
        self.postal_code = postal_code
        self.fax = fax
        self.phone = phone
        self.website = website
        self.id = id
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = created_at
        self.modified_dates.updated_at = updated_at
        self.group_id = 1
    }
    
    //Checks if two accounts are equal
    func equals(account: Account) -> Bool {
        var flag: Bool = true
        if(account.name != self.name){
            flag = false
        }
        if(self.state != self.state){
            flag = false
        }
        if(self.city != account.city){
            flag = false
        }
        if(self.country != account.country){
            flag = false
        }
        if(self.street_1 != account.street_1){
            flag = false
        }
        if(self.street_2 != account.street_2){
            flag = false
        }
        if(self.postal_code != account.postal_code){
            flag = false
        }
        if(self.fax != account.fax){
            flag = false
        }
        if(self.phone != account.phone){
            flag = false
        }
        if(self.website != account.website){
            flag = false
        }
        return flag
    }
}

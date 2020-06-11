//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Bundle.swift                    //
//                                              //
//  Desc:       Data model for bundles          //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class Bundle {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    
    //MARK: Properties
    var id : Int
    var name : String!
    var modified_date : DateHandler
    var quote_id : Int
    var option : Bool
    var quote_position : Int
    
    //Initializer with required values
    init(id: Int, name: String, created_at: String, updated_at: String, quote_id: Int, option: Bool, quote_position: Int){
        self.id = id
        self.name = name
        self.modified_date = DateHandler.init()
        self.modified_date.created_at = created_at
        self.modified_date.updated_at = updated_at
        self.quote_id = quote_id
        self.option = option
        self.quote_position = quote_position
    }
    
    //Initializer with required values
    init(name: String, quote_id: Int, option: Bool, quote_position: Int){
        self.id = 0
        self.name = name
        self.modified_date = DateHandler.init()
        self.modified_date.created_at = "0"
        self.modified_date.updated_at = "0"
        self.quote_id = quote_id
        self.option = option
        self.quote_position = quote_position
    }
    
    //Default initializer with default values
    init(){
        self.id = 0
        self.name = ""
        self.modified_date = DateHandler.init()
        self.modified_date.created_at = ""
        self.modified_date.updated_at = ""
        self.quote_id = 0
        self.option = false
        self.quote_position = 0
    }
    
}

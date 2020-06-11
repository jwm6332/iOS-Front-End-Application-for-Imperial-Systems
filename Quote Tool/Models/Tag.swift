//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Tag.swift                       //
//                                              //
//  Desc:       Data model for tag              //
//                                              //
//  Creation:   24Nov19                         //
//**********************************************//

import Foundation
public class Tag {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    var id: Int
    var name: String
    var category: String
    var value: String
    var taggable_type: String
    var taggable_id: Int
    var modified_dates : DateHandler
    
    
    init(id: Int, name: String, category: String, value: String, taggable_type: String, taggable_id: Int, updatedDate: String, createdDate: String) {
        self.id = id
        self.name = name
        self.category = category
        self.value = value
        self.taggable_type = taggable_type
        self.taggable_id = taggable_id
        modified_dates = DateHandler.init()
        modified_dates.created_at = createdDate
        modified_dates.updated_at = updatedDate
    }
    
    //Default initializer with default values
    init(){
        self.id = 0
        self.name = ""
        self.category = ""
        self.value = "$0.00"
        self.taggable_type = ""
        self.taggable_id = 0
        modified_dates = DateHandler.init()
        modified_dates.created_at = ""
        modified_dates.updated_at = ""
    }
    
}

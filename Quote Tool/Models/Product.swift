//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Product.swift                   //
//                                              //
//  Desc:       Data model for product          //
//                                              //
//  Creation:   24Nov19                         //
//**********************************************//

import Foundation
public class Product {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    var product_id : Int
    var active : Bool
    var category : String
    var description : String
    var digest_id : String
    var image : String
    var lead_time : Int
    var make : String
    var name : String
    var sku : String
    var modified_dates : DateHandler
    
    init(product_id:Int, active: Bool, category: String, description: String, digest_id: String, image: String, lead_time: Int, make: String, name: String, sku: String, created_date: String, updated_date: String){
        self.active = active
        self.product_id = product_id
        self.category = category
        self.description = description
        self.digest_id = digest_id
        self.image = image
        self.lead_time = lead_time
        self.make = make
        self.name = name
        self.sku = sku
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = created_date
        self.modified_dates.updated_at = updated_date
    }
    
    //Default initializer with default values
    init(){
        self.active = false
        self.product_id = 0
        self.category = ""
        self.description = ""
        self.digest_id = ""
        self.image = ""
        self.lead_time = 0
        self.make = ""
        self.name = ""
        self.sku = ""
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
    }
}

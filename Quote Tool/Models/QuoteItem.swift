//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   QuoteItem.swift                 //
//                                              //
//  Desc:       Data model for QuoteItem        //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class QuoteItem : Product {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    //Question marked items are the only ones NOT being filled in by API upon request
    
    //MARK: Properties
    var id : Int
    var quantity : Int
    var bundle_id : Int
    var model : String
    var price : Double
    var option : Bool
    var bundle_position : Int
    
    //Default initializer with default values
    override init(){
        self.id = 0
        self.quantity = 0
        self.bundle_id = 0
        self.model = ""
        self.price = 0.00
        self.option = false
        self.bundle_position = 0
        super.init()    //Initializes Product Superclass
    }
    
    //Initializer with required values
    init(id: Int, quantity: Int, bundle_id: Int, model: String, price: Double, option: Bool, bundle_position: Int, product_id: Int, active: Bool, category: String, description: String, digest_id: String, image:String, lead_time: Int, make: String, name: String, sku: String, updated_at:String, created_at:String){
        self.id = id
        self.quantity = quantity
        self.bundle_id = bundle_id
        self.model = model
        self.price = price
        self.option = option
        self.bundle_position = bundle_position
        super.init(product_id: product_id, active: active, category: category, description: description, digest_id: digest_id, image: image, lead_time: lead_time, make: make, name: name, sku: sku, created_date: created_at, updated_date: updated_at)
    }
    
}

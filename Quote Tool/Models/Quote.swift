//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Quote.swift                     //
//                                              //
//  Desc:       Data model for Quotes           //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class Quote {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    
    //MARK: Properties
    var account_id : Int
    var application : String
    var commission : Double!
    var list_prices : Bool
    var multiplier : Double!
    var open : Bool
    var quote_number : String!
    var id : Int!
    var modified_dates : DateHandler
    var contact_id : Int!
    var account_name: String
    var contact_name: String
    var lead_time: String
    var sell_price: Double
    var net_imperial: Double
    
    
    //Initializer with required values and filling in optionals that are required to send (even blank) in API
    init?(account_id: Int, commission: Double, quote_number: String, multiplier: Double, contact_id: Int, application: String, list_prices: Bool, open: Bool, created_date: String, updated_date: String, id: Int, lead_time: String, sell_price: Double, net_imperial: Double){
        
        guard !quote_number.isEmpty else {
            return nil
        }
        guard (commission>=0) && (multiplier>=0) else {
            return nil
        }
        
        self.account_id = account_id
        self.id = id
        self.commission = commission
        self.quote_number = quote_number
        self.multiplier = multiplier
        self.application = application
        self.list_prices = list_prices
        self.open = open
        self.contact_id = contact_id
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = created_date
        self.modified_dates.updated_at = updated_date
        self.account_name = ""
        self.contact_name = ""
        self.lead_time = lead_time
        self.sell_price = sell_price
        self.net_imperial = net_imperial
    }
    
    //Initializer with default values
    init(){
        self.id = 0
        self.account_id = 0
        self.commission = 0.00
        self.quote_number = "0"
        self.multiplier = 0.00
        self.application = ""
        self.list_prices = false
        self.open = false
        self.contact_id = 0
        self.modified_dates = DateHandler.init()
        self.modified_dates.created_at = ""
        self.modified_dates.updated_at = ""
        self.account_name = ""
        self.contact_name = ""
        self.lead_time = ""
        self.net_imperial = 0.00
        self.sell_price = 0.00
    }
    
    func equals(quote: Quote) -> Bool {
        var flag: Bool = true
        if self.account_id != quote.account_id {
            flag = false
        }
        if self.commission != quote.commission {
            flag = false
        }
        if self.quote_number != quote.quote_number {
            flag = false
        }
        if self.multiplier != quote.multiplier {
            flag = false
        }
        if self.application != quote.application {
            flag = false
        }
        if self.list_prices != quote.list_prices {
            flag = false
        }
        if self.open != quote.open {
            flag = false
        }
        if self.contact_id != quote.contact_id {
            flag = false
        }
        if self.modified_dates.created_at != quote.modified_dates.created_at {
            flag = false
        }
        if self.modified_dates.updated_at != quote.modified_dates.updated_at {
            flag = false
        }
        if self.lead_time != quote.lead_time {
            flag = false
        }
        if self.net_imperial != quote.net_imperial {
            flag = false
        }
        if self.sell_price != quote.sell_price {
            flag = false
        }
        return flag
    }
    
    func OpenToInt() -> Int{
        var int : Int = 0
        if self.open {
            int = 1
        }
        return int
    }
    
    func ListPricesToInt() -> Int{
        var int : Int = 0
        if self.list_prices {
            int = 1
        }
        return int
    }
    
}

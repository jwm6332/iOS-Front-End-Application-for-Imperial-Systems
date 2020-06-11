//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   ProductFile.swift               //
//                                              //
//  Desc:       Data model for ProductFile      //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class ProductFile {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    //All varibles will be filled in by API
    
    //MARK: Properties
    
    var id : Int
    var description : String
    var active : Bool
    var modified_date : DateHandler
    var document_url : String
    var language : String
    var family : String
    var document_type : String
    var preview_url : String
    var thumbnail_url : String
    var name: String
    
    init(id: Int, description: String, active: Bool, created_date: String, updated_date: String, document_url: String, language: String, family: String, document_type: String, preview_url: String, thumbnail_url: String, name: String){
        self.id = id
        self.description = description
        self.active = active
        self.modified_date = DateHandler.init()
        self.modified_date.created_at = created_date
        self.modified_date.updated_at = updated_date
        self.document_url = document_url
        self.language = language
        self.family = family
        self.document_type = document_type
        self.preview_url = preview_url
        self.document_url = document_url
        self.thumbnail_url = thumbnail_url
        self.name = name
    }
    
    //Default initializer with defualt values
    init(){
        self.id = 0
        self.description = ""
        self.active = false
        self.modified_date = DateHandler.init()
        self.modified_date.created_at = ""
        self.modified_date.updated_at = ""
        self.document_url = ""
        self.language = ""
        self.family = ""
        self.document_type = ""
        self.preview_url = ""
        self.document_url = ""
        self.thumbnail_url = ""
        self.name = ""
    }
}

//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   Protocol.swift                  //
//                                              //
//  Desc:       Defines logic of protocols      //
//              for interaction between         //
//              controllers                     //
//                                              //
//  Creation:   06Feb20                         //
//**********************************************//

import Foundation

//For passing data between FileCollectionController and SearchFileController
protocol Protocol {
    func onSearch(language: String, docType: String, equipType: String, searchCrit: String)
}

//For communication between accountviewController and SpecificAccountViewController
protocol AccountProtocol {
    //If account was deleted and make name = "" as this is normally impossible, indicator that user deleted this on the server.
    func passData(account: Account, new: Bool)
}

protocol QuoteProtocol {
    func passQuote(quote: Quote, new: Bool)
}

protocol ContactProtocol {
    func passContact(contact: Contact, new: Bool)
}

protocol BundleProtocol {
    func passBundle(bundle: Bundle, new: Bool)
}

protocol quoteItemProtocol{
    func passQuoteItems(quoteItem: QuoteItem)
}

protocol addQuoteItemProtocol{
    func addQuoteItem(quoteItem: QuoteItem)
}

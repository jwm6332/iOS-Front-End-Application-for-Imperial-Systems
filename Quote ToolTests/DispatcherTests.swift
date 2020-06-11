//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   DispatcherTests.swift           //
//                                              //
//  Desc:       This file contains all the tests//
//              developed to test methods within//
//              the apiDispatcher class         //
//                                              //
//  Creation:   16Nov19                         //
//                                              //
//  Last Commit & Push:                         //
//**********************************************//
//  JWM 16Nov19 Created Initial File            //
//  JWM 17Nov19 Added func headers and account  //
//              test cases                      //
//  JWM 25Nov19 Implemented 'Login' test suite. //
//  JWM 01Dec19 Implemented 'User' test suite   //
//**********************************************//

import XCTest
@testable import Quote_Tool

class testAPIDispatcher: XCTestCase
{
    struct UserTest {
        var jwt : String = ""
    }
    
    var user = UserTest()
    var code : Int = 0
    
    override func setUp()
    {
        let user : String = "admin@isystemsweb.com"
        let password : String = "test123"
        code = apiDispatcher.dispatcher.submitLogin(user: user, pass: password)
    }
    
    override func tearDown()
    {
        
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   testLogin                           //
    //                                              //
    //  Desc:   Asserts that a JWT was accepted     //
    //          and API returns 200 (success)       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testLogin()
    {
        //Use test username and password
        let username = "admin@isystemsweb.com"
        let password = "test123"
        
        //Call dispatcher login to get JWT for testing use.
        code = apiDispatcher.dispatcher.submitLogin(user: username, pass: password)
        XCTAssertTrue(code == 200)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testExtendLogin                     //
    //                                              //
    //  Desc:   Asserts that the upon extending     //
    //          login the API returns 200 (success) //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testExtendLogin()
    {
        code = apiDispatcher.dispatcher.extendLogin();
        XCTAssert(code == 200)
    }
    
     //******************************************************* BEGIN QUOTE TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   TestPostNewQuote                    //
    //                                              //
    //  Desc:   Calls getQuote and asserts that the //
    //          quote was created. Then calls       //
    //          deleteQuote to clean up the test    //
    //          quote.                              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostNewQuote()
    {
        var id: Int = 0
        var quoteObj: Quote
        
        //Post quote and get id of the quote
        let test_quote = Quote.init(account_id: 99, commission: 1, quote_number: "1", multiplier: 0.73, contact_id: 1, application: "Coreytest", list_prices: true, open: true, created_date: "", updated_date: "", id: 0, lead_time: "", sell_price: 0.00, net_imperial: 0.00)
        id = apiDispatcher.dispatcher.postNewQuote(quote: test_quote!)
        
        //Get the quote and assert that it is the same quote
        quoteObj = apiDispatcher.dispatcher.getQuote(quote_id: id)
        XCTAssert((quoteObj.contact_id == 1) && (quoteObj.application == "Coreytest"))
        
        //Delete the quote and assert it was deleted
        code = apiDispatcher.dispatcher.deleteQuote(id: id)
        XCTAssert(code == 200)
        
        //Delete the same quote and assert that it was not found
        code = apiDispatcher.dispatcher.deleteQuote(id: id)
        XCTAssert(code == 404)
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   testdeleteQuote                     //
    //                                              //
    //  Desc:   Creates a quote to delete. Then     //
    //          utilizes getAllQuotes to check the  //
    //          count of stored quote objects before//
    //          and after the deleteQuote function. //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testDeleteQuote()
    {
        //Create a new quote
        let test_quote = Quote.init(account_id: 99, commission: 1, quote_number: "1", multiplier: 0.73, contact_id: 1, application: "Coreytest", list_prices: true, open: true, created_date: "", updated_date: "", id: 0, lead_time: "", sell_price: 0.00, net_imperial: 0.00)
        let id = apiDispatcher.dispatcher.postNewQuote(quote: test_quote!);
        
        //Get all quotes to check the number of quotes
        var array = apiDispatcher.dispatcher.getAllQuotes(DESC: false);
        let size = array.count
        
        //delete the added test quote.
        let code = apiDispatcher.dispatcher.deleteQuote(id: id)
        XCTAssert(code == 200)
        
        //Assert it no longer exists in quotes.
        array = apiDispatcher.dispatcher.getAllQuotes(DESC: false);
        XCTAssert(array.count == size - 1)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetQuote                        //
    //                                              //
    //  Desc:   Asserts that the returned object's  //
    //          ID is equal to the requested ID     //
    //          and has a quote_number              //
    //                                              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetQuote()
    {
        var id : Int
        let test_quote = Quote.init(account_id: 99, commission: 1, quote_number: "1", multiplier: 0.73, contact_id: 1, application: "Coreytest", list_prices: true, open: true, created_date: "", updated_date: "", id: 0, lead_time: "", sell_price: 0.00, net_imperial: 0.00)
        id = apiDispatcher.dispatcher.postNewQuote(quote: test_quote!)
        
        let quote = apiDispatcher.dispatcher.getQuote(quote_id: id)
        XCTAssert(quote.quote_number == test_quote!.quote_number)
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateQuote                     //
    //                                              //
    //  Desc:   Calls getQuote after patchQuote and //
    //          asserts that the returned quote has //
    //          been changed                        //
    //                                              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateQuote()
    {
        var id : Int
        let test_quote = Quote.init(account_id: 99, commission: 1, quote_number: "1", multiplier: 0.73, contact_id: 1, application: "JaredTest", list_prices: true, open: true, created_date: "", updated_date: "", id: 0, lead_time: "", sell_price: 0.00, net_imperial: 0.00)
        id = apiDispatcher.dispatcher.postNewQuote(quote: test_quote!)
        let firstquote = apiDispatcher.dispatcher.getQuote(quote_id: id)
        firstquote.application = "NEWAPPLICATION"
        var code = apiDispatcher.dispatcher.updateQuote(quote: firstquote)
        XCTAssert(code == 201 || code == 200)
        let secondquote = apiDispatcher.dispatcher.getQuote(quote_id: id)
        XCTAssert(secondquote.application == "NEWAPPLICATION")
        secondquote.application = "JaredTest"
        code = apiDispatcher.dispatcher.updateQuote(quote: secondquote)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllQuotes                    //
    //                                              //
    //  Desc:   Assert that the quote_array returned//
    //          has data                            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllQuotes()
    {
        let quoteArray = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        XCTAssert(quoteArray.count > 0)
        for element in quoteArray{
            XCTAssert(element.id > 0)
            print(element.sell_price)
            print(element.net_imperial)
            print(element.lead_time)
            print(element.open)
            print(element.commission!)
            XCTAssert(element.application != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllQuotesForContact          //
    //                                              //
    //  Desc:   Assert that the quote_array returned//
    //          has data                            //
    //  args:                                       //
    //**********************************************//
    func testGetAllQuotesForContact()
    {
        let quoteArray = apiDispatcher.dispatcher.getAllQuotesForContact(DESC:false, contact_id: 1)
        XCTAssert(quoteArray.count > 0)
        for element in quoteArray{
            XCTAssert(element.id > 0)
            XCTAssert(element.application != "")
        }
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllQuotesFromSearch          //
    //                                              //
    //  Desc:   Assert that the quote_array returned//
    //          has data                            //
    //  args:                                       //
    //**********************************************//
    func testGetAllQuotesFromSearch()
    {
        let quoteArray = apiDispatcher.dispatcher.getAllQuotesFromSearch(DESC: false, searchText: "quote")
        XCTAssert(quoteArray.count > 0)
        for element in quoteArray{
            XCTAssert(element.id > 0)
            XCTAssert(element.application != "")
        }
    }
    
    //******************************************************* END QUOTE TEST FUNCTIONS *************************************************//
    
     //**************************************************** BEGIN USER TEST FUNCTIONS *************************************************//
    //**********************************************//
    //                                              //
    //  func:   testGetUser                         //
    //                                              //
    //  Desc:   Asserts that getUser returns valid  //
    //          data.                               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetUser()
    {
        let code = apiDispatcher.dispatcher.getUser()
        XCTAssert((code == 200) || (code == 202))
        XCTAssert(User.current_user.role! == "Admin")
        XCTAssert(User.current_user.id! == 1)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateUserEmail                 //
    //                                              //
    //  Desc:   Asserts that the user's email was   //
    //          updated.                            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateUserEmail()
    {
        var code = apiDispatcher.dispatcher.updateUserEmail(user: "test@testing.com")
        XCTAssert(code == 200)
        code = apiDispatcher.dispatcher.getUser()
        XCTAssert(code == 200)
        XCTAssert(User.current_user.email == "test@testing.com")
        code = apiDispatcher.dispatcher.submitLogin(user: "test@testing.com", pass: "test123")
        code = apiDispatcher.dispatcher.updateUserEmail(user: "admin@isystemsweb.com")
        XCTAssert(code == 200)
        code = apiDispatcher.dispatcher.getUser()
        XCTAssert(User.current_user.email == "admin@isystemsweb.com")
        code = apiDispatcher.dispatcher.submitLogin(user: "admin@isystemsweb.com", pass: "test123")
        XCTAssert(code == 200)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateUserPassword              //
    //                                              //
    //  Desc:   Asserts that the user's password was//
    //          updated.                            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateUserPassword()
    {
        var code = apiDispatcher.dispatcher.updateUserPassword(pass: "test1234")
        XCTAssert(code == 200)
        code = apiDispatcher.dispatcher.submitLogin(user: "admin@isystemsweb.com", pass: "test1234")
        XCTAssert(code == 200)
        code = apiDispatcher.dispatcher.updateUserPassword(pass: "test123")
        XCTAssert(code == 200)
        code = apiDispatcher.dispatcher.submitLogin(user: "admin@isystemsweb.com", pass: "test123")
        XCTAssert(code == 200)
    }
    
     //******************************************************* END USER TEST FUNCTIONS *************************************************//
    
     //*****************************************************BEGIN ACCOUNT TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   testPostDeleteNewAccount            //
    //                                              //
    //  Desc:   Posts a new account, utilizing      //
    //          getAllAccounts in order to track the//
    //          number of accounts before and after //
    //          posting. Then calls deleteAccount in//
    //          order to clean up the junk account. //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostDeleteNewAccount()
    {
        var accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
        XCTAssert(accountArray.count > 0)
        let originalNum = accountArray.count
        
        let accountObj = Account(name: "testAccount", state: "PA", city: "Erie", country: "United States", street_1: "test street", postal_code: "16509", fax: "7778889999", phone: "1112223333", website: "test.comnetorg")
        accountObj.street_2 = "test street 2"
        let id = apiDispatcher.dispatcher.postNewAccount(accountObj: accountObj)
        XCTAssert(id > 0)
        
        accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
        XCTAssert(accountArray.count > originalNum)
        
        for element in accountArray{
            print(element.name)
        }
        
        code = apiDispatcher.dispatcher.deleteAccount(id: id)
        XCTAssert((code == 200) || (code == 202) || (code == 204))
        
        accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
        XCTAssert(accountArray.count == originalNum)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllAccounts()                //
    //                                              //
    //  Desc:   Asserts that function does not      //
    //          return an empty list.               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllAccounts()
    {
        let accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: true)
        XCTAssert(accountArray.count > 0)
        for element in accountArray{
            XCTAssert(element.name != "")
            XCTAssert(element.id > 0)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllAccountsInGroup()         //
    //                                              //
    //  Desc:   Asserts that function does not      //
    //          return an empty list                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllAccountsInGroup()
    {
        let accountArray = apiDispatcher.dispatcher.getAllAccountsInGroup(DESC: true, group_id: 1)
        XCTAssert(accountArray.count > 0)
        for element in accountArray{
            XCTAssert(element.name != "")
            XCTAssert(element.id > 0)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAccount()                    //
    //                                              //
    //  Desc:   Asserts that getAccount does not    //
    //          return an empty account             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAccount()
    {
        let account = apiDispatcher.dispatcher.getAccount(id: 1)
        XCTAssert(account.name != "")
        XCTAssert(account.state != "")
        XCTAssert(account.city != "")
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateAccount()                 //
    //                                              //
    //  Desc:   Asserts that updateAccount adjusts  //
    //          the fax number of the selected      //
    //          and then reverts the change         //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateAccount()
    {
        //ORIGINAL FAX: (425) 882-3585
        var account = Account.init()
        var originalFax = ""
        let newFax = "(111) 222-3333"
        var name = ""
        let newName = "test_name"
        account = apiDispatcher.dispatcher.getAccount(id: 1)
        originalFax = account.fax
        name = account.name
        account.fax = newFax
        account.name = newName
        code = apiDispatcher.dispatcher.updateAccount(accountObj: account)
        XCTAssert(code == 200)
        account = apiDispatcher.dispatcher.getAccount(id: 1)
        XCTAssert(account.fax != originalFax)
        XCTAssert(account.fax == newFax)
        XCTAssert(account.name != name)
        XCTAssert(account.name == newName)
        account.fax = originalFax
        account.name = name
        code = apiDispatcher.dispatcher.updateAccount(accountObj: account)
        XCTAssert(code == 200)
        account = apiDispatcher.dispatcher.getAccount(id: 1)
        XCTAssert(account.fax != newFax)
        XCTAssert(account.fax == originalFax)
        XCTAssert(account.name != newName)
        XCTAssert(account.name == name)
    }
    
    //****************************************************** END ACCOUNT FUNCTIONS ************************************************//
    
    //***************************************************BEGIN PRODUCT TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllProductFiles()            //
    //                                              //
    //  Desc:   Asserts that getAllProductFiles does//
    //          not return an empty list.           //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllProductFiles()
    {
        let fileArray = apiDispatcher.dispatcher.getAllProductFiles(DESC: false)
        XCTAssert(fileArray.count > 0)
        for element in fileArray{
            XCTAssert(element.id > 0)
            XCTAssert(element.name != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetProductFile                  //
    //                                              //
    //  Desc:   Asserts that getProductFile         //
    //          returns the object specified by     //
    //          its ID                              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetProductFile()
    {
        let file = apiDispatcher.dispatcher.getProductFile(product_file_id: 1)
        XCTAssert(file.id == 1)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetProductMakes                 //
    //                                              //
    //  Desc:   Asserts that getAllMakes() does not //
    //          return an empty list                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetProductMakes()
    {
        let makes = apiDispatcher.dispatcher.getProductMakes()
        XCTAssert(makes.count > 0)
        for element in makes {
            XCTAssert(!element.isEmpty)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllProductBases              //
    //                                              //
    //  Desc:   Asserts that getProductBases        //
    //          returns a valid product array       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetProductBases()
    {
        let bases = apiDispatcher.dispatcher.getProductBases(DESC: false, make: "CMAXX")
        XCTAssert(bases.count > 0)
        for element in bases {
            print(element.product_id)
            XCTAssert(!element.name.isEmpty)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetProduct                      //
    //                                              //
    //  Desc:   Asserts that getProductBases        //
    //          returns a valid product array       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetProduct()
    {
        let product = apiDispatcher.dispatcher.getProduct(product_id: 200)
            print(product.product_id)
            XCTAssert(!product.name.isEmpty)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllProductAdders             //
    //                                              //
    //  Desc:   Asserts that getProductAdders       //
    //          returns a valid product array       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetProductAdders()
    {
        let bases = apiDispatcher.dispatcher.getProductBases(DESC: false, make: "Shadow")
        let adders = apiDispatcher.dispatcher.getProductAdders(DESC: false, product_id: bases[0].product_id, make: "Shadow")
        for element in adders {
            for element2 in element {
                print(element2.name)
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllProducts                  //
    //                                              //
    //  Desc:   Asserts that getAllProducts         //
    //          returns valid array of products     //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllProducts()
    {
        let product_list = apiDispatcher.dispatcher.getAllProducts(DESC: false)
        XCTAssert(product_list.count > 0)
        for element in product_list{
            XCTAssert(element.name != "")
        }
    }
    
    //*************************************************END PRODUCT TEST FUNCTIONS *************************************************//
    
    //***********************************************BEGIN CONTACT TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllContacts()                //
    //                                              //
    //  Desc:   Asserts that getAllContacts() does  //
    //          not return an empty list.           //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllContacts()
    {
        let contactArray = apiDispatcher.dispatcher.getAllContacts(DESC: false)
        XCTAssert(contactArray.count > 0)
        for element in contactArray{
            XCTAssert(element.id > 0)
            XCTAssert(element.first_name != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testPostDeleteContact               //
    //                                              //
    //  Desc:   Creates and deletes a test contact. //
    //          Assertions are made based on the    //
    //          quantity of contact entries before  //
    //          and after the POST and DELETE calls.//
    //          The physical existance of the       //
    //          contact entry is also checked after //
    //          the POST call. The DELETE function  //
    //          is called twice to assert that no   //
    //          entry was found the second time.    //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostDeleteContact()
    {
        //call getAllContacts to collect count
        var arrayContacts = apiDispatcher.dispatcher.getAllContacts(DESC: false)
        let originalCount = arrayContacts.count
        
        //Post new contact and get its id
        let contact = Contact.init(first_name: "Test", last_name: "test", email: "test@test.com", fax: "724535", phone: "724532", title: "tite", notes: "note", id: 1, account_id: 1, created: "", updated: "")
        let id = apiDispatcher.dispatcher.postNewContact(contactObj: contact)
        
        //get new count and assert it is greater than old count
        arrayContacts = apiDispatcher.dispatcher.getAllContacts(DESC: false)
        XCTAssert((arrayContacts.count > originalCount))
        
        //Check that the test contact exists
        let contactObj = apiDispatcher.dispatcher.getContact(id: id)
        XCTAssert((contactObj.first_name == "Test") && (contactObj.email == "test@test.com"))
        
        //Delete the contact
        var code = apiDispatcher.dispatcher.deleteContact(id: id)
        XCTAssert(code == 200)
        
        //Get new count and assert that it is the same as the original
        arrayContacts = apiDispatcher.dispatcher.getAllContacts(DESC: false)
        XCTAssert(arrayContacts.count == originalCount)
        
        //Try to delete again
        code = apiDispatcher.dispatcher.deleteContact(id: id)
        XCTAssert(code == 404)
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetContact                      //
    //                                              //
    //  Desc:   Asserts that getContact returns     //
    //          object with same id as requested    //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetContact()
    {
        let contact = apiDispatcher.dispatcher.getContact(id: 1)
        XCTAssert(contact.account_id == 1)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateContact                   //
    //                                              //
    //  Desc:   Asserts that UpdateContact          //
    //          returns succesful response          //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateContact()
    {
        var contact = apiDispatcher.dispatcher.getContact(id: 1)
        contact.first_name = "fname"
        let code = apiDispatcher.dispatcher.updateContact(contactObj: contact)
        XCTAssert(code == 200)
        contact = apiDispatcher.dispatcher.getContact(id: 1)
        XCTAssert(contact.first_name == "fname")
    }
    
    //*********************************************END CONTACT TEST FUNCTIONS *************************************************//
    
    //********************************************BEGIN BUNDLE TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllBundles                   //
    //                                              //
    //  Desc:   Asserts that getAllBundles          //
    //          returns successfully                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllBundles()
    {
        let bundle_list = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        XCTAssert(bundle_list.count > 0)
        for element in bundle_list{
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetBundlesForQuotes             //
    //                                              //
    //  Desc:   Asserts that getBundlesForQuotes    //
    //          returns successfully                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetBundlesForQuotes()
    {
        let quote_list = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        
        let bundle_list = apiDispatcher.dispatcher.getBundlesForQuote(DESC: false, id: quote_list[0].id)
        XCTAssert(bundle_list.count > 0)
        
        let bundle_list2 = apiDispatcher.dispatcher.getBundlesForQuote(DESC: false, id: quote_list[1].id)
        XCTAssert(bundle_list.count > 0)
        
        if (bundle_list.count == bundle_list2.count){
            
            for element in bundle_list{
                for element2 in bundle_list2{
                    XCTAssert(element.id > 0 && element.name != "")
                    XCTAssert(element2.id > 0 && element2.name != "")
                    XCTAssert(element.id != element2.id)
                }
            }
        } else {
            XCTAssert(true)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testPostDeleteBundle                //
    //                                              //
    //  Desc:   Creates and deletes a test bundle.  //
    //          Assertions are made based on the    //
    //          quantity of bundle entries before   //
    //          and after the POST and DELETE calls.//
    //          The physical existance of the       //
    //          bundle entry is also checked after  //
    //          the POST call. The DELETE function  //
    //          is called twice to assert that no   //
    //          entry was found the second time.    //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostDeleteBundles()
    {
        //call getAllContacts to collect count
        var arrayBundles = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        let originalCount = arrayBundles.count
        
        //Get quote objects to use
        let quote_list = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        let quote = quote_list[0];
        
        //Post new bundle and get its id
        let bundle = Bundle.init(name: "Testing", quote_id: quote.id, option: false, quote_position: 2)
        let id = apiDispatcher.dispatcher.postNewBundle(bundleObj: bundle)
        
        //get new count and assert it is greater than old count
        arrayBundles = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        XCTAssert(arrayBundles.count > originalCount)
        
        //Check that the test bundle exists
        print(id)
        let bundleObj = apiDispatcher.dispatcher.getBundle(id: id)
        XCTAssert(bundleObj.name == "Testing")
        
        //Delete the bundle
        var code = apiDispatcher.dispatcher.deleteBundle(id: id)
        XCTAssert(code == 200)
        
        //Get new count and assert that it is the same as the original
        arrayBundles = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        XCTAssert(arrayBundles.count == originalCount)
        
        //Try to delete again
        code = apiDispatcher.dispatcher.deleteBundle(id: id)
        XCTAssert(code == 404)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateBundle                    //
    //                                              //
    //  Desc:   Creates a bundle to adjust. Asserts //
    //          that the bundle is adjusted. Then   //
    //          deletes the bundle.                 //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateBundles()
    {
        //Get a quote object to post a bundle to
        let quote_list = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        let quote = quote_list[1]
        
        //Post new bundle and get its id
        let bundle = Bundle.init(name: "QuoteTestUpdate", quote_id: quote.id, option: false, quote_position: 7)
        let id = apiDispatcher.dispatcher.postNewBundle(bundleObj: bundle)
        bundle.id = id
        var code = 0
        
        //Give bundle a new name and update
        bundle.quote_position = 3
        code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundle)
        
        //Get bundle and assert that the name was changed
        var gotBundle = apiDispatcher.dispatcher.getBundle(id: id)
        XCTAssert(gotBundle.quote_position == 3)
        
        //Give bundle old name and update
        bundle.quote_position = 2
        code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundle)
        
        //Get bundle and assert that the name is back to normal
        gotBundle = apiDispatcher.dispatcher.getBundle(id: id)
        XCTAssert(gotBundle.quote_position == 2)
        
        //Delete the bundle
        code = apiDispatcher.dispatcher.deleteBundle(id: id)
        XCTAssert(code == 200)
    }
    
    //**************************************************END BUNDLE TEST FUNCTIONS *************************************************//
    
    //***********************************************BEGIN QUOTEITEMS TEST FUNCTIONS *************************************************//
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllQuoteItems                //
    //                                              //
    //  Desc:   Asserts that getAllQuoteItems       //
    //          returns quote_items                 //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllQuoteItems()
    {
        let quote_items = apiDispatcher.dispatcher.getAllQuoteItems(DESC: false)
        XCTAssert(quote_items.count > 0)
        for element in quote_items{
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetQuoteItem                    //
    //                                              //
    //  Desc:   Asserts that getQuoteItem           //
    //          returns a valid quote               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetQuoteItem()
    {
        let quote_items = apiDispatcher.dispatcher.getAllQuoteItems(DESC: false)
        
        let quote_item = apiDispatcher.dispatcher.getQuoteItem(quote_item_id: quote_items[0].id)
        XCTAssert(quote_item.id == quote_items[0].id)
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   testPostNewQuoteItem                //
    //                                              //
    //  Desc:   Asserts that postNewQuoteItem       //
    //          returns a valid new ID              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostNewQuoteItem()
    {
        let bundles_list = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        
        var quote_item = QuoteItem.init(id: 0, quantity: 12, bundle_id: bundles_list[0].id, model: "test", price: 0.45, option: false, bundle_position: 2, product_id: 1, active: true, category: "test", description: "test", digest_id: "test", image: "img", lead_time: 1, make: "test", name: "name", sku: "sku", updated_at: "", created_at: "")
        let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
        quote_item = apiDispatcher.dispatcher.getQuoteItem(quote_item_id: quote_item_id)
        XCTAssert(quote_item_id > 0)
        XCTAssert(quote_item.quantity == 12)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateQuoteItem                 //
    //                                              //
    //  Desc:   Asserts that UpdateQuoteItem        //
    //          has updated a certain quote item    //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateQuoteItem()
    {
        //Get a quoteItem to update
        let quote_items = apiDispatcher.dispatcher.getAllQuoteItems(DESC: false)
        
        var quote_item = apiDispatcher.dispatcher.getQuoteItem(quote_item_id: quote_items[0].id)
        quote_item.price = 200.00
        var code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: quote_item)
        XCTAssert(code == 200)
        quote_item = apiDispatcher.dispatcher.getQuoteItem(quote_item_id: quote_items[0].id)
        XCTAssert(quote_item.price == 200.00)
        quote_item.price = 250.00
        code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: quote_item)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testdeleteQuoteItem                 //
    //                                              //
    //  Desc:   Creates a quote_item to delete. Then//
    //          utilizes getAllQuote_items to check //
    //          count of stored quote objects before//
    //          and after the deleteQuote function. //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testdeleteQuoteItem()
    {
        //Get a bundle for use for posting
        let bundles_list = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        
        //Create a new quote_item
        let quote_item = QuoteItem.init(id: 0, quantity: 12, bundle_id: bundles_list[0].id, model: "test", price: 0.45, option: false, bundle_position: 2, product_id: 1, active: true, category: "test", description: "test", digest_id: "test", image: "img", lead_time: 1, make: "test", name: "name", sku: "sku", updated_at: "", created_at: "")
        let id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
        
        //Get all quotes to check the number of quotes
        var array = apiDispatcher.dispatcher.getAllQuoteItems(DESC: false);
        let size = array.count
        
        //delete the added test quote.
        let code = apiDispatcher.dispatcher.deleteQuoteItem(id: id)
        XCTAssert(code == 200)
        
        //Assert it no longer exists in quotes.
        array = apiDispatcher.dispatcher.getAllQuoteItems(DESC: false);
        XCTAssert(array.count == size - 1)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetQuoteItemsInBundle           //
    //                                              //
    //  Desc:   Asserts the array returned is valid //
    //          and not empty                       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllQuoteItemsInBundle()
    {
        let bundles_list = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        
        let quote_itemArray = apiDispatcher.dispatcher.getAllQuoteItemsInBundle(DESC: false, bundle_id: bundles_list[0].id)
        XCTAssert(quote_itemArray.count > 0)
        for element in quote_itemArray{
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    //***********************************************END QUOTEITEMS TEST FUNCTIONS *************************************************//
    
    //************************************************** BEGIN TAG TEST FUNCTIONS *************************************************//
    
    //*********************************************//
    //  func:   testGetAllTags                      //
    //                                              //
    //  Desc:   Asserts that getAllTags             //
    //          returns a valid tag list            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllTags()
    {
        let tagArray = apiDispatcher.dispatcher.getAllTags(DESC: false)
        XCTAssert(tagArray.count > 0)
        for element in tagArray {
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   testPostNewTag                      //
    //                                              //
    //  Desc:   Asserts that new tag posted         //
    //          succussfully                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testPostNewTag()
    {
        let tag = Tag.init(id: 0, name: "test12j3", category: "test", value: "test2", taggable_type: "Product", taggable_id: 1, updatedDate: "", createdDate: "")
        let id = apiDispatcher.dispatcher.postNewTag(tagObj: tag)
        print(id)
        XCTAssert(id > 0)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testUpdateTag                       //
    //                                              //
    //  Desc:   Asserts that a tag with specified   //
    //          id updated successfully             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testUpdateTag()
    {
        let tag = Tag.init(id: 5, name: "test123", category: "test", value: "test", taggable_type: "Product", taggable_id: 1, updatedDate: "", createdDate: "")
        tag.name = "test1234"
        
        let code = apiDispatcher.dispatcher.updateTag(tagObj: tag)
        XCTAssert(code == 200)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testDeleteTag                       //
    //                                              //
    //  Desc:   Asserts that a tag with specified   //
    //          id deleted                          //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testDeleteTag()
    {
        let tag_list = apiDispatcher.dispatcher.getTagsForProduct(DESC: false, product_id: 10)
        
        let code = apiDispatcher.dispatcher.deleteTag(id: tag_list[0].id)
        XCTAssert(code == 200)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetAllTagsInBundle              //
    //                                              //
    //  Desc:   Asserts that getAllTagsInBundle     //
    //          returns a valid tag list            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllTagsInBundle()
    {
        let bundles_list = apiDispatcher.dispatcher.getAllBundles(DESC: false)
        
        let tagArray = apiDispatcher.dispatcher.getAllTagsInBundle(bundle_id: bundles_list[1].id, DESC: false)
        for element in tagArray {
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testGetTagsForProduct               //
    //                                              //
    //  Desc:   Asserts that getTagsFor Product     //
    //          returns valid tag array             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testGetAllTagsForProduct()
    {
        let tagArray = apiDispatcher.dispatcher.getTagsForProduct(DESC: false, product_id: 10)
        XCTAssert(tagArray.count != 0)
        for element in tagArray {
            XCTAssert(element.id > 0 && element.name != "")
        }
    }
    
    func testConsole(){

    }
        
}

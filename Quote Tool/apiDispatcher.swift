//******************************************************//
//          Imperial Systems Inc.                       //
//******************************************************//
//                                                      //
//  Filename:   apiDispatcher.swift                     //
//                                                      //
//  Desc:       This class is to be primarily           //
//              used to communicate with the            //
//              backend                                 //
//                                                      //
//  Creation:   16Nov19                                 //
//                                                      //
//  Last Commit & Push:                                 //
//******************************************************//
//  JWM 16Nov19 Created Initial File                    //
//  CJF/JWM 21Nov19 Added Login Functionality           //
//  JWM 25Nov19 Added function headers, function        //
//              returns, func extendLogin, and          //
//              func logout.                            //
//  CJF 25Nov19 Added updateUser Functionality          //
//  JWM 01Dec19 Added func getUser skeleton             //
//  CJF 01Dec19 Added getAllProductFiles func           //
//  CJF 02Dec19 Added getUser, extendLogin, getallQuotes//
//  JWM 21Jan20 Finalized all Account functions         //
//******************************************************//
import Foundation


public class apiDispatcher {
    
    //singleton for memory conservation
    static let dispatcher = apiDispatcher()
    private init(){
        
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   submitLogin                         //
    //                                              //
    //  Desc:   Passes the user-submitted fields of //
    //          'username' and 'password' to the API//
    //          and will recieve a JWT if the user  //
    //          is successfully authenticated. The  //
    //          function will return "" in the case //
    //          of authentication failure.          //
    //                                              //
    //  args:   user - string 'username'            //
    //          pass - string 'password'            //
    //**********************************************//
    
    func submitLogin(user : String, pass : String) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        
        //Create json to pass to httprequest with username and password
        let json  = [
            "meta": [
                "authentication": [
                    "email": "\(user)",
                    "password": "\(pass)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/auth/login")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("Login HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        //Inside first array of data's array inside an array
                        let element = data[0]
                        //Get inside the array of attributes
                        if let attrib = element["attributes"] as? [String:AnyObject]{
                            //At jwt to store into user
                            User.current_user.jwt = (attrib["value"] as! String)
                            
                        }
                        //Inside second array of data's array inside an array
                        let secondportion = data[1]
                        //Get user_id and assign it to user
                        User.current_user.id = (secondportion["user_id"] as! Int)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   extendLogin                         //
    //                                              //
    //  Desc:   Passes the user-held JWT to the API.//
    //          The API will use it to authenticate //
    //          the user. Upon a successful         //
    //          authentication extendLogin will     //
    //          return the JWT string. Upon a       //
    //          failure extendLogin will return ""  //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func extendLogin() -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var code : Int = 0
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/auth/extend_login")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("Extend Login HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        //Inside first array of data's array inside an array
                        let element = data[0]
                        //Get inside the array of attributes
                        if let attrib = element["attributes"] as? [String:AnyObject]{
                            //At jwt to store into user
                            User.current_user.jwt = (attrib["value"] as! String)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code
    }
    
    //******************************************************** END LOGIN FUNCTIONS ***********************************************************//
    
    
    
    
    
    //**********************************************//
    //                                              //
    //  func:   getUser                             //
    //                                              //
    //  Desc:   Gets the current user from the API  //
    //          using the currently held JWT.       //
    //          Returns an integer 'code' to        //
    //          indicate the action outcome.        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func getUser() -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var code : Int = 0
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/users/\(User.current_user.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetUser HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        //See other functions as data[0] should only be used when there is for sure only one json data respone
                        let element = data[0]
                        //set the current users data
                        User.current_user.id = (element["id"] as! Int)
                        User.current_user.group_id = (element["group_id"] as! Int)
                        User.current_user.email = (element["email"] as! String)
                        if let role_id = (element["role_id"] as? Int) {
                            if role_id == 1 {
                                User.current_user.role = "User"
                            }
                            else if role_id == 2{
                                User.current_user.role = "Moderator"
                            }
                            else if role_id == 3{
                                User.current_user.role = "Admin"
                            }
                            else {
                                User.current_user.role = "Test Account"
                            }
                        }
                        else{
                            User.current_user.role = "Unknown"
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   updateUserEmail                     //
    //                                              //
    //  Desc:   Passes the user-submitted fields of //
    //          'username' to the api to be updated //
    //          does not currently support          //
    //          change of password due to api       //
    //                                              //
    //  args:   user - string 'new username'        //
    //**********************************************//
    
    func updateUserEmail(user: String) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "user": [
                    "email": "\(user)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/users/\(User.current_user.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("Change email HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            }catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   updateUserPassword                  //
    //                                              //
    //  Desc:   Passes the user-submitted fields of //
    //          'password' to the api to be updated //
    //                                              //
    //  args:   user - string 'new username'        //
    //**********************************************//
    func updateUserPassword(pass : String) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        
        let json  = [
            "data": [
                "user": [
                    "email": "\(User.current_user.email!)",
                    "password" : "\(pass)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/users/\(User.current_user.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("Change email HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            }catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    ///******************************************************** END USER FUNCTIONS ***********************************************************//
    
    ///******************************************************BEGIN PRODUCT FUNCTIONS********************************************************//
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllProductFiles                  //
    //                                              //
    //  Desc:   Makes call to get all product       //
    //          files and returns them as an        //
    //          ArrayList of type ProductFile       //
    //                                              //
    //  args:   user - string 'new username'        //
    //**********************************************//
    
    func getAllProductFiles(DESC: Bool) -> [ProductFile] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var fileArray = [ProductFile]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/product_files")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllProductFiles HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let product_file = ProductFile.init()
                            if let id = (element["id"] as? Int){
                                product_file.id = id
                            }
                            if let description = (element["description"] as? String){
                                product_file.description = description
                            }
                            if let active = (element["active"] as? Bool){
                                product_file.active = active
                            }
                            if let created_at = (element["created_at"] as? String){
                                product_file.modified_date.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                product_file.modified_date.updated_at = updated_at
                            }
                            if let document = element["document"] as? [String:AnyObject]{
                                if let document_url = (document["url"] as? String){
                                    product_file.document_url = document_url
                                }
                                if let name = (document["name"] as? String){
                                    product_file.name = name
                                }
                                if let preview = document["preview"] as? [String:AnyObject]{
                                    if let preview_url = (preview["url"] as? String){
                                        product_file.preview_url = preview_url
                                    }
                                }
                                if let thumbnail = document["thumbnail"] as? [String:AnyObject]{
                                    if let thumbnail_url = (thumbnail["url"] as? String){
                                        product_file.thumbnail_url = thumbnail_url
                                    }
                                }
                            }
                            if let language = (element["language"] as? String){
                                product_file.language = language
                            }
                            
                            if let family = (element["family"] as? String){
                                product_file.family = family
                            }
                            if let document_type = (element["document_type"] as? String){
                                product_file.document_type = document_type
                            }
                            fileArray.append(product_file)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return fileArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getProductFile                      //
    //                                              //
    //  Desc:   Makes call to get the ProductFile   //
    //          with the specified ID               //
    //                                              //
    //  args:   user - string 'new username'        //
    //**********************************************//
    
    func getProductFile(product_file_id : Int) -> ProductFile {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let product_file = ProductFile.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/product_files/\(product_file_id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetProductFile HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            if let id = (element["id"] as? Int){
                                product_file.id = id
                            }
                            if let description = (element["description"] as? String){
                                product_file.description = description
                            }
                            if let active = (element["active"] as? Bool){
                                product_file.active = active
                            }
                            if let created_at = (element["created_at"] as? String){
                                product_file.modified_date.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                product_file.modified_date.updated_at = updated_at
                            }
                            if let document = element["document"] as? [String:AnyObject]{
                                if let document_url = (document["url"] as? String){
                                    product_file.document_url = document_url
                                }
                                if let name = (document["name"] as? String){
                                    product_file.name = name
                                }
                                if let preview = document["preview"] as? [String:AnyObject]{
                                    if let preview_url = (preview["url"] as? String){
                                        product_file.preview_url = preview_url
                                    }
                                }
                                if let thumbnail = document["thumbnail"] as? [String:AnyObject]{
                                    if let thumbnail_url = (thumbnail["url"] as? String){
                                        product_file.thumbnail_url = thumbnail_url
                                    }
                                }
                            }
                            if let language = (element["language"] as? String){
                                product_file.language = language
                            }
                            
                            if let family = (element["family"] as? String){
                                product_file.family = family
                            }
                            if let document_type = (element["document_type"] as? String){
                                product_file.document_type = document_type
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return product_file
    }
    
    //******************************************************** END PRODUCT_FILE FUNCTIONS ***********************************************************//
    
    
    
    
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllQuotes                        //
    //                                              //
    //  Desc:   Gets all the quotes for the         //
    //          current user                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllQuotes(DESC : Bool) -> [Quote] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var quoteArray = [Quote]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllQuotes HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        for element in data {
                            print(element)
                            let quoteObj = Quote.init()
                            if let id = (element["id"] as? Int){
                                quoteObj.id = id
                            }
                            if let account = (element["account"] as? String){
                                if let account_num = Int.init(account){
                                    quoteObj.account_id = account_num
                                }
                            }
                            if let created_at = (element["created_at"] as? String){
                                quoteObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                quoteObj.modified_dates.updated_at = updated_at
                            }
                            if let temp_multiplier = (element["multiplier"] as? String){
                                let multiplier = Double(temp_multiplier)!
                                quoteObj.multiplier = multiplier
                            }
                            if let application = (element["application"] as? String){
                                quoteObj.application = application
                            }
                            if let quote_number = (element["quote_number"] as? String){
                                quoteObj.quote_number = quote_number
                            }
                            if let list_prices = (element["list_prices"] as? Int){
                                if list_prices == 0 {
                                    quoteObj.list_prices = false
                                }
                                else{
                                    quoteObj.list_prices = true
                                }
                            }
                            if let contact_id = (element["contact_id"] as? Int){
                                quoteObj.contact_id = contact_id
                            }
                            if let temp_commission = (element["commission"] as? String){
                                if let commission = Double(temp_commission){
                                    quoteObj.commission = commission
                                }
                            }
                            if let open = (element["open"] as? Int){
                                if open == 0 {
                                    quoteObj.open = false
                                }
                                else{
                                    quoteObj.open = true
                                }
                            }
                            if let lead_time = (element["lead_time"] as? String){
                                quoteObj.lead_time = lead_time
                            }
                            if let sell_price = (element["sell_price"] as? Double){
                                quoteObj.sell_price = sell_price
                            }
                            if let net_imperial = (element["net_imperial"] as? Double){
                                quoteObj.net_imperial = net_imperial
                            }
                            quoteArray.append(quoteObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quoteArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllQuotesForContact              //
    //                                              //
    //  Desc:   Gets all the quotes for a           //
    //          certain contact                     //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllQuotesForContact(DESC : Bool, contact_id: Int) -> [Quote] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var quoteArray = [Quote]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts/\(contact_id)/quotes")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllQuotesForContact, Contact #\(contact_id) HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        for element in data {
                            let user_id = (element["user_id"] as! Int)
                            if(user_id == User.current_user.id) {
                                print(element)
                                let quoteObj = Quote.init()
                                if let id = (element["id"] as? Int){
                                    quoteObj.id = id
                                }
                                if let account = (element["account"] as? String){
                                    if let account_num = Int.init(account){
                                        quoteObj.account_id = account_num
                                    }
                                }
                                if let created_at = (element["created_at"] as? String){
                                    quoteObj.modified_dates.created_at = created_at
                                }
                                if let updated_at = (element["updated_at"] as? String){
                                    quoteObj.modified_dates.updated_at = updated_at
                                }
                                if let temp_multiplier = (element["multiplier"] as? String){
                                    let multiplier = Double(temp_multiplier)!
                                    quoteObj.multiplier = multiplier
                                }
                                if let application = (element["application"] as? String){
                                    quoteObj.application = application
                                }
                                if let quote_number = (element["quote_number"] as? String){
                                    quoteObj.quote_number = quote_number
                                }
                                if let list_prices = (element["list_prices"] as? Int){
                                    if list_prices == 0 {
                                        quoteObj.list_prices = false
                                    }
                                    else{
                                        quoteObj.list_prices = true
                                    }
                                }
                                if let contact_id = (element["contact_id"] as? Int){
                                    quoteObj.contact_id = contact_id
                                }
                                if let temp_commission = (element["commission"] as? String){
                                    let commission = Double(temp_commission)!
                                    quoteObj.commission = commission
                                }
                                if let open = (element["open"] as? Int){
                                    if open == 0 {
                                        quoteObj.open = false
                                    }
                                    else{
                                        quoteObj.open = true
                                    }
                                }
                                if let lead_time = (element["lead_time"] as? String){
                                    quoteObj.lead_time = lead_time
                                }
                                if let sell_price = (element["sell_price"] as? Double){
                                    quoteObj.sell_price = sell_price
                                }
                                if let net_imperial = (element["net_imperial"] as? Double){
                                    quoteObj.net_imperial = net_imperial
                                }
                                quoteArray.append(quoteObj)
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quoteArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getQuote                            //
    //                                              //
    //  Desc:   gets the specified quote            //
    //           from the API                       //
    //                                              //
    //  args:   quote_id                            //
    //**********************************************//
    
    func getQuote(quote_id : Int) -> Quote {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let quoteObj = Quote.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes/\(quote_id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetQuote HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        let element = data[0]
                        let user_id = (element["user_id"] as! Int)
                        //WILL BE CHANGED ON BACK END TO NOT NEED THIS LATER ON
                        if(user_id == User.current_user.id) {
                            if let id = (element["id"] as? Int){
                                quoteObj.id = id
                            }
                            if let account = (element["account"] as? String){
                                if let account_num = Int.init(account){
                                    quoteObj.account_id = account_num
                                }
                            }
                            if let created_at = (element["created_at"] as? String){
                                quoteObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                quoteObj.modified_dates.updated_at = updated_at
                            }
                            if let temp_multiplier = (element["multiplier"] as? String){
                                let multiplier = Double(temp_multiplier)!
                                quoteObj.multiplier = multiplier
                            }
                            if let application = (element["application"] as? String){
                                quoteObj.application = application
                            }
                            if let quote_number = (element["quote_number"] as? String){
                                quoteObj.quote_number = quote_number
                            }
                            if let list_prices = (element["list_prices"] as? Int){
                                if list_prices == 0 {
                                    quoteObj.list_prices = false
                                }
                                else{
                                    quoteObj.list_prices = true
                                }
                            }
                            if let contact_id = (element["contact_id"] as? Int){
                                quoteObj.contact_id = contact_id
                            }
                            if let temp_commission = (element["commission"] as? String){
                                let commission = Double(temp_commission)!
                                quoteObj.commission = commission
                            }
                            if let open = (element["open"] as? Int){
                                if open == 0 {
                                    quoteObj.open = false
                                }
                                else{
                                    quoteObj.open = true
                                }
                            }
                            if let lead_time = (element["lead_time"] as? String){
                                quoteObj.lead_time = lead_time
                            }
                            if let sell_price = (element["sell_price"] as? Double){
                                quoteObj.sell_price = sell_price
                            }
                            if let net_imperial = (element["net_imperial"] as? Double){
                                quoteObj.net_imperial = net_imperial
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quoteObj
    }
    
    //**********************************************//
    //                                              //
    //  func:   postNewQuote                        //
    //                                              //
    //  Desc:   Gets all the quotes for the         //
    //          current user                        //
    //                                              //
    //  args: quote                                 //
    //**********************************************//
    func postNewQuote(quote : Quote) -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var id : Int = 0
        let json  = [
            "data": [
                "quote": [
                    "account": "\(quote.account_id)",
                    "user_id": "\(User.current_user.id!)",
                    "contact_id": "\(quote.contact_id!)",
                    "application": "\(quote.application)",
                    "quote_number": "\(quote.quote_number!)",
                    "list_prices": "\(quote.ListPricesToInt())",
                    "multiplier": "\(quote.multiplier!)",
                    "commission": "\(quote.commission!)",
                    "open": "\(quote.OpenToInt())"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com//quotes")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("createQuote HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            }catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   updateQuote                         //
    //                                              //
    //  Desc:   updates specified quote             //
    //                                              //
    //  args:   fax - The new fax number to update  //
    //          id - Id of the account to adjust    //
    //**********************************************//
    func updateQuote(quote : Quote) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data":[
                "quote" :[
                    "quote_number":"\(quote.quote_number!)",
                    "contact_id":"\(quote.contact_id!)",
                    "multiplier":"\(quote.multiplier!)",
                    "commission":"\(quote.commission!)",
                    "account":"\(quote.account_id)",
                    "application":"\(quote.application)",
                    "list_prices":"\(quote.ListPricesToInt())",
                    "open": "\(quote.OpenToInt())"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes/\(quote.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateQuote HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    
    
    //**********************************************//
    //                                              //
    //  func:   deleteQuote                         //
    //                                              //
    //  Desc:   deletes specified quote             //
    //                                              //
    //  args:   id of quote                         //
    //**********************************************//
    func deleteQuote(id : Int) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteQuote HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllQuotesFromSearch              //
    //                                              //
    //  Desc:   Gets all the quotes for a           //
    //          certain search                      //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllQuotesFromSearch(DESC : Bool, searchText: String) -> [Quote] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var quoteArray = [Quote]()
        
        let json  = [
            "data":[
                "search": "\(searchText)"
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes/search")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        // insert body to the request
        request.httpBody = body
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllQuotesFromSearch HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        for element in data {
                            let user_id = (element["user_id"] as! Int)
                            if(user_id == User.current_user.id) {
                                print(element)
                                let quoteObj = Quote.init()
                                if let id = (element["id"] as? Int){
                                    quoteObj.id = id
                                }
                                if let account = (element["account"] as? String){
                                    if let account_num = Int.init(account){
                                        quoteObj.account_id = account_num
                                    }
                                }
                                if let created_at = (element["created_at"] as? String){
                                    quoteObj.modified_dates.created_at = created_at
                                }
                                if let updated_at = (element["updated_at"] as? String){
                                    quoteObj.modified_dates.updated_at = updated_at
                                }
                                if let temp_multiplier = (element["multiplier"] as? String){
                                    let multiplier = Double(temp_multiplier)!
                                    quoteObj.multiplier = multiplier
                                }
                                if let application = (element["application"] as? String){
                                    quoteObj.application = application
                                }
                                if let quote_number = (element["quote_number"] as? String){
                                    quoteObj.quote_number = quote_number
                                }
                                if let list_prices = (element["list_prices"] as? Int){
                                    if list_prices == 0 {
                                        quoteObj.list_prices = false
                                    }
                                    else{
                                        quoteObj.list_prices = true
                                    }
                                }
                                if let contact_id = (element["contact_id"] as? Int){
                                    quoteObj.contact_id = contact_id
                                }
                                if let temp_commission = (element["commission"] as? String){
                                    let commission = Double(temp_commission)!
                                    quoteObj.commission = commission
                                }
                                if let open = (element["open"] as? Int){
                                    if open == 0 {
                                        quoteObj.open = false
                                    }
                                    else{
                                        quoteObj.open = true
                                    }
                                }
                                if let lead_time = (element["lead_time"] as? String){
                                    quoteObj.lead_time = lead_time
                                }
                                if let sell_price = (element["sell_price"] as? Double){
                                    quoteObj.sell_price = sell_price
                                }
                                if let net_imperial = (element["net_imperial"] as? Double){
                                    quoteObj.net_imperial = net_imperial
                                }
                                quoteArray.append(quoteObj)
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quoteArray
    }
    
    
    //******************************************************** END QUOTE FUNCTIONS ***********************************************************//
    
    
    
    
    
    //**********************************************//
    //                                              //
    //  func:   postNewAccount                      //
    //                                              //
    //  Desc:   Posts new company account under the //
    //          current user                        //
    //                                              //
    //  args:   accountObj - new account object to  //
    //                       post                   //
    //**********************************************//
    func postNewAccount(accountObj: Account) -> Int {
        var id: Int = 0
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "account": [
                    "name": "\(accountObj.name)",
                    "street_1": "\(accountObj.street_1)",
                    "street_2": "\(accountObj.street_2)",
                    "city": "\(accountObj.city)",
                    "state": "\(accountObj.state)",
                    "country": "\(accountObj.country)",
                    "postal_code": "\(accountObj.postal_code)",
                    "phone": "\(accountObj.phone)",
                    "fax": "\(accountObj.fax)",
                    "website": "\(accountObj.website)",
                    "group_id": "\(accountObj.group_id)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("postNewAccount HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   getAllAccounts                      //
    //                                              //
    //  Desc:   Gets all the accounts for the       //
    //          current user                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllAccounts(DESC: Bool) -> [Account] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var accountArray = [Account]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts")!
        print(link)
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllAccounts HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let accountObj = Account.init()
                            if let id = (element["id"] as? Int){
                                accountObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                accountObj.name = name
                            }
                            if let street_1 = (element["street_1"] as? String){
                                accountObj.street_1 = street_1
                            }
                            if let street_2 = (element["street_2"] as? String){
                                accountObj.street_2 = street_2
                            }
                            if let city = (element["city"] as? String){
                                accountObj.city = city
                            }
                            if let state = (element["state"] as? String){
                                accountObj.state = state
                            }
                            if let country = (element["country"] as? String){
                                accountObj.country = country
                            }
                            if let postal_code = (element["postal_code"] as? String){
                                accountObj.postal_code = postal_code
                            }
                            if let phone = (element["phone"] as? String){
                                accountObj.phone = phone
                            }
                            if let created_at = (element["created_at"] as? String){
                                accountObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["created_at"] as? String){
                                accountObj.modified_dates.updated_at = updated_at
                            }
                            if let fax = (element["fax"] as? String){
                                accountObj.fax = fax
                            }
                            if let website = (element["website"] as? String){
                                accountObj.website = website
                            }
                            if let group_id = (element["group_id"] as? Int){
                                accountObj.group_id = group_id
                            }
                            accountArray.append(accountObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return accountArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   getAllAccountsInGroup               //
    //                                              //
    //  Desc:   Gets all the accounts for the       //
    //          current user                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllAccountsInGroup(DESC: Bool, group_id: Int) -> [Account] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var accountArray = [Account]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/groups/\(group_id)/accounts")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllAccountsInGroup, Group #\(group_id), HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let accountObj = Account.init()
                            if let id = (element["id"] as? Int){
                                accountObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                accountObj.name = name
                            }
                            if let street_1 = (element["street_1"] as? String){
                                accountObj.street_1 = street_1
                            }
                            if let street_2 = (element["street_2"] as? String){
                                accountObj.street_2 = street_2
                            }
                            if let city = (element["city"] as? String){
                                accountObj.city = city
                            }
                            if let state = (element["state"] as? String){
                                accountObj.state = state
                            }
                            if let country = (element["country"] as? String){
                                accountObj.country = country
                            }
                            if let postal_code = (element["postal_code"] as? String){
                                accountObj.postal_code = postal_code
                            }
                            if let phone = (element["phone"] as? String){
                                accountObj.phone = phone
                            }
                            if let created_at = (element["created_at"] as? String){
                                accountObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["created_at"] as? String){
                                accountObj.modified_dates.updated_at = updated_at
                            }
                            if let fax = (element["fax"] as? String){
                                accountObj.fax = fax
                            }
                            if let website = (element["website"] as? String){
                                accountObj.website = website
                            }
                            if let group_id = (element["group_id"] as? Int){
                                accountObj.group_id = group_id
                            }
                            accountArray.append(accountObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return accountArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   getAccount                          //
    //                                              //
    //  Desc:   Gets specified account for the      //
    //          current user                        //
    //                                              //
    //  args:   id - int representing desired       //
    //               desired account                 //
    //**********************************************//
    func getAccount(id: Int) -> Account {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let accountObj = Account.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("getAccount HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        let element = data[0]
                        if let id = (element["id"] as? Int){
                            accountObj.id = id
                        }
                        if let name = (element["name"] as? String){
                            accountObj.name = name
                        }
                        if let street_1 = (element["street_1"] as? String){
                            accountObj.street_1 = street_1
                        }
                        if let street_2 = (element["street_2"] as? String){
                            accountObj.street_2 = street_2
                        }
                        if let city = (element["city"] as? String){
                            accountObj.city = city
                        }
                        if let state = (element["state"] as? String){
                            accountObj.state = state
                        }
                        if let country = (element["country"] as? String){
                            accountObj.country = country
                        }
                        if let postal_code = (element["postal_code"] as? String){
                            accountObj.postal_code = postal_code
                        }
                        if let phone = (element["phone"] as? String){
                            accountObj.phone = phone
                        }
                        if let created_at = (element["created_at"] as? String){
                            accountObj.modified_dates.created_at = created_at
                        }
                        if let updated_at = (element["updated_at"] as? String){
                            accountObj.modified_dates.updated_at = updated_at
                        }
                        if let fax = (element["fax"] as? String){
                            accountObj.fax = fax
                        }
                        if let website = (element["website"] as? String){
                            accountObj.website = website
                        }
                        if let group_id = (element["group_id"] as? Int){
                            accountObj.group_id = group_id
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return accountObj
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteAccount                       //
    //                                              //
    //  Desc:   Deletes specified account for the   //
    //          current user                        //
    //                                              //
    //  args:   id - int representing desired       //
    //               desired account                 //
    //**********************************************//
    func deleteAccount(id: Int) -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var code: Int = 0
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteAccount HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code
    }
    
    //**********************************************//
    //                                              //
    //  func:   updateAccount                       //
    //                                              //
    //  Desc:   updates specified company account   //
    //                                              //
    //  args:   fax - The new fax number to update  //
    //          id - Id of the account to adjust    //
    //**********************************************//
    func updateAccount(accountObj: Account) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "account": [
                    "name": "\(accountObj.name)",
                    "street_1": "\(accountObj.street_1)",
                    "street_2": "\(accountObj.street_2)",
                    "city": "\(accountObj.city)",
                    "state": "\(accountObj.state)",
                    "country": "\(accountObj.country)",
                    "postal_code": "\(accountObj.postal_code)",
                    "phone": "\(accountObj.phone)",
                    "fax": "\(accountObj.fax)",
                    "website": "\(accountObj.website)",
                    "group_id": "\(accountObj.group_id)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts/\(accountObj.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateAccount HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //***************** END ACCOUNT FUNCTIONS **********************//
    
    
    
    
    //***************** START BUNDLE FUNCTIONS *********************//
    
    //**********************************************//
    //                                              //
    //  func:   getAllBundles                       //
    //                                              //
    //  Desc:   Gets all the bundles in the         //
    //          database.                           //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllBundles(DESC: Bool) -> [Bundle] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var bundleArray = [Bundle]()
        
        //Create body with json in it, made pretty
        //create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if DESC {
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllBundles HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let bundleObj = Bundle.init()
                            if let id = (element["id"] as? Int){
                                bundleObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                bundleObj.name = name
                            }
                            if let created_at = (element["created_at"] as? String){
                                bundleObj.modified_date.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                bundleObj.modified_date.updated_at = updated_at
                            }
                            if let quote_id = (element["quote_id"] as? Int){
                                bundleObj.quote_id = quote_id
                            }
                            if let option = (element["option"] as? Bool){
                                bundleObj.option = option
                            }
                            if let quote_position = (element["quote_position"] as? Int){
                                bundleObj.quote_position = quote_position
                            }
                            bundleArray.append(bundleObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return bundleArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   getBundlesForQuote                  //
    //                                              //
    //  Desc:   Gets all the bundles in the         //
    //          database related to the quote is    //
    //                                              //
    //  args:   DESC - Set cascading list           //
    //          id - id of the quote to grab bundles//
    //**********************************************//
    func getBundlesForQuote(DESC: Bool, id: Int) -> [Bundle] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var bundleArray = [Bundle]()
        
        //Create body with json in it, made pretty
        //create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quotes/\(id)/bundles")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetBundlesForQuotes HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let bundleObj = Bundle.init()
                            if let id = (element["id"] as? Int){
                                bundleObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                bundleObj.name = name
                            }
                            if let created_at = (element["created_at"] as? String){
                                bundleObj.modified_date.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                bundleObj.modified_date.updated_at = updated_at
                            }
                            if let quote_id = (element["quote_id"] as? Int){
                                bundleObj.quote_id = quote_id
                            }
                            if let option = (element["option"] as? Bool){
                                bundleObj.option = option
                            }
                            if let quote_position = (element["quote_position"] as? Int){
                                bundleObj.quote_position = quote_position
                            }
                            bundleArray.append(bundleObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return bundleArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   postNewBundle                       //
    //                                              //
    //  Desc:   Posts new bundle under account      //
    //                                              //
    //  args:   bundleObj - new bundle object to    //
    //                      post                    //
    //**********************************************//
    func postNewBundle(bundleObj: Bundle) -> Int {
        var id: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "bundle": [
                    "name": "\(bundleObj.name!)",
                    "quote_id": "\(bundleObj.quote_id)",
                    "option": "\(bundleObj.option)",
                    "quote_position": "\(bundleObj.quote_position)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("postNewBundle HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteBundle                        //
    //                                              //
    //  Desc:   Deletes specified bundle for the    //
    //          current user                        //
    //                                              //
    //  args:   id - int representing desired       //
    //               bundle                         //
    //**********************************************//
    func deleteBundle(id: Int) -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var code: Int = 0
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteBundle HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code
    }
    
    //**********************************************//
    //                                              //
    //  func:   updateBundle                        //
    //                                              //
    //  Desc:   updates specified Bundle            //
    //                                              //
    //  args:   bundleObj - bundleObject to be      //
    //                      updated                 //
    //**********************************************//
    func updateBundle(bundleObj: Bundle) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "bundle": [
                    "name": "\(bundleObj.name!)",
                    "quote_id": "\(bundleObj.quote_id)",
                    "option": "\(bundleObj.option)",
                    "quote_position": "\(bundleObj.quote_position)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles/\(bundleObj.id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateBundle HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   getBundle                           //
    //                                              //
    //  Desc:   Gets specified bundle for the       //
    //          current user                        //
    //                                              //
    //  args:   id - int representing desired       //
    //               desired bundle                 //
    //**********************************************//
    func getBundle(id: Int) -> Bundle {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let bundleObj = Bundle.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("getBundle HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        let element = data[0]
                        if let id = (element["id"] as? Int){
                            bundleObj.id = id
                        }
                        if let name = (element["name"] as? String){
                            bundleObj.name = name
                        }
                        if let created_at = (element["created_at"] as? String){
                            bundleObj.modified_date.created_at = created_at
                        }
                        if let updated_at = (element["updated_at"] as? String){
                            bundleObj.modified_date.updated_at = updated_at
                        }
                        if let quote_id = (element["quote_id"] as? Int){
                            bundleObj.quote_id = quote_id
                        }
                        if let option = (element["option"] as? Bool){
                            bundleObj.option = option
                        }
                        if let quote_position = (element["quote_position"] as? Int){
                            bundleObj.quote_position = quote_position
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return bundleObj
    }
    
    //****************** END BUNDLE FUNCTIONS **********************//
    
    //**************** START CONTACT FUNCTIONS *********************//
    
    //**********************************************//
    //                                              //
    //  func:   getAllContacts                      //
    //                                              //
    //  Desc:   Gets all the contacts for the       //
    //          current user                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllContacts(DESC: Bool) -> [Contact] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var contactArray = [Contact]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllContacts HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let contactObj = Contact.init()
                            if let firstname = (element["first_name"] as? String){
                                contactObj.first_name = firstname
                            }
                            if let lastname = (element["last_name"] as? String){
                                contactObj.last_name = lastname
                            }
                            if let email = (element["email"] as? String){
                                contactObj.email = email
                            }
                            if let fax = (element["fax"] as? String){
                                contactObj.fax = fax
                            }
                            if let phone = (element["phone"] as? String){
                                contactObj.phone = phone
                            }
                            if let title = (element["title"] as? String){
                                contactObj.title = title
                            }
                            if let notes = (element["notes"] as? String){
                                contactObj.notes = notes
                            }
                            if let id = (element["id"] as? Int){
                                contactObj.id = id
                            }
                            if let account_id = (element["account_id"] as? Int){
                                contactObj.account_id = account_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                contactObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                contactObj.modified_dates.updated_at = updated_at
                            }
                            contactArray.append(contactObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return contactArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   getAllContactsForAccount            //
    //                                              //
    //  Desc:   Gets all the contacts for the       //
    //          current user                        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllContactsForAccount(DESC: Bool, account_id: Int) -> [Contact] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var contactArray = [Contact]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/accounts/\(account_id)/contacts")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllContactsForAccount, Account #\(account_id) HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let contactObj = Contact.init()
                            if let firstname = (element["first_name"] as? String){
                                contactObj.first_name = firstname
                            }
                            if let lastname = (element["last_name"] as? String){
                                contactObj.last_name = lastname
                            }
                            if let email = (element["email"] as? String){
                                contactObj.email = email
                            }
                            if let fax = (element["fax"] as? String){
                                contactObj.fax = fax
                            }
                            if let phone = (element["phone"] as? String){
                                contactObj.phone = phone
                            }
                            if let title = (element["title"] as? String){
                                contactObj.title = title
                            }
                            if let notes = (element["notes"] as? String){
                                contactObj.notes = notes
                            }
                            if let id = (element["id"] as? Int){
                                contactObj.id = id
                            }
                            if let account_id = (element["account_id"] as? Int){
                                contactObj.account_id = account_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                contactObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                contactObj.modified_dates.updated_at = updated_at
                            }
                            contactArray.append(contactObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return contactArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   postNewContact                      //
    //                                              //
    //  Desc:   Posts new contact under account     //
    //                                              //
    //  args:   contactObj - new contact object to  //
    //                       post                   //
    //**********************************************//
    func postNewContact(contactObj: Contact) -> Int {
        var id: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "contact": [
                    "account_id": "\(contactObj.account_id!)",
                    "first_name": "\(contactObj.first_name!)",
                    "last_name": "\(contactObj.last_name!)",
                    "title": "\(contactObj.title!)",
                    "phone": "\(contactObj.phone!)",
                    "notes": "\(contactObj.notes!)",
                    "email": "\(contactObj.email!)",
                    "fax": "\(contactObj.fax!)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("postNewContact HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id
    }
    
    //**********************************************//
    //                                              //
    //  func:   getContact                          //
    //                                              //
    //  Desc:   Gets specified contact              //
    //                                              //
    //  args:   id - int representing desired       //
    //               contact                        //
    //**********************************************//
    func getContact(id: Int) -> Contact {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let contactObj = Contact.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("getContact HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data) //REMOVE ME LATER
                        let element = data[0]
                        if let firstname = (element["first_name"] as? String){
                            contactObj.first_name = firstname
                        }
                        if let lastname = (element["last_name"] as? String){
                            contactObj.last_name = lastname
                        }
                        if let email = (element["email"] as? String){
                            contactObj.email = email
                        }
                        if let fax = (element["fax"] as? String){
                            contactObj.fax = fax
                        }
                        if let phone = (element["phone"] as? String){
                            contactObj.phone = phone
                        }
                        if let title = (element["title"] as? String){
                            contactObj.title = title
                        }
                        if let notes = (element["notes"] as? String){
                            contactObj.notes = notes
                        }
                        if let id = (element["id"] as? Int){
                            contactObj.id = id
                        }
                        if let account_id = (element["account_id"] as? Int){
                            contactObj.account_id = account_id
                        }
                        if let created_at = (element["created_at"] as? String){
                            contactObj.modified_dates.created_at = created_at
                        }
                        if let updated_at = (element["updated_at"] as? String){
                            contactObj.modified_dates.updated_at = updated_at
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return contactObj
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   updateContact                       //
    //                                              //
    //  Desc:   updates specified contact           //
    //                                              //
    //  args:   fax - The new fax number to update  //
    //          id - Id of the account to adjust    //
    //**********************************************//
    func updateContact(contactObj : Contact) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "contact": [
                    "account_id": "\(contactObj.account_id!)",
                    "first_name": "\(contactObj.first_name!)",
                    "last_name": "\(contactObj.last_name!)",
                    "title": "\(contactObj.title!)",
                    "phone": "\(contactObj.phone!)",
                    "notes": "\(contactObj.notes!)",
                    "email": "\(contactObj.email!)",
                    "fax": "\(contactObj.fax!)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts/\(contactObj.id!)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateContact HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteContact                       //
    //                                              //
    //  Desc:   deletes specified contact           //
    //                                              //
    //  args:   id of contact                       //
    //**********************************************//
    func deleteContact(id : Int) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/contacts/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteContact HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    //******************************************************** END CONTACT FUNCTIONS ***********************************************************//
    
    
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllProducts                      //
    //                                              //
    //  Desc:   Gets all products                   //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func getAllProducts(DESC: Bool) -> [Product] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var productArray = [Product]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllProducts HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let product = Product.init()
                            if let id = (element["id"] as? Int){
                                product.product_id = id
                            }
                            if let name = (element["name"] as? String){
                                product.name = name
                            }
                            if let make = (element["make"] as? String){
                                product.make = make
                            }
                            if let category = (element["category"] as? String){
                                product.category = category
                            }
                            if let sku = (element["sku"] as? String) {
                                product.sku = sku
                            }
                            if let lead_time = (element["lead_time"] as? Int){
                                product.lead_time = lead_time
                            }
                            if let description = (element["description"] as? String){
                                product.description = description
                            }
                            if let active = (element["active"] as? Bool){
                                product.active = active
                            }
                            if let created_at = (element["created_at"] as? String){
                                product.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                product.modified_dates.updated_at = updated_at
                            }
                            if let image = (element["image"] as? String){
                                product.image = image
                            }
                            if let digest_id = (element["digest_id"] as? String){
                                product.digest_id = digest_id
                            }
                            productArray.append(product)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return productArray
    }
    
    //**********************************************//
    //                                              //
    //  func:   getProduct                          //
    //                                              //
    //  Desc:   gets the specified product          //
    //           from the API                       //
    //                                              //
    //  args:   product_id                          //
    //**********************************************//
    
    func getProduct(product_id : Int) -> Product {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let product = Product.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products/\(product_id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetProduct HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    print(jsonArray)
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        let element = data[0]
                        if let id = (element["id"] as? Int){
                            product.product_id = id
                        }
                        if let name = (element["name"] as? String){
                            product.name = name
                        }
                        if let make = (element["make"] as? String){
                            product.make = make
                        }
                        if let category = (element["category"] as? String){
                            product.category = category
                        }
                        if let sku = (element["sku"] as? String) {
                            product.sku = sku
                        }
                        if let lead_time = (element["lead_time"] as? Int){
                            product.lead_time = lead_time
                        }
                        if let description = (element["description"] as? String){
                            product.description = description
                        }
                        if let active = (element["active"] as? Bool){
                            product.active = active
                        }
                        if let created_at = (element["created_at"] as? String){
                            product.modified_dates.created_at = created_at
                        }
                        if let updated_at = (element["updated_at"] as? String){
                            product.modified_dates.updated_at = updated_at
                        }
                        if let image = (element["image"] as? String){
                            product.image = image
                        }
                        if let digest_id = (element["digest_id"] as? String){
                            product.digest_id = digest_id
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return product
    }
    
    //**********************************************//
    //                                              //
    //  func:   getProductMakes                     //
    //                                              //
    //  Desc:   gets the makes for generic types of //
    //          equipment                           //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func getProductMakes() -> [String] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var makes = [String]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products/makes")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetProductMakes HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [String]
                    {
                        makes = data
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return makes
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getProductBases                     //
    //                                              //
    //  Desc:   gets the bases for a certain type   //
    //          of make                             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func getProductBases(DESC: Bool, make: String) -> [Product] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var productArray = [Product]()
        
        //Create body with json in it, made pretty
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "make":"\(make)"
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products/bases")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetProductBases HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let product = Product.init()
                            if let id = (element["id"] as? Int){
                                product.product_id = id
                            }
                            if let name = (element["name"] as? String){
                                product.name = name
                            }
                            if let make = (element["make"] as? String){
                                product.make = make
                            }
                            if let category = (element["category"] as? String){
                                product.category = category
                            }
                            if let sku = (element["sku"] as? String) {
                                product.sku = sku
                            }
                            if let lead_time = (element["lead_time"] as? Int){
                                product.lead_time = lead_time
                            }
                            if let description = (element["description"] as? String){
                                product.description = description
                            }
                            if let active = (element["active"] as? Bool){
                                product.active = active
                            }
                            if let created_at = (element["created_at"] as? String){
                                product.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                product.modified_dates.updated_at = updated_at
                            }
                            if let image = (element["image"] as? String){
                                product.image = image
                            }
                            if let digest_id = (element["digest_id"] as? String){
                                product.digest_id = digest_id
                            }
                            productArray.append(product)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return productArray
    }
    
    
    
    //**********************************************//
    //                                              //
    //  func:   getProductAdders                    //
    //                                              //
    //  Desc:   gets the adders for a specific      //
    //          product                             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    
    func getProductAdders(DESC: Bool, product_id: Int, make: String) -> [[Product]] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var productArray = [[Product]]()
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products/\(product_id)/adders")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetProductAdders HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        if make == "Abort Gate" {
                            for element2 in data {
                                if let spark_switch = element2["spark_switch"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in spark_switch {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let deduct = element2["deduct"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in deduct {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let support_a = element2["support_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support_a {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let support_b = element2["support_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let platform = element2["platform"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in platform {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let heat_shield = element2["heat_shield"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in heat_shield {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "Airlock" {
                            for element2 in data {
                                if let wipers = element2["wipers"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in wipers {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let flange = element2["flange"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in flange {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let motor = element2["motor"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in motor {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                            }
                        }
                        else if make == "BRF" {
                            for element2 in data {
                                if let support = element2["support"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let support_b = element2["support_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let discharge_a = element2["discharge_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in discharge_a {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let filter = element2["filter"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in filter {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let inlet = element2["inlet"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in inlet {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let discharge_b = element2["discharge_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in discharge_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let gauge = element2["gauge"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in gauge {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let filter_b = element2["filter_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in filter_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let hopper = element2["hopper"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in hopper {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                            }
                        }
                            //Didn't do this one yet
                        else if make == "CMAXX" {
                            for element2 in data {
                                if let filter = element2["filter"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in filter {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let fire = element2["fire_explosion"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in fire {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let inlet = element2["inlet_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in inlet {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let inlet = element2["inlet_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in inlet {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let timer = element2["timer"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in timer {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let filter = element2["filet_bag"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in filter {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let deduct = element2["deduct"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in deduct {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let support = element2["support_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let discharge = element2["discharge_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in discharge {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let hopper = element2["hopper_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in hopper {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let dd = element2["dd_fan"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in dd {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let dis_a = element2["discharge_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in dis_a {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                                if let hop_b = element2["hopper_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in hop_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                }
                            }
                        }
                        else if make == "CMAXX Control Panel" {
                            for element2 in data {
                                if let control_panel = element2["control_panel"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in control_panel {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let cpanel_adder = element2["control_panel_adder"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in cpanel_adder {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "CMAXX Fan" {
                            for element2 in data {
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "Cast Airlock" {
                            for element2 in data {
                                if let housing = element2["housing"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in housing {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let wipers = element2["wipers"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in wipers {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "Cyclone" {
                            for element2 in data {
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let plates = element2["plates"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in plates {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let accessories = element2["accessories"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in accessories {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let support_a = element2["support_a"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support_a {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let support_b = element2["support_b"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in support_b {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let expansion_hopper = element2["expansion_hopper"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in expansion_hopper {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "Dust Level Sensor" {
                            for element2 in data {
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                            }
                        }
                        else if make == "Explosion Isolation Valve" {
                            for element2 in data {
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let deduct = element2["deduct"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in deduct {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                
                            }
                            
                        }
                        else if make == "Shadow" {
                            for element2 in data {
                                if let base = element2["base"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in base {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let fan = element2["fan"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in fan {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                if let filter = element2["filter"] as? [[String:AnyObject]] {
                                    var innerProdArray = [Product]()
                                    for element in filter {
                                        let product = self.createProduct(array: element)
                                        innerProdArray.append(product)
                                    }
                                    productArray.append(innerProdArray)
                                }
                                
                            }
                            
                        }
                            
                        else if make == "Spark Trap" {
                            for _ in data {
                                // Nothing gets returned here, not sure if intentional or not
                                
                            }
                            
                        }
                        
                        
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return productArray
    }
    
    //******************************************************** END PRODUCT FUNCTIONS ***********************************************************//
    
    
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllQuoteItems                    //
    //                                              //
    //  Desc:   Gets all quote_items                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllQuoteItems(DESC: Bool) -> [QuoteItem] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var quote_itemArray = [QuoteItem]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quote_items")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllQuoteItems HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let quote_itemObj = QuoteItem.init()
                            if let id = (element["id"] as? Int){
                                quote_itemObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                quote_itemObj.name = name
                            }
                            if let bundle_id = (element["bundle_id"] as? Int){
                                quote_itemObj.bundle_id = bundle_id
                            }
                            if let image = (element["image"] as? String){
                                quote_itemObj.image = image
                            }
                            if let description = (element["description"] as? String){
                                quote_itemObj.description = description
                            }
                            if let model = (element["model"] as? String){
                                quote_itemObj.model = model
                            }
                            if let lead_time = (element["lead_time"] as? Int){
                                quote_itemObj.lead_time = lead_time
                            }
                            if let category = (element["category"] as? String){
                                quote_itemObj.category = category
                            }
                            if let temp_price = (element["price"] as? String){
                                let price = Double(temp_price)!
                                quote_itemObj.price = price
                            }
                            if let created_at = (element["created_at"] as? String){
                                quote_itemObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                quote_itemObj.modified_dates.updated_at = updated_at
                            }
                            if let option = (element["option"] as? Bool){
                                quote_itemObj.option = option
                            }
                            if let sku = (element["sku"] as? String){
                                quote_itemObj.sku = sku
                            }
                            if let product_id = (element["product_id"] as? Int){
                                quote_itemObj.product_id = product_id
                            }
                            if let bundle_position = (element["bundle_position"] as? Int){
                                quote_itemObj.bundle_position = bundle_position
                            }
                            quote_itemArray.append(quote_itemObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quote_itemArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   postNewQuoteItem                    //
    //                                              //
    //  Desc:   Posts a new quote_item              //
    //                                              //
    //  args: quote                                 //
    //**********************************************//
    func postNewQuoteItem(quote_item : QuoteItem) -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var id : Int = 0
        let json  = [
            "data": [
                "quote_item": [
                    "product_id": "\(quote_item.product_id)",
                    "bundle_id": "\(quote_item.bundle_id)",
                    "quantity": "\(quote_item.quantity)",
                    "name": "\(quote_item.name)",
                    "image": "\(quote_item.image)",
                    "description": "\(quote_item.description)",
                    "model": "\(quote_item.model)",
                    "lead_time": "\(quote_item.lead_time)",
                    "category": "\(quote_item.category)",
                    "price": "\(quote_item.price)",
                    "option": "\(quote_item.option)",
                    "sku": "\(quote_item.sku)",
                    "bundle_position": "\(quote_item.bundle_position)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quote_items")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("createQuote_Item HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            }catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id
    }
    
    //**********************************************//
    //                                              //
    //  func:   getQuoteItem                        //
    //                                              //
    //  Desc:   gets the specified quote_item       //
    //           from the API                       //
    //                                              //
    //  args:   quote_id                            //
    //**********************************************//
    
    func getQuoteItem(quote_item_id : Int) -> QuoteItem {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let quote_itemObj = QuoteItem.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quote_items/\(quote_item_id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetQuote_Item HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        let element = data[0]
                        if let id = (element["id"] as? Int){
                            quote_itemObj.id = id
                        }
                        if let name = (element["name"] as? String){
                            quote_itemObj.name = name
                        }
                        if let bundle_id = (element["bundle_id"] as? Int){
                            quote_itemObj.bundle_id = bundle_id
                        }
                        if let quantity = (element["quantity"] as? Int){
                            quote_itemObj.quantity = quantity
                        }
                        if let image = (element["image"] as? String){
                            quote_itemObj.image = image
                        }
                        if let description = (element["description"] as? String){
                            quote_itemObj.description = description
                        }
                        if let model = (element["model"] as? String){
                            quote_itemObj.model = model
                        }
                        if let lead_time = (element["lead_time"] as? Int){
                            quote_itemObj.lead_time = lead_time
                        }
                        if let category = (element["category"] as? String){
                            quote_itemObj.category = category
                        }
                        if let temp_price = (element["price"] as? String){
                            let price = Double(temp_price)!
                            quote_itemObj.price = price
                        }
                        if let created_at = (element["created_at"] as? String){
                            quote_itemObj.modified_dates.created_at = created_at
                        }
                        if let updated_at = (element["updated_at"] as? String){
                            quote_itemObj.modified_dates.updated_at = updated_at
                        }
                        if let option = (element["option"] as? Bool){
                            quote_itemObj.option = option
                        }
                        if let sku = (element["sku"] as? String){
                            quote_itemObj.sku = sku
                        }
                        if let product_id = (element["product_id"] as? Int){
                            quote_itemObj.product_id = product_id
                        }
                        if let bundle_position = (element["bundle_position"] as? Int){
                            quote_itemObj.bundle_position = bundle_position
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quote_itemObj
    }
    
    //**********************************************//
    //                                              //
    //  func:   updateQuoteItem                     //
    //                                              //
    //  Desc:   updates specified quote_item        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func updateQuoteItem(quote_item : QuoteItem) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "quote_item": [
                    "product_id": "\(quote_item.product_id)",
                    "bundle_id": "\(quote_item.bundle_id)",
                    "quantity": "\(quote_item.quantity)",
                    "name": "\(quote_item.name)",
                    "image": "\(quote_item.image)",
                    "description": "\(quote_item.description)",
                    "model": "\(quote_item.model)",
                    "lead_time": "\(quote_item.lead_time)",
                    "category": "\(quote_item.category)",
                    "price": "\(quote_item.price)",
                    "option": "\(quote_item.option)",
                    "sku": "\(quote_item.sku)",
                    "bundle_position": "\(quote_item.bundle_position)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quote_items/\(quote_item.id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateQuoteItem HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteQuoteItem                     //
    //                                              //
    //  Desc:   deletes specified quote_item        //
    //                                              //
    //  args:   id of quote_item                    //
    //**********************************************//
    func deleteQuoteItem(id : Int) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/quote_items/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteQuoteItem HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    //**********************************************//
    //                                              //
    //  func:   getAllQuoteItems                    //
    //                                              //
    //  Desc:   Gets all quote_items                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllQuoteItemsInBundle(DESC: Bool, bundle_id: Int) -> [QuoteItem] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var quote_itemArray = [QuoteItem]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles/\(bundle_id)/quote_items")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllQuoteItemsInBundle Bundle #\(bundle_id) HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let quote_itemObj = QuoteItem.init()
                            if let id = (element["id"] as? Int){
                                quote_itemObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                quote_itemObj.name = name
                            }
                            if let bundle_id = (element["bundle_id"] as? Int){
                                quote_itemObj.bundle_id = bundle_id
                            }
                            if let quantity = (element["quantity"] as? Int){
                                quote_itemObj.quantity = quantity
                            }
                            if let image = (element["image"] as? String){
                                quote_itemObj.image = image
                            }
                            if let description = (element["description"] as? String){
                                quote_itemObj.description = description
                            }
                            if let model = (element["model"] as? String){
                                quote_itemObj.model = model
                            }
                            if let lead_time = (element["lead_time"] as? Int){
                                quote_itemObj.lead_time = lead_time
                            }
                            if let category = (element["category"] as? String){
                                quote_itemObj.category = category
                            }
                            if let temp_price = (element["price"] as? String){
                                let price = Double(temp_price)!
                                quote_itemObj.price = price
                            }
                            if let created_at = (element["created_at"] as? String){
                                quote_itemObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                quote_itemObj.modified_dates.updated_at = updated_at
                            }
                            if let option = (element["option"] as? Bool){
                                quote_itemObj.option = option
                            }
                            if let sku = (element["sku"] as? String){
                                quote_itemObj.sku = sku
                            }
                            if let product_id = (element["product_id"] as? Int){
                                quote_itemObj.product_id = product_id
                            }
                            if let bundle_position = (element["bundle_position"] as? Int){
                                quote_itemObj.bundle_position = bundle_position
                            }
                            quote_itemArray.append(quote_itemObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return quote_itemArray
    }
    
    //****************** END QUOTE ITEM FUNCTIONS *********************//
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllTags                          //
    //                                              //
    //  Desc:   Asserts tag array is valid          //
    //          and not empty                       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllTags(DESC: Bool) -> [Tag] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var tagArray = [Tag]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/tags")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllTags HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let tagObj = Tag.init()
                            if let id = (element["id"] as? Int){
                                tagObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                tagObj.name = name
                            }
                            if let category = (element["category"] as? String){
                                tagObj.category = category
                            }
                            if let value = (element["value"] as? String){
                                tagObj.value = value
                            }
                            if let taggable_type = (element["taggable_type"] as? String){
                                tagObj.taggable_type = taggable_type
                            }
                            if let taggable_id = (element["taggable_id"] as? Int){
                                tagObj.taggable_id = taggable_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                tagObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                tagObj.modified_dates.updated_at = updated_at
                            }
                            tagArray.append(tagObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return tagArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getTag                              //
    //                                              //
    //  Desc:   Gets tag with specified id          //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getTag(tag_id: Int) -> Tag {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        let tagObj = Tag.init()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/tags/\(tag_id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetTag HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    print(jsonArray)
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        
                        for element in data {
                            if let id = (element["id"] as? Int){
                                tagObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                tagObj.name = name
                            }
                            if let category = (element["category"] as? String){
                                tagObj.category = category
                            }
                            if let value = (element["value"] as? String){
                                tagObj.value = value
                            }
                            if let taggable_type = (element["taggable_type"] as? String){
                                tagObj.taggable_type = taggable_type
                            }
                            if let taggable_id = (element["taggable_id"] as? Int){
                                tagObj.taggable_id = taggable_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                tagObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                tagObj.modified_dates.updated_at = updated_at
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return tagObj
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getTagsForProduct                    //
    //                                              //
    //  Desc:   Gets tags with associated           //
    //          product id                          //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getTagsForProduct(DESC: Bool, product_id: Int) -> [Tag] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var tagArray = [Tag]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/products/\(product_id)/tags")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 10000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetTagsForProduct HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let tagObj = Tag.init()
                            if let id = (element["id"] as? Int){
                                tagObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                tagObj.name = name
                            }
                            if let category = (element["category"] as? String){
                                tagObj.category = category
                            }
                            if let value = (element["value"] as? String){
                                tagObj.value = value
                            }
                            if let taggable_type = (element["taggable_type"] as? String){
                                tagObj.taggable_type = taggable_type
                            }
                            if let taggable_id = (element["taggable_id"] as? Int){
                                tagObj.taggable_id = taggable_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                tagObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                tagObj.modified_dates.updated_at = updated_at
                            }
                            tagArray.append(tagObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return tagArray
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   postNewTag                          //
    //                                              //
    //  Desc:   Posts a new tag                     //
    //                                              //
    //  args:   tag object                          //
    //**********************************************//
    func postNewTag(tagObj: Tag) -> Int {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var id : Int = 0
        let json  = [
            "data": [
                "tag": [
                    "name":"\(tagObj.name)",
                    "category":"\(tagObj.category)",
                    "value":"\(tagObj.value)",
                    "taggable_type":"\(tagObj.taggable_type)",
                    "taggable_id":"\(tagObj.taggable_id)"
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/tags")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("createTag HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data{
                            id = (element["id"] as! Int)
                        }
                    }
                }
            }catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return id
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   updateQuoteItem                     //
    //                                              //
    //  Desc:   updates specified quote_item        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func updateTag(tagObj : Tag) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        //Create json to pass to httprequest with username and password
        let json  = [
            "data": [
                "tag": [
                    "name":"\(tagObj.name)",
                    "category":"\(tagObj.category)",
                    "value":"\(tagObj.value)",
                ]
            ]
            ] as [String : Any]
        
        //Create body with json in it, made pretty
        let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/tags/\(tagObj.id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        // insert body to the request
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("updateTag HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   deleteTag                           //
    //                                              //
    //  Desc:   deletes specified tag               //
    //                                              //
    //  args:   id of tag                           //
    //**********************************************//
    func deleteTag(id : Int) -> Int {
        var code: Int = 0   //code to store return value from http response
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/tags/\(id)")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                return
            }
            
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("deleteTag HTTP Response Code: \(httpResponse.statusCode)")
                code = httpResponse.statusCode
            }
            
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                    }
                }
            } catch let error as NSError {
                print(error)
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return code //Without semaphore code will always be empty because it returns before task can receive a response
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   getAllTags                          //
    //                                              //
    //  Desc:   Asserts tag array is valid          //
    //          and not empty                       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func getAllTagsInBundle(bundle_id: Int, DESC: Bool) -> [Tag] {
        let semaphore = DispatchSemaphore(value: 0) //semaphore to turn async to sync process
        var tagArray = [Tag]()
        
        //Create body with json in it, made pretty
        // create post request
        let link = URL(string: "https://quote-api.isystemsweb.com/bundles/\(bundle_id)/tags")!
        var request = URLRequest(url: link)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(DESC){
            request.addValue("{\"sorting\": {\"order\": \"DESC\"},\"paginating\": {\"limit\": 100000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        else{
            request.addValue("{\"sorting\": {\"order\": \"ASC\"},\"paginating\": {\"limit\": 100000, \"offset\": 0}}", forHTTPHeaderField: "meta")
        }
        request.addValue("Bearer \(User.current_user.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data") //if error is nil print No data
                semaphore.signal() //Signal Task has completed
                return
            }
            //Get response code and store it into code
            if let httpResponse = response as? HTTPURLResponse {
                print("GetAllTagsInBundle Bundle #\(bundle_id) HTTP Response Code: \(httpResponse.statusCode)")
            }
            
            //Try catch
            do {
                //Break return json object into an array
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
                {
                    //Grab the data field inside json, which is an array inside an array
                    if let data = jsonArray["data"] as? [[String:AnyObject]]
                    {
                        print(data)
                        for element in data {
                            let tagObj = Tag.init()
                            if let id = (element["id"] as? Int){
                                tagObj.id = id
                            }
                            if let name = (element["name"] as? String){
                                tagObj.name = name
                            }
                            if let category = (element["category"] as? String){
                                tagObj.category = category
                            }
                            if let value = (element["value"] as? String){
                                tagObj.value = value
                            }
                            if let taggable_type = (element["taggable_type"] as? String){
                                tagObj.taggable_type = taggable_type
                            }
                            if let taggable_id = (element["taggable_id"] as? Int){
                                tagObj.taggable_id = taggable_id
                            }
                            if let created_at = (element["created_at"] as? String){
                                tagObj.modified_dates.created_at = created_at
                            }
                            if let updated_at = (element["updated_at"] as? String){
                                tagObj.modified_dates.updated_at = updated_at
                            }
                            tagArray.append(tagObj)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
                semaphore.signal() //Signal Task has completed
            }
            semaphore.signal() //Signal Task has completed
        }
        task.resume() //Start the task
        _ = semaphore.wait(timeout: .distantFuture) //Semaphore to wait for task to be completed
        return tagArray
    }
    
    internal func createProduct(array: [String:AnyObject]) -> Product{
        let product = Product.init()
        if let id = (array["id"] as? Int){
            product.product_id = id
        }
        if let name = (array["name"] as? String){
            product.name = name
        }
        if let make = (array["make"] as? String){
            product.make = make
        }
        if let category = (array["category"] as? String){
            product.category = category
        }
        if let sku = (array["sku"] as? String) {
            product.sku = sku
        }
        if let lead_time = (array["lead_time"] as? Int){
            product.lead_time = lead_time
        }
        if let description = (array["description"] as? String){
            product.description = description
        }
        if let active = (array["active"] as? Bool){
            product.active = active
        }
        if let created_at = (array["created_at"] as? String){
            product.modified_dates.created_at = created_at
        }
        if let updated_at = (array["updated_at"] as? String){
            product.modified_dates.updated_at = updated_at
        }
        if let image = (array["image"] as? String){
            product.image = image
        }
        if let digest_id = (array["digest_id"] as? String){
            product.digest_id = digest_id
        }
        return product
    }
    
}


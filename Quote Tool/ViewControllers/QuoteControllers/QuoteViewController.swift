//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   QuoteViewController.swift       //
//                                              //
//  Desc:       Functionality for quote view    //
//                                              //
//  Creation:   01Nov19                         //
//**********************************************//

import UIKit

class QuoteViewCell: UITableViewCell {
    
    
    @IBOutlet weak var quoteNumberTextField: UILabel!
    @IBOutlet weak var quoteUpdatedTextField: UILabel!
    @IBOutlet weak var accountNameTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    @IBOutlet weak var contactTextField: UILabel!
}

class QuoteViewController: UITableViewController, QuoteProtocol {
    
    var quoteArray = [Quote]()
    var searchedQuotes = [Quote]()
    var quoteToSend = Quote()
    var searched: Bool = false
    var rowSelected: Int = 0
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet var quoteHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adjust look for light or dark mode
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.tableView.backgroundColor = UIColor.lightGray
        } else {
            //For dark mode
            self.tableView.backgroundColor = UIColor.black
        }
        
        //Adds refresh capabalities
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        //Must handle differently if above iOS 10
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        searchButton.isEnabled = false
        clearButton.isEnabled = false
        self.tableView.estimatedRowHeight = 116
        //For loading: activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.tableView.center
        activityIndicator.frame.origin.y -= 116         //for putting view in center of screen since quote is 116 in size
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2) //Make indicator larger
        self.tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.quoteArray = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
            for element in self.quoteArray{
                let account = apiDispatcher.dispatcher.getAccount(id: element.account_id)
                let contact = apiDispatcher.dispatcher.getContact(id: element.contact_id)
                element.account_name = account.name
                element.contact_name = contact.first_name + " " + contact.last_name
            }
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.tableView.reloadData()
                self?.searchButton.isEnabled = true
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   refreshTable                        //
    //                                              //
    //  Desc:   Refreshes the table and resets      //
    //          any search previously made.         //
    //          Used for pull-down to refresh       //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @objc func refreshTable(refreshControl: UIRefreshControl) {
        searched = false
        searchButton.isEnabled = false
        clearButton.isEnabled = false
        DispatchQueue.global(qos: .default).async {
            self.quoteArray = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
            for element in self.quoteArray{
                let account = apiDispatcher.dispatcher.getAccount(id: element.account_id)
                let contact = apiDispatcher.dispatcher.getContact(id: element.contact_id)
                element.account_name = account.name
                element.contact_name = contact.first_name + " " + contact.last_name
            }
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.searchButton.isEnabled = true
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searched {
            return searchedQuotes.count
        }
        else {
            return quoteArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = quoteHeader
        // configure view, note the method gives you the section to help this process
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searched {
            quoteToSend = quoteArray[indexPath.row]
            rowSelected = indexPath.row
        }
        else {
            quoteToSend = searchedQuotes[indexPath.row]
            for (index, element) in quoteArray.enumerated() {
                if quoteToSend.id == element.id {
                    rowSelected = index
                }
            }
        }
        self.performSegue(withIdentifier: "SelectQuoteSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.tableView.separatorColor = UIColor.systemBlue
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tabCell", for: indexPath) as! QuoteViewCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        if !searched {
            cell.quoteNumberTextField.text = quoteArray[indexPath.row].quote_number
            cell.quoteUpdatedTextField.text = quoteArray[indexPath.row].modified_dates.convertUpdatedDateToReadable()
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: quoteArray[indexPath.row].sell_price as NSNumber) {
                cell.priceTextField.text = formatted_price
            }
            if(quoteArray[indexPath.row].account_name == ""){
                quoteArray[indexPath.row].account_name  = "Uncategorized"
            }
            cell.accountNameTextField.text = quoteArray[indexPath.row].account_name
            cell.contactTextField.text = quoteArray[indexPath.row].contact_name
        }
        else {
            cell.quoteNumberTextField.text = searchedQuotes[indexPath.row].quote_number
            cell.quoteUpdatedTextField.text = searchedQuotes[indexPath.row].modified_dates.convertUpdatedDateToReadable()
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: searchedQuotes[indexPath.row].sell_price as NSNumber) {
                cell.priceTextField.text = formatted_price
            }
            if(searchedQuotes[indexPath.row].account_name == ""){
                searchedQuotes[indexPath.row].account_name  = "Uncategorized"
            }
            cell.accountNameTextField.text = searchedQuotes[indexPath.row].account_name
            cell.contactTextField.text = searchedQuotes[indexPath.row].contact_name
        }
        return cell
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   passQuote                           //
    //                                              //
    //  Desc:   Run by Protocol senders to add, edit//
    //          and delete quotes from main array   //
    //                                              //
    //  args:   quote for passing edited, or deleted//
    //          quote. New determines if it was     //
    //          created or deleted                  //
    //**********************************************//
    func passQuote(quote: Quote, new: Bool) {
        //Was changed, not deleted
        if quote.id != 0 && !new {
            quoteArray[rowSelected] = quote
            let account = apiDispatcher.dispatcher.getAccount(id: quote.account_id)
            let contact = apiDispatcher.dispatcher.getContact(id: quote.contact_id)
            quote.account_name = account.name
            quote.contact_name = contact.first_name + " " + contact.last_name
        }
            //Was deleted, id was set to zero
        else if quote.id == 0 && !new {
            quoteArray.remove(at: rowSelected)
        }
            //Was created
        else {
            quoteArray.append(quote)
            let account = apiDispatcher.dispatcher.getAccount(id: quote.account_id)
            let contact = apiDispatcher.dispatcher.getContact(id: quote.contact_id)
            quote.account_name = account.name
            quote.contact_name = contact.first_name + " " + contact.last_name
            quoteToSend = quote
            rowSelected = quoteArray.count - 1
            performSegue(withIdentifier: "SelectQuoteSegue", sender: self)
        }
        clearSearch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newQuoteSegue" {
            if let viewController = segue.destination as? CreateQuoteViewController {
                //sets the delegate of the next controller to this controller
                viewController.quote_delegate = self
            }
        }
        if segue.identifier == "SelectQuoteSegue" {
            if let viewController = segue.destination as? SpecificQuoteViewController {
                //sets the delegate of the next controller to this controller
                viewController.quote_delegate = self
                viewController.quote = quoteToSend
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   searchClicked                       //
    //                                              //
    //  Desc:   Populates an alert to allow the user//
    //          to input search criteria for quotes //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func searchClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Search for Quote", message: "Enter the application or quote number of the quote", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }
        
        let saveAction = UIAlertAction(title: "Search", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    if let searchText = textField.text {
                        let activityIndicator = UIActivityIndicatorView()
                        activityIndicator.center = self.tableView.center
                        activityIndicator.frame.origin.y -= 116         //for putting view in center of screen since quote is 116 in size
                        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
                        self.tableView.addSubview(activityIndicator)
                        activityIndicator.startAnimating()
                        DispatchQueue.global(qos: .default).async {
                            self.searchedQuotes = apiDispatcher.dispatcher.getAllQuotesFromSearch(DESC: false, searchText: searchText)
                            for element in self.searchedQuotes{
                                let account = apiDispatcher.dispatcher.getAccount(id: element.account_id)
                                let contact = apiDispatcher.dispatcher.getContact(id: element.contact_id)
                                element.account_name = account.name
                                element.contact_name = contact.first_name + " " + contact.last_name
                            }
                            DispatchQueue.main.async { [weak self] in
                                // UI updates must be on main thread
                                activityIndicator.stopAnimating()
                                activityIndicator.removeFromSuperview()
                                self?.tableView.reloadData()
                            }
                            
                        }
                    }
                    else {
                        let alert = UIAlertController(title: "Could not parse text field", message:
                            "Please check your entry and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.searched = true
                    self.searchButton.isEnabled = false
                    self.clearButton.isEnabled = true
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.preferredAction = saveAction
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        clearSearch()
    }
    
    func clearSearch() {
        searched = false
        searchButton.isEnabled = true
        clearButton.isEnabled = false
        tableView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //If display modes changed while app was running
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.tableView.backgroundColor = UIColor.lightGray
        } else {
            //For dark mode
            self.tableView.backgroundColor = UIColor.black
        }
    }
}


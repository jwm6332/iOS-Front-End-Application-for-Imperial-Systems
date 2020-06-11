//*************************************************************//
//          Imperial Systems Inc.                              //
//*************************************************************//
//                                                             //
//  Filename:   AccountViewControllerTableViewController.swift //
//                                                             //
//  Desc:       Search for file functionality                  //
//                                                             //
//  Creation:   03Mar20                                        //
//*************************************************************//

import UIKit

class AccountViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
}

class AccountViewControllerTableViewController: UITableViewController, AccountProtocol {
    
    //**********************************************//
    //                                              //
    //  func:   passData                            //
    //                                              //
    //  Desc:   Used to update data from one view   //
    //          to the next. Avoids having to       //
    //          refresh the application to see new  //
    //          updates to the account list         //
    //                                              //
    //  args:   account - Account                   //
    //          new  - Bool                         //
    //**********************************************//
    func passData(account: Account, new: Bool) {
        //Was changed, not deleted
        if !account.name.isEmpty && !new {
            accountArray[rowSelected] = account
        }
            //Was deleted
        else if account.name.isEmpty && !new {
            accountArray.remove(at: rowSelected)
        }
        else {
            accountArray.append(account)
        }
        clearSearch()
    }
    
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet var accountHeader: UIView!
    
    var accountToSend = Account()
    var accountArray = [Account]()
    var rowSelected: Int = 0
    var searchAccounts = [Account]()
    var searched: Bool = false
    
    //**********************************************//
    //                                              //
    //  func:   viewDidLoad                         //
    //                                              //
    //  Desc:   Function that takes care of         //
    //          initializing the view and all of its//
    //          components. Many styling adjustments//
    //          exist here.                         //
    //                                              //
    //  args:                                       //
    //**********************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.tableView.backgroundColor = UIColor.lightGray
        } else {
            //For dark mode
            self.tableView.backgroundColor = UIColor.black
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        searchButton.isEnabled = false
        clearButton.isEnabled = false
        self.tableView.estimatedRowHeight = 97
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.tableView.center
        activityIndicator.frame.origin.y -= 97         //for putting view in center of screen since quote is 116 in size
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.searchButton.isEnabled = true
                self?.tableView.reloadData()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   refreshTable                        //
    //                                              //
    //  Desc:   First disables user input while the //
    //          table is refreshed. The table is    //
    //          refreshed and afterwards the user   //
    //          input is enabled                    //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @objc func refreshTable(refreshControl: UIRefreshControl) {
        searched = false
        searchButton.isEnabled = false
        clearButton.isEnabled = false
        DispatchQueue.global(qos: .default).async {
            self.accountArray = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.searchButton.isEnabled = true
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   traitCollectionDidChange            //
    //                                              //
    //  Desc:   Adjusts the GUI elements based on   //
    //          light or dark mode.                 //
    //                                              //
    //  args:   previo....ction - UITraitC...on     //
    //**********************************************//
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //If changed modes while app was running
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.tableView.backgroundColor = UIColor.lightGray
        } else {
            //For dark mode
            self.tableView.backgroundColor = UIColor.black
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   numberOfSections                    //
    //                                              //
    //  Desc:   Returns the number of sections in   //
    //          tableView, which is locked at one.  //
    //          Increase the return to increase the //
    //          sections in the tableView           //
    //                                              //
    //  args:   tableView - UITableView             //
    //**********************************************//
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Returns the number of rows to       //
    //          populate the tableView based on the //
    //          account array (or filtered array)   //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !searched {
            return accountArray.count
        }
        else {
            return searchAccounts.count
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Sets the height of the tableView    //
    //          header                              //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Sets the tableView header           //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = accountHeader
        // configure view, note the method gives you the section to help this process
        return headerView
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Builds the entries in the tableView.//
    //          Sets GUI elements such as the       //
    //          separator and populates each cell   //
    //          using the Account Array             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.separatorColor = UIColor.systemBlue
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountViewCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        if !searched {
            cell.name.text = accountArray[indexPath.row].name
            cell.location.text = "\(accountArray[indexPath.row].city), \(accountArray[indexPath.row].state)"
        }
        else{
            cell.name.text = searchAccounts[indexPath.row].name
            cell.location.text = "\(searchAccounts[indexPath.row].city), \(searchAccounts[indexPath.row].state)"
        }
        return cell
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Handles when an account has been    //
    //          selected from the tableView         //
    //                                              //
    //  args:   tableView - UITableView             //
    //          indexPath - IndexPath               //
    //**********************************************//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searched {
            accountToSend = accountArray[indexPath.row]
            rowSelected = indexPath.row
        }
        else {
            accountToSend = searchAccounts[indexPath.row]
            for (index, element) in accountArray.enumerated() {
                if accountToSend.id == element.id {
                    rowSelected = index
                }
            }
        }
        self.performSegue(withIdentifier: "accountClickedSegue", sender: nil)
    }
    
    //**********************************************//
    //                                              //
    //  func:   prepare                             //
    //                                              //
    //  Desc:   Handles segues to other views when  //
    //          certain GUI elements are interacted //
    //          with.                               //
    //                                              //
    //  args:   segue - UIStoryBoardSegue           //
    //          sender - Any                        //
    //**********************************************//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountClickedSegue" {
            if let viewController = segue.destination as? SpecificAccountViewController {
                //sets the delegate of the next controller to this controller
                viewController.account = accountToSend
                viewController.account_delegate = self
            }
        }
        else if segue.identifier == "createAccountSegue" {
            if let viewController = segue.destination as? CreateAccountViewController {
                //sets the delegate of the next controller to this controller
                viewController.account_delegate = self
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   clearClicked                        //
    //                                              //
    //  Desc:   Handles button press event to call  //
    //          the clearSearch function            //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func clearClicked(_ sender: Any) {
        clearSearch()
    }
    
    //**********************************************//
    //                                              //
    //  func:   clearSearch                         //
    //                                              //
    //  Desc:   Clears search criteria, reloads data//
    //          and updates GUI elements            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func clearSearch() {
        searched = false
        searchButton.isEnabled = true
        clearButton.isEnabled = false
        tableView.reloadData()
    }
    
    //**********************************************//
    //                                              //
    //  func:   searchClicked                       //
    //                                              //
    //  Desc:   On button click, populate an alert  //
    //          to ask for search criteria. Then    //
    //          reloads the table data and sets the //
    //          appropriate GUI elements and flags  //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func searchClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Search for Account", message: "Enter the name of the account", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }
        
        let saveAction = UIAlertAction(title: "Search", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    self.searchAccounts.removeAll()
                    if let searchText = textField.text {
                        for element in self.accountArray {
                            if element.name.lowercased().contains(searchText.lowercased()) || element.name.lowercased().elementsEqual(searchText.lowercased()){
                                self.searchAccounts.append(element)
                            }
                        }
                        self.searched = true
                        self.searchButton.isEnabled = false
                        self.clearButton.isEnabled = true
                        self.tableView.reloadData()
                    }
                    else {
                        let alert = UIAlertController(title: "Could not parse text field", message:
                            "Please check your entry and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
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
    
}

//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   ProfileViewController.swift     //
//                                              //
//  Desc:       Allows the user to search for a //
//              file by name and/or filters     //
//                                              //
//  Creation:   04Nov19                         //
//**********************************************//

import UIKit

class SearchFileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //Varibles and components
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var searchFileTextBox: UITextField!
    @IBOutlet weak var documentTypePicker: UIPickerView!
    @IBOutlet weak var equipmentPicker: UIPickerView!
    @IBOutlet weak var searchButton: UIButton!
    let languages = ["", "English", "Spanish"]
    let equipment = ["", "Abort Gate", "BRF", "BRFMP", "CMAXX", "CMAXX Lazer", "Colors", "Combustable Dust", "Cyclone", "DeltaMAXX", "Dust Level Sensor", "EIV", "Explosion", "Firetrace", "Grain", "HD Airlock", "KST", "LP AirLock", "Rhino Drum", "ServiceMAXX", "Spark Trap", "SparkTrap: Raw End", "SparkTrap: Flanged End", "SparkTrap: Quick Fit End", "Spot Filter", "System"]
    let documentType = ["", "Drawing", "Manual", "Render", "Sell Sheet"]
    var delegate:Protocol?
    
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
        searchFileTextBox.text = ""
        searchFileTextBox.delegate = self
        languagePicker.delegate = self
        languagePicker.dataSource = self
        documentTypePicker.delegate = self
        documentTypePicker.dataSource = self
        equipmentPicker.delegate = self
        equipmentPicker.dataSource = self
        searchButton.layer.cornerRadius = searchButton.bounds.size.height/2
    }
    
    //**********************************************//
    //                                              //
    //  func:   numberOfComponents                  //
    //                                              //
    //  Desc:   On the view load, this initializes  //
    //          the picker view to have at least one//
    //          entry                               //
    //                                              //
    //  args:   pickerView - UIPickerView to update //
    //**********************************************//
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //**********************************************//
    //                                              //
    //  func:   pickerView                          //
    //                                              //
    //  Desc:   This dynamically initializes        //
    //          each picker view to have a number of//
    //          entries equal to the count of the   //
    //          list related to the picker view.    //
    //                                              //
    //  args:   pickerView - UIPickerView to update //
    //          component - Int (num of rows for    //
    //                      that specific picker)   //
    //**********************************************//
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == languagePicker{
            return languages.count
        }
        else if pickerView == equipmentPicker{
            return equipment.count
        }
        else {
            return documentType.count;
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   submitClicked                       //
    //                                              //
    //  Desc:   Takes the selections from all the   //
    //          entry fields in the program,        //
    //          performs a search, and navigates    //
    //          back to the file page view          //
    //                                              //
    //  args:   sender - Any (button click event)   //
    //**********************************************//
    @IBAction func submitClicked(_ sender: Any) {
        let selectedLanguage = languages[languagePicker.selectedRow(inComponent: 0)]
        let selectedDocType = documentType[documentTypePicker.selectedRow(inComponent: 0)]
        let selectedEquipType = equipment[equipmentPicker.selectedRow(inComponent: 0)]
        let searchCrit = searchFileTextBox.text!
        //uses onSearch from Protocol class to pass data to FileCollectionController
        delegate?.onSearch(language: selectedLanguage, docType: selectedDocType, equipType: selectedEquipType, searchCrit: searchCrit)
        self.navigationController?.popViewController(animated: true)
    }
    
    //**********************************************//
    //                                              //
    //  func:   pickerView                          //
    //                                              //
    //  Desc:   This dynamically initializes        //
    //          each picker view with the text that //
    //          needs to populate each entry in the //
    //          picker.                             //
    //                                              //
    //  args:   pickerView - UIPickerView to update //
    //          titleForRow - Int (which row)       //
    //          component - Int                     //
    //**********************************************//
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == languagePicker{
            return languages[row]
        }
        else if pickerView == equipmentPicker{
            return equipment[row]
        }
        else {
            return documentType[row]
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   testFieldShouldReturn               //
    //                                              //
    //  Desc:   On return key closes the keyboard   //
    //                                              //
    //  args:   textField - UITextField             //
    //**********************************************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

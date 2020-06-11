//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   DateHandler.swift               //
//                                              //
//  Desc:       Data model for Dates            //
//                                              //
//  Creation:   21Nov19                         //
//**********************************************//

import Foundation
public class DateHandler {
    //? = it may be nil at any point in time, use ! to unwrap before use on any variable using ?
    //! = impicitly unwrapped, it may be nil at first but it will have a value, therefore the object is already unwrapped and does not need ! when using later on
    //All var types are implicitly internal and can only be accessed within the same module
    //Setters and getters are not used in Swift unless computation will be done to modify the value
    
    
    //MARK: Properties
    var created_at : String
    var updated_at : String
    
    init(){
        self.created_at = ""
        self.updated_at = ""
    }
    
    //**********************************************//
    //                                              //
    //  func:   convertUpdatedDateToReadable        //
    //                                              //
    //  Desc:   Takes the updated_at string and     //
    //          splits it using its delimiters      //
    //          specified in Swift. Returns a       //
    //          rebuilt string in human readable    //
    //          form.                               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func convertUpdatedDateToReadable() -> String{
        var AM = true
        var monthName = "Jan"
        let firstSplit = self.updated_at.split(separator: "-")
        let year = firstSplit[0]
        let month = firstSplit[1]
        let secondSplit = firstSplit[2].split(separator: "T")
        let day = secondSplit[0]
        let thirdSplit = secondSplit[1].split(separator: ":")
        var hour = String(thirdSplit[0])
        let minute = thirdSplit[1]
        var fullString = ""
        
        if ((Int(hour) ?? 0)! - 12 < 0){
            AM = true
        } else {
            hour = String((Int(hour) ?? 0) - 12)
            AM = false
        }
        
        let monthNum = Int(month) ?? 0
        
        switch(monthNum){
        case 1:
            monthName = "Jan"
            break
        case 2:
            monthName = "Feb"
            break
        case 3:
            monthName = "Mar"
            break
        case 4:
            monthName = "Apr"
            break
        case 5:
            monthName = "May"
            break
        case 6:
            monthName = "Jun"
            break
        case 7:
            monthName = "Jul"
            break
        case 8:
            monthName = "Aug"
            break
        case 9:
            monthName = "Sep"
            break
        case 10:
            monthName = "Oct"
            break
        case 11:
            monthName = "Nov"
            break
        case 12:
            monthName = "Dec"
            break
        default:
            monthName = "Jan"
            break
        }
        
        fullString += "Last Modified: "
        fullString += monthName
        fullString += " "
        fullString += day
        fullString += ", "
        fullString += year
        fullString += "  "
        fullString += hour
        fullString += ":"
        fullString += minute
        if(AM){
            fullString += "AM"
        } else {
            fullString += "PM"
        }
        
        return fullString
    }
    
    
    //**********************************************//
    //                                              //
    //  func:   convertCreatedDateToReadable        //
    //                                              //
    //  Desc:   Takes the created_at string and     //
    //          splits it using its delimiters      //
    //          specified in Swift. Returns a       //
    //          rebuilt string in human readable    //
    //          form.                               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func convertCreatedDateToReadable() -> String{
        var AM = true
        var monthName = "Jan"
        let firstSplit = self.created_at.split(separator: "-")
        let year = firstSplit[0]
        let month = firstSplit[1]
        let secondSplit = firstSplit[2].split(separator: "T")
        let day = secondSplit[0]
        let thirdSplit = secondSplit[1].split(separator: ":")
        var hour = String(thirdSplit[0])
        let minute = thirdSplit[1]
        var fullString = ""
        
        if ((Int(hour) ?? 0)! - 12 < 0){
            AM = true
        } else {
            hour = String((Int(hour) ?? 0) - 12)
            AM = false
        }
        
        let monthNum = Int(month) ?? 0
        
        switch(monthNum){
        case 1:
            monthName = "Jan"
            break
        case 2:
            monthName = "Feb"
            break
        case 3:
            monthName = "Mar"
            break
        case 4:
            monthName = "Apr"
            break
        case 5:
            monthName = "May"
            break
        case 6:
            monthName = "Jun"
            break
        case 7:
            monthName = "Jul"
            break
        case 8:
            monthName = "Aug"
            break
        case 9:
            monthName = "Sep"
            break
        case 10:
            monthName = "Oct"
            break
        case 11:
            monthName = "Nov"
            break
        case 12:
            monthName = "Dec"
            break
        default:
            monthName = "Jan"
            break
        }
        
        fullString += "Created at: "
        fullString += monthName
        fullString += " "
        fullString += day
        fullString += ", "
        fullString += year
        fullString += "  "
        fullString += hour
        fullString += ":"
        fullString += minute
        if(AM){
            fullString += "AM"
        } else {
            fullString += "PM"
        }
        
        return fullString
    }
    
}

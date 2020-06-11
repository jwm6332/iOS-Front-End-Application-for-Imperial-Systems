//
//  Quote_ToolUITests.swift
//  Quote ToolUITests
//
//  Created by Corey Franco on 11/1/19.
//  Copyright © 2019 ImperialSystems. All rights reserved.
//

import XCTest

class Quote_ToolUITests: XCTestCase {

    var app : XCUIApplication!
    
    override func setUp()
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //**********************************************//
    //                                              //
    //  func:   testLoginSuccess                    //
    //                                              //
    //  Desc:   Asserts that buttons exist on page  //
    //          and app does not crash on submit    //
    //          with values in fields               //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testLoginSuccess()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
    }
    
    //**********************************************//
    //                                              //
    //  func:   testLoginFail                       //
    //                                              //
    //  Desc:   Asserts that an alert will          //
    //          prompt if nothing in fields         //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testLoginFail()
    {
        let submit = app.buttons["Login"]
        submit.tap()
        let allowButton = app.alerts.buttons["Dismiss"]
        XCTAssertTrue(allowButton.exists)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testProfileSuccess                  //
    //                                              //
    //  Desc:   Asserts that profile matches login  //
    //          username                            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testProfileSuccess()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
        app.tabBars.buttons["Profile"].tap()
        XCTAssertEqual(app.staticTexts["usernamelabel"].label, "admin@isystemsweb.com")
    }
    
      //**********************************************//
      //                                              //
      //  func:   testProfileFail                     //
      //                                              //
      //  Desc:   Asserts that profile username is    //
      //          not empty                           //
      //                                              //
      //  args:                                       //
      //**********************************************//
    func testProfileFail()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
        app.tabBars.buttons["Profile"].tap()
        XCTAssertFalse(app.staticTexts["usernamelabel"].label == "")
    }
    
    //**********************************************//
    //                                              //
    //  func:   testChangeProfileBlank              //
    //                                              //
    //  Desc:   Asserts that profile username and   //
    //          password are not empty              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func testChangeProfileBlank()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["changeAccount"].tap()
        sleep(1)
        app.alerts.buttons["Change Email"].tap()
        sleep(1)
        app.buttons["submit"].tap()
        let allowButton = app.alerts.buttons["Dismiss"]
        XCTAssertTrue(allowButton.exists)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testChangeProfileIncorrect          //
    //                                              //
    //  Desc:   Asserts that profile cannot be      //
    //          changed if two passwords are not    //
    //          the same
    //                                              //
    //  args:                                       //
    //**********************************************//

    func testChangeEmailIncorrect()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["changeAccount"].tap()
        sleep(1)
        app.alerts.buttons["Change Email"].tap()
        let email = app.textFields["email"]
        email.doubleTap()
        email.tap()
        XCTAssertTrue(email.exists)
        email.typeText("test\ntest1\n")
        app.buttons["submit"].tap()
        let allowButton = app.alerts.buttons["Dismiss"]
        XCTAssertTrue(allowButton.exists)
    }
    
    //**********************************************//
    //                                              //
    //  func:   testChangePassword Success          //
    //                                              //
    //  Desc:   Asserts that profile can be         //
    //          changed if two passwords are        //
    //          the same                            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    /*
    func testChangeEmailSuccess()
    {
        let usernametextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("admin@isystemsweb.com")
        XCTAssertEqual(usernametextField.value as! String, "admin@isystemsweb.com")
        let passwordtextField = app.secureTextFields["passwordTextField"]
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        let rememberSwitch = app.switches["rememberme"]
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        let submit = app.buttons["Login"]
        submit.tap()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["changeAccount"].tap()
        let emButton = app.alerts.buttons["Change Email"]
        emButton.tap()
        let email = app.textFields["email"]
        email.doubleTap()
        email.tap()
        email.typeText("test\ntest\ntest\n")
        app.buttons["submit"].tap()
        let allowButton = app.alerts.buttons["Dismiss"]
        allowButton.tap()
        
        sleep(1)
        
        //Change back
        XCTAssertTrue(usernametextField.exists, "Username Text field doesn't exist")
        usernametextField.tap()
        usernametextField.typeText("test")
        XCTAssertEqual(usernametextField.value as! String, "test")
        XCTAssertTrue(passwordtextField.exists, "Password Text field doesn't exist")
        passwordtextField.tap()
        passwordtextField.typeText("test123\n")
        XCTAssertTrue(rememberSwitch.exists, "Switch doesn't exist")
        rememberSwitch.tap()
        submit.tap()
        sleep(2)
        let profbutton = self.app.buttons.matching(identifier: "Profile")
        if profbutton.count > 0 {
            let firstButton = profbutton.element(boundBy: 1)
            firstButton.tap()
        }
        let changeAcc = self.app.buttons.matching(identifier: "changeAccount")
        if changeAcc.count > 0 {
            let firstButton = changeAcc.element(boundBy: 1)
            firstButton.tap()
        }
        email.doubleTap()
        email.tap()
        email.typeText("admin@isystemsweb.com\ntest\ntest\n")
        app.buttons["submit"].tap()
        allowButton.tap()
        XCTAssertFalse(allowButton.exists)
    }*/
}

//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   ViewFileController.swift        //
//                                              //
//  Desc:       Opens a selected file to present//
//              the contents of the file to the //
//              user.                           //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit
import WebKit

class ViewFileController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet var webView: WKWebView! = WKWebView()
    var image_url : String = ""
    @IBOutlet weak var image_title: UINavigationItem!
    
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
        let lr : URL! = URL(string: image_url)
        Activity.center = self.view.center
        self.webView.load(URLRequest(url: lr))
        // add activity indicator
        Activity.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.webView.addSubview(self.Activity)
        self.Activity.startAnimating()
        self.webView.navigationDelegate = self
        self.Activity.hidesWhenStopped = true
    }
    
    //**********************************************//
    //                                              //
    //  func:   webView                             //
    //                                              //
    //  Desc:   Stops the acitivity indicator when  //
    //          the file is finished loading.       //
    //                                              //
    //  args:   webView - WKWebView                 //
    //          navigation - WKNavigation           //
    //**********************************************//
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Activity.stopAnimating()
    }

    //**********************************************//
    //                                              //
    //  func:   webView                             //
    //                                              //
    //  Desc:   Stops the acitivity indicator and   //
    //          populates an error message if the   //
    //          file failed to load                 //
    //                                              //
    //  args:   webView - WKWebView                 //
    //          navigation - WKNavigation           //
    //          error - Error                       //
    //**********************************************//
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Activity.stopAnimating()
        let alert = UIAlertController(title: "Error Loading File", message:
            "Please check your connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
}

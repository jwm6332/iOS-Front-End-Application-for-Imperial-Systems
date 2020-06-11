//
//  ProductCollectionViewController.swift
//  Quote Tool
//
//  Created by Corey Franco on 3/9/20.
//  Copyright © 2020 ImperialSystems. All rights reserved.
//
//****************************************************//
//          Imperial Systems Inc.                     //
//****************************************************//
//                                                    //
//  Filename:   ProductCollectionViewController.swift //
//                                                    //
//  Desc:       Search for file functionality         //
//                                                    //
//  Creation:   03Mar20                               //
//****************************************************//

import UIKit

class ProductCollectionViewController: UICollectionViewController {
    var quote = Quote()
    var make: String = ""
    var product = Product()
    var bundle_delegate:BundleProtocol?
    var quote_delegate:QuoteProtocol?
    var productArray = [Product]()
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
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
        self.navigationItem.title = make
        Activity.center = self.view.center
        Activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.Activity.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.productArray = apiDispatcher.dispatcher.getProductBases(DESC: false, make: self.make)
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.Activity.stopAnimating()
                self?.collectionView.reloadData()
            }
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return productArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FileViewCell
        // Configure the cell
        cell.fileLabel.text = productArray[indexPath.row].name
        //cell.fileLabel.adjustsFontSizeToFitWidth = true
        if productArray[indexPath.row].image != "" {
            let url = URL(string: productArray[indexPath.row].image)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell.fileImage.image = UIImage(data: data)
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                cell.fileImage.image = UIImage(named: "default_image")
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.product = productArray[indexPath.row]
        performSegue(withIdentifier: "specificProductSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "specificProductSegue" {
            if let viewController = segue.destination as? SpecificProductViewController {
                viewController.make = make
                viewController.quote = quote
                viewController.product = product
                viewController.bundle_delegate = bundle_delegate
                viewController.quote_delegate = quote_delegate
            }
        }
    }
    
}

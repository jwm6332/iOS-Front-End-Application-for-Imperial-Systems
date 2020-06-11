//**************************************************//
//          Imperial Systems Inc.                   //
//**************************************************//
//                                                  //
//  Filename:   MakesCollectionViewController.swift //
//                                                  //
//  Desc:       Search for file functionality       //
//                                                  //
//  Creation:   03Mar20                             //
//**************************************************//

import UIKit
struct Make {
    var image: String
    var title: String
    init(image: String, title: String){
        self.image = image
        self.title = title
    }
}
class MakesCollectionViewController: UICollectionViewController {
    
    var quote = Quote()
    var make : String = ""
    var makesArray = [Make]()
    var bundle_delegate:BundleProtocol?
    var quote_delegate:QuoteProtocol?
    
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
        DispatchQueue.global(qos: .default).async {
            self.makesArray.append(Make.init(image: "abort_gate", title: "Abort Gate"))
            self.makesArray.append(Make.init(image: "after_filter_housing", title: "After Filter Housing"))
            self.makesArray.append(Make.init(image: "airlock", title: "Airlock"))
            self.makesArray.append(Make.init(image: "brf", title: "BRF"))
            self.makesArray.append(Make.init(image: "cast_airlock", title: "Cast Airlock"))
            self.makesArray.append(Make.init(image: "cmaxx", title: "CMAXX"))
            self.makesArray.append(Make.init(image: "cmaxx_control_panel", title: "CMAXX Control Panel"))
            self.makesArray.append(Make.init(image: "cmaxx_fan", title: "CMAXX Fan"))
            self.makesArray.append(Make.init(image: "cyclone", title: "Cyclone"))
            self.makesArray.append(Make.init(image: "dust_level_sensor", title: "Dust Level Sensor"))
            self.makesArray.append(Make.init(image: "explosion_isolation_valve", title: "Explosion Isolation Valve"))
            self.makesArray.append(Make.init(image: "shadow", title: "Shadow"))
            self.makesArray.append(Make.init(image: "spark_trap", title: "Spark Trap"))
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.collectionView.reloadData()
            }
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return makesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FileViewCell
        cell.fileLabel.text = makesArray[indexPath.row].title
        cell.fileImage.image = UIImage(named: makesArray[indexPath.row].image)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.make = makesArray[indexPath.row].title
        performSegue(withIdentifier: "selectedMakeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedMakeSegue" {
            if let viewController = segue.destination as? ProductCollectionViewController {
                viewController.make = make
                viewController.quote = quote
                viewController.bundle_delegate = bundle_delegate
                viewController.quote_delegate = quote_delegate
            }
        }
    }
    
}

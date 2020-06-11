//*************************************************//
//             Imperial Systems Inc.               //
//*************************************************//
//                                                 //
//  Filename:   FileCollectionViewController.swift //
//                                                 //
//  Desc:       Pulls a collection of file previews//
//              from the API to display to the user//
//              in a grid format. Each preview is  //
//              selectable for download or opening //
//                                                 //
//  Creation:   03Mar20                            //
//*************************************************//


import UIKit


class FileViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fileImage: UIImageView!
    @IBOutlet weak var fileLabel: UILabel!
    
}
extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}

class FileCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, Protocol {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var filearray = [ProductFile]()
    private var searchedFiles = [ProductFile]()
    private var image_url : String = ""
    private var image_title : String = ""
    var language : String = ""
    var docType : String = ""
    var equipType : String = ""
    var searchCrit : String = ""
    var documentController : UIDocumentInteractionController! = UIDocumentInteractionController()
    
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
        clearButton.isEnabled = false
        searchButton.isEnabled = false
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.filearray = apiDispatcher.dispatcher.getAllProductFiles(DESC: false)
            self.searchedFiles = self.filearray
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.activityIndicator.stopAnimating()
                self?.searchButton.isEnabled = true
                self?.collectionView.reloadData()
            }
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    //**********************************************//
    //                                              //
    //  func:   onSearch                            //
    //                                              //
    //  Desc:   Refines displayed files based on    //
    //          search criteria                     //
    //                                              //
    //  args:   language - String (filter arg)      //
    //          docType - String (filter arg)       //
    //          equipType - String (filter arg)     //
    //          searchCrit - String (filter arg)    //
    //**********************************************//
    func onSearch(language: String, docType: String, equipType: String, searchCrit: String) {
        self.language = language
        self.equipType = equipType
        self.docType = docType
        self.searchCrit = searchCrit
        searchedFiles = filearray
        self.searchForFiles()
        if searchedFiles.count == filearray.count {
            clearButton.isEnabled = false
            searchButton.isEnabled = true
        }
        else {
            clearButton.isEnabled = true
            searchButton.isEnabled = false
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   numberOfSections                    //
    //                                              //
    //  Desc:   Only allows for one container to    //
    //          collection entries                  //
    //                                              //
    //  args:   collectionView - UICollectionView   //
    //**********************************************//
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //**********************************************//
    //                                              //
    //  func:   collectionView                      //
    //                                              //
    //  Desc:   Dynamically sets the number of      //
    //          entries available in the collection //
    //          view based on the file list         //
    //                                              //
    //  args:   collectionView - UICollectionView   //
    //          section - Int                       //
    //**********************************************//
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedFiles.count
    }
    
    //**********************************************//
    //                                              //
    //  func:   collectionView                      //
    //                                              //
    //  Desc:   Populates all entries of the        //
    //          collection view with their relevant //
    //          image and information               //
    //                                              //
    //  args:   collectionView - UICollectionView   //
    //          indexPath - IndexPath (entry index) //
    //**********************************************//
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FileViewCell
        // Configure the cell
        cell.fileLabel.text = searchedFiles[indexPath.row].name
        //cell.fileLabel.adjustsFontSizeToFitWidth = true
        let url = URL(string: searchedFiles[indexPath.row].thumbnail_url)
        DispatchQueue.global().async {
            if self.searchedFiles[indexPath.row].thumbnail_url != "" {
                if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell.fileImage.image = UIImage(data: data)
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    cell.fileImage.image = UIImage(named: "default_image")
                }
            }
        }
        return cell
    }
    
    //**********************************************//
    //                                              //
    //  func:   collectionView                      //
    //                                              //
    //  Desc:   Handles when the user selects a file//
    //          dwg and docx can't be handled       //
    //          natively, and are downloaded.       //
    //          Otherwise, the file is viewed.      //
    //                                              //
    //  args:   collectionView - UICollectionView   //
    //          indexPath - IndexPath               //
    //**********************************************//
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (searchedFiles[indexPath.item].document_url.suffix(3).lowercased() == "dwg" || searchedFiles[indexPath.item].document_url.suffix(4).lowercased() == "docx") {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let url = URL(string: searchedFiles[indexPath.item].document_url)
            self.downloadAndShare(url: url!)
        }
        else{
            image_url = searchedFiles[indexPath.item].document_url
            image_title = searchedFiles[indexPath.item].name
            performSegue(withIdentifier: "fileViewSegue", sender: self)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   prepare                             //
    //                                              //
    //  Desc:   Handles the preparation for when the//
    //          view is about to segue to another   //
    //          view                                //
    //                                              //
    //  args:   segue - UIStoryboardSegue           //
    //          sender - Any                        //
    //**********************************************//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fileViewSegue" {
            if let viewController = segue.destination as? ViewFileController {
                viewController.image_url = image_url
                viewController.image_title.title = image_title
            }
        }
        else if segue.identifier == "searchSegue" {
            if let viewController = segue.destination as? SearchFileViewController {
                //sets the delegate of the next controller to this controller
                viewController.delegate = self
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   downloadAndShare                    //
    //                                              //
    //  Desc:   Handles downloading a selected file //
    //          and provides the user options to    //
    //          open the file with a different app  //
    //          or share it using another app       //
    //                                              //
    //  args:   url - URL                           //
    //**********************************************//
    func downloadAndShare(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.csv")
            do {
                try data.write(to: tmpURL)
                DispatchQueue.main.async {
                    self.documentController.url = tmpURL
                    self.documentController.uti = url.typeIdentifier ?? "public.data, public.content"
                    self.documentController.name = url.localizedName ?? url.lastPathComponent
                    self.activityIndicator.stopAnimating()
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let rect = CGRect(origin: CGPoint.init(x: self.view.frame.width/2, y: self.view.frame.maxY), size: CGSize.zero)
                        self.documentController.presentOptionsMenu(from: rect, in: self.view, animated: true)
                    }
                    else {
                        self.documentController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
                    }
                }
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    //**********************************************//
    //                                              //
    //  func:   handleLongPress                     //
    //                                              //
    //  Desc:   Recognizes a long press on a file to//
    //          then run the downloadAndShare       //
    //          method                              //
    //                                              //
    //  args:   gestureReconizer - UILongPr...izer  //
    //**********************************************//
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: p)
        if let index = indexPath {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let url = URL(string: filearray[index.item].document_url)
            self.downloadAndShare(url: url!)
            
        } else {
            print("Could not find index path")
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   searchForFiles                      //
    //                                              //
    //  Desc:   Recursively filters out files from  //
    //          the collection view that do not meet//
    //          the serach filters                  //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func searchForFiles(){
        //searches for the files in searchArray and removes anything not within search criteria
        for (index, element) in self.searchedFiles.enumerated() {
            if(self.searchCrit != "" && !element.name.lowercased().contains(searchCrit.lowercased()) && !element.name.lowercased().elementsEqual(searchCrit.lowercased())){
                self.searchedFiles.remove(at: index)
                self.searchForFiles()
                break
            }
            if(self.docType != "" && element.document_type.lowercased() != self.docType.lowercased()){
                self.searchedFiles.remove(at: index)
                self.searchForFiles()
                break
            }
            if(self.language != "" && element.language.lowercased() != self.language.lowercased()){
                self.searchedFiles.remove(at: index)
                self.searchForFiles()
                break
            }
            if(self.equipType != "" && element.family.lowercased() != self.equipType.lowercased()){
                self.searchedFiles.remove(at: index)
                self.searchForFiles()
                break
            }
        }
        self.collectionView.reloadData()
    }
    
    //**********************************************//
    //                                              //
    //  func:   clearClicked                        //
    //                                              //
    //  Desc:   Resets all search criteria and      //
    //          reloads the data                    //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func clearClicked(_ sender: Any) {
        self.searchedFiles = self.filearray
        clearButton.isEnabled = false
        searchButton.isEnabled = true
        self.collectionView.reloadData()
    }
    
    //**********************************************//
    //                                              //
    //  func:   helpClicked                         //
    //                                              //
    //  Desc:   Presents a pop-up message to the    //
    //          user with information regarding     //
    //          available actions within the view   //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func helpClicked(_ sender: Any) {
        //How to use files prompt
        let alert = UIAlertController(title: "How to use Files", message:
            "- Click on any file to view it.\n- Long press on any file to see more options.\n- Drawings and word documents require other applications in order to be opened.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
}

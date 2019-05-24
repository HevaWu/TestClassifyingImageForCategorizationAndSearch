/*
See LICENSE folder for this sample’s licensing information.

Abstract:
MasterViewController handles the main view.
*/

import Cocoa

class MasterViewController: NSViewController {

    let collectionItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem")
    let headerViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "HeaderView")
    let detailsViewControllerIdentifier = NSStoryboard.SceneIdentifier("DetailsViewController")
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var progressView: NSView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    let dataSource = DataSource()
    
    var inputURLs = [URL]() {
        didSet {
            guard !inputURLs.isEmpty else {
                return
            }
            self.dataSource.loadData(inputURLs: inputURLs, reportTotal: { (total) in
                DispatchQueue.main.async { [weak self] in
                    self?.progressBar.maxValue = Double(total)
                    self?.progressBar.doubleValue = 0
                    self?.progressView.animator().isHidden = false
                }
            }, reportProgress: { (current) in
                DispatchQueue.main.async { [weak self] in
                    self?.progressBar.doubleValue = Double(current)
                }
            }, completion: {
                DispatchQueue.main.async { [weak self] in
                    self?.progressView.animator().isHidden = true
                    self?.collectionView.reloadData()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide progress view
        progressView.isHidden = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        DispatchQueue.main.async {
            self.selectImages(nil)
        }
    }
    
    @IBAction func selectImages(_ sender: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.message = "Choose images to be classified (folders will be processed recursively)."
        openPanel.prompt = "Choose"
        openPanel.allowedFileTypes = ["public.image"]
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.beginSheetModal(for: view.window!) { (response) in
            if response == .OK {
                openPanel.close()
                self.inputURLs = openPanel.urls
            }
        }
    }
    
    @IBAction func setSearchString(_ sender: NSSearchField) {
        dataSource.performSearch(sender.stringValue) {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
}

extension MasterViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfImages(inSection: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                        withIdentifier: headerViewIdentifier,
                                                        for: indexPath)
        guard let headerView = view as? HeaderView else {
            fatalError("Unexpected header view type.")
        }
        
        let sectionName = dataSource.sectionName(at: indexPath.section)
        headerView.sectionTitle.stringValue = sectionName.formattedCategoryName
        return headerView
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: collectionItemIdentifier, for: indexPath)
        guard let collectionItem = item as? CollectionViewItem else {
            fatalError("Unexpected collection item type.")
        }
        
        let imageFile = dataSource.imageFile(at: indexPath.item, inSection: indexPath.section)
        collectionItem.imageView?.image = imageFile.thumbnail
        collectionItem.textField?.stringValue = imageFile.name
        return collectionItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        guard let viewController = storyboard?.instantiateController(withIdentifier: detailsViewControllerIdentifier) else {
            fatalError("Failed to instantiate \(detailsViewControllerIdentifier)")
        }
        guard let detailsViewController = viewController as? DetailsViewController else {
            fatalError("Unexpected details view controller type.")
        }
        detailsViewController.imageFile = dataSource.imageFile(at: indexPath.item, inSection: indexPath.section)
        present(detailsViewController, animator: DetailsViewControllerAnimator(selectedItemIndexPath: indexPath))
        collectionView.deselectItems(at: indexPaths)
    }
}

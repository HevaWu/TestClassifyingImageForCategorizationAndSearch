/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The DetailsViewController handles the full resolution view with the labels.
*/

import Cocoa

class OpaqueView: NSView {
    override func mouseDown(with event: NSEvent) {
        // Do not propagete mouse down events to underlying views
        return
    }
}

class DetailsViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var overlayView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    
    var imageFile: ImageFile?
    
    var tableRows = [(name: String, confidence: Float)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imgFile = imageFile else {
            return
        }
        imageView.image = NSImage(contentsOf: imgFile.url)
        if !imgFile.categories.isEmpty {
            tableRows.append(("Categories", Float.nan))
            tableRows.append(contentsOf: imgFile.categories.map({ (name, confidence) -> (String, Float) in
                return (name.formattedCategoryName, confidence)
            }).sorted(by: { (row1, row2) -> Bool in
                return row1.confidence > row2.confidence
            }))
        }
        if !imgFile.searchTerms.isEmpty {
            tableRows.append(("Search Terms", Float.nan))
            tableRows.append(contentsOf: imgFile.searchTerms.map({ (name, confidence) -> (String, Float) in
                return (name.formattedCategoryName, confidence)
            }).sorted(by: { (row1, row2) -> Bool in
                return row1.confidence > row2.confidence
            }))
        }
    }
}

class TableCellView: NSTableCellView {
    static let storyboardIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TableCellViewID")
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var confidenceLabel: NSTextField!
}

extension DetailsViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return tableRows[row].confidence.isNaN
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: TableCellView.storyboardIdentifier, owner: self) as? TableCellView else {
            return nil
        }
        let tableRow = tableRows[row]
        cellView.nameLabel.stringValue = tableRow.name
        if tableRow.confidence.isNaN {
            cellView.confidenceLabel.isHidden = true
        } else {
            cellView.confidenceLabel.stringValue = String(format: "%0.2f", tableRow.confidence)
        }
        return cellView
    }
}

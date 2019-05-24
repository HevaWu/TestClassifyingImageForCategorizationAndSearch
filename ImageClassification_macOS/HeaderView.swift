/*
See LICENSE folder for this sample’s licensing information.

Abstract:
HeaderView for the CollectionView providing the custom drawing code
*/

import Cocoa

class HeaderView: NSView {

    @IBOutlet weak var sectionTitle: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(calibratedWhite: 0.9, alpha: 0.8).set()
        dirtyRect.fill(using: .sourceOver)
    }
}

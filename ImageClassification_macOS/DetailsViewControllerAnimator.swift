/*
See LICENSE folder for this sample’s licensing information.

Abstract:
DetailsViewControllerAnimator handling the transition to and from the details view.
*/

import Cocoa

class DetailsViewControllerAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    let indexPath: IndexPath
    var left: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    
    init(selectedItemIndexPath: IndexPath) {
        indexPath = selectedItemIndexPath
    }
    
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        guard let masterViewController = fromViewController as? MasterViewController,
                let detailsViewController = viewController as? DetailsViewController else {
            fatalError("Unexpected view controller types")
        }
        guard let imageView = masterViewController.collectionView.item(at: indexPath)?.imageView else {
            fatalError("Could not find item to animate")
        }

        let masterView = masterViewController.view
        let detailsView = detailsViewController.view
        let srcRect = masterView.convert(imageView.frame, from: imageView.superview)
        
        detailsView.alphaValue = 0
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        masterView.addSubview(detailsView)
        masterViewController.addChild(detailsViewController)
        left = detailsView.leftAnchor.constraint(equalTo: masterView.leftAnchor, constant: srcRect.minX)
        bottom = detailsView.bottomAnchor.constraint(equalTo: masterView.bottomAnchor, constant: -srcRect.minY)
        width = detailsView.widthAnchor.constraint(equalTo: masterView.widthAnchor, constant: srcRect.width - masterView.bounds.width)
        height = detailsView.heightAnchor.constraint(equalTo: masterView.heightAnchor, constant: srcRect.height - masterView.bounds.height)
        NSLayoutConstraint.activate([left!, bottom!, width!, height!])
        
        NSAnimationContext.runAnimationGroup({ (ctx) in
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            left?.animator().constant = 0
            bottom?.animator().constant = 0
            width?.animator().constant = 0
            height?.animator().constant = 0
            detailsView.animator().alphaValue = 1
        })
    }
    
    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        guard let masterViewController = fromViewController as? MasterViewController,
            let detailsViewController = viewController as? DetailsViewController else {
                fatalError("Unexpected view controller types")
        }
        guard let imageView = masterViewController.collectionView.item(at: indexPath)?.imageView else {
            fatalError("Could not find item to animate")
        }

        let masterView = masterViewController.view
        let detailsView = detailsViewController.view
        let dstRect = masterView.convert(imageView.frame, from: imageView.superview)

        NSAnimationContext.runAnimationGroup({ (ctx) in
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            left?.animator().constant = dstRect.minX
            bottom?.animator().constant = -dstRect.minY
            width?.animator().constant = dstRect.width - masterView.bounds.width
            height?.animator().constant = dstRect.height - masterView.bounds.height
            detailsView.animator().alphaValue = 0
        }) {
            detailsView.removeFromSuperview()
            detailsViewController.removeFromParent()
        }
    }
}

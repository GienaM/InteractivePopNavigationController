//
//  InteractivePopNavigationController.swift
//
//  Copyright © 2021 Gienadij Mackiewicz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

open class InteractivePopNavigationController: UINavigationController {
    
    // MARK: - Public attributes
    
    open override var delegate: UINavigationControllerDelegate? {
        /// Whenever the delegate is being set we check if our subclass itself is the delegate (we don’t do anything so the subclass will be set as its own delegate).
        /// If the delegate is of any other class we do not set it as delegate but keep a reference to it in externalDelegate.
        didSet {
            if !(delegate is InteractivePopNavigationController) {
                externalDelegate = delegate
                super.delegate = oldValue
            }
        }
    }
    
    // MARK: - Private properties
    
    /// Boolean value indicating whether navigation controller is currently pushing a new view controller on the stack.
    private var isPushingViewController = false
    
    /// We need to keep UINavigationControllerDelegate set to self to be able to handle isPushingViewController state correctly.
    /// When someone externaly set delegate we need to keep reference to it in this property and forward through it all delegate methods.
    private weak var externalDelegate: UINavigationControllerDelegate?
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Overriden methods
    
    /// Overriden pushViewController method to set isPushingViewController to true.
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension InteractivePopNavigationController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            // Disable pop gesture in three situations:
            // 1) when there less than 2 view controllers on stack.
            // 2) when the pop animation is in progress.
            // 3) when user swipes quickly a couple of times and animations don't have time to be performed.
            return viewControllers.count > 1 && !isPushingViewController
        }
        
        return true
    }
}

// MARK: - UINavigationControllerDelegate

/// We have to foward all delegate methods to external delegate to make it fully functional.
extension InteractivePopNavigationController: UINavigationControllerDelegate {
    
    /// Called when pushed view controller did show - so we can set isPushingViewController back to false.
    open func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool) {
        
        isPushingViewController = false
        externalDelegate?.navigationController?(
            navigationController, didShow: viewController, animated: animated)
    }
    
    open func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController, animated: Bool) {
        
        externalDelegate?.navigationController?(
            navigationController, willShow: viewController, animated: animated)
    }
    
    open func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return externalDelegate?.navigationControllerSupportedInterfaceOrientations?(
            navigationController) ?? visibleViewController?.supportedInterfaceOrientations ?? .all
    }
    
    open func navigationControllerPreferredInterfaceOrientationForPresentation(
        _ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return externalDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(
            navigationController) ?? .portrait
    }
    
    open func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
        return externalDelegate?.navigationController?(
            navigationController, animationControllerFor: operation, from: fromVC, to:toVC)
    }
    
    open func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
        return externalDelegate?.navigationController?(
            navigationController, interactionControllerFor: animationController)
    }
}

import UIKit

open class InteractivePopNavigationController: UINavigationController {
    
    // MARK: - Public attributes
    
    open override var delegate: UINavigationControllerDelegate? {
        /// Whenever the delegate is being set we check if our subclass itself is the delegate (we don’t do anything so the subclass will be set as its own delegate).
        /// If the delegate is of any other class we do not set it as delegate but keep a reference to it in externalDelegate.
        didSet {
            if !(delegate is BaseNavigationController) {
                externalDelegate = delegate
                super.delegate = oldValue
            }
        }
    }
    
    public var transitionHelper = TransitionHelper()
    
    // MARK: - Private properties
    
    /// Boolean value indicating whether navigation controller is currently pushing a new view controller on the stack.
    private var isPushingViewController = false
    
    /// We need to keep UINavigationControllerDelegate set to self to be able to handle isPushingViewController state correctly.
    /// When someone externaly set delegate we need to keep reference to it in this property and forward through it all delegate methods.
    private weak var externalDelegate: UINavigationControllerDelegate?
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Overriden methods
    
    /// Overriden pushViewController method to set isPushingViewController to true.
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - TransitionHelperInterface

extension BaseNavigationController: TransitionHelperInterface {}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
extension BaseNavigationController: UINavigationControllerDelegate {
    
    /// Called when pushed view controller did show - so we can set isPushingViewController back to false.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool) {
        
        isPushingViewController = false
        externalDelegate?.navigationController?(
            navigationController, didShow: viewController, animated: animated)
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController, animated: Bool) {
        
        externalDelegate?.navigationController?(
            navigationController, willShow: viewController, animated: animated)
    }
    
    func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return externalDelegate?.navigationControllerSupportedInterfaceOrientations?(
            navigationController) ?? visibleViewController?.supportedInterfaceOrientations ?? .all
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(
        _ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return externalDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(
            navigationController) ?? .portrait
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
        return externalDelegate?.navigationController?(
            navigationController, animationControllerFor: operation, from: fromVC, to:toVC)
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
        return externalDelegate?.navigationController?(
            navigationController, interactionControllerFor: animationController)
    }
}

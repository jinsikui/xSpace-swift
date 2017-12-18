//
//  QtFullscreenPopGesture.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/24.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    private var qt_popGestureRecognizerDelegate: _QTFullscreenPopGestureRecognizerDelegate {
        guard let delegate = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_popGestureRecognizerDelegate) as? _QTFullscreenPopGestureRecognizerDelegate else {
            let popDelegate = _QTFullscreenPopGestureRecognizerDelegate()
            popDelegate.navigationController = self
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_popGestureRecognizerDelegate, popDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return popDelegate
        }
        return delegate
    }
    
    public class func qt_exchangePushViewController() {
        // Inject "-pushViewController:animated:"
        DispatchQueue.once(token: "com.UINavigationController.MethodSwizzling", block: {
            let originalMethod = class_getInstanceMethod(self, #selector(pushViewController(_:animated:)))
            let swizzledMethod = class_getInstanceMethod(self, #selector(qt_pushViewController(_:animated:)))
            method_exchangeImplementations(originalMethod, swizzledMethod)
        })
    }
    
    @objc private func qt_pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.qt_fullscreenPopGestureRecognizer) == false {
            
            // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
            self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(self.qt_fullscreenPopGestureRecognizer)
            
            // Forward the gesture events to the private handler of the onboard gesture recognizer.
            let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? Array<NSObject>
            let internalTarget = internalTargets?.first?.value(forKey: "target")
            let internalAction = NSSelectorFromString("handleNavigationTransition:")
            if let target = internalTarget {
                self.qt_fullscreenPopGestureRecognizer.delegate = self.qt_popGestureRecognizerDelegate
                self.qt_fullscreenPopGestureRecognizer.addTarget(target, action: internalAction)
                
                // Disable the onboard gesture recognizer.
                self.interactivePopGestureRecognizer?.isEnabled = false
            }
        }
        
        // Handle perferred navigation bar appearance.
        self.qt_setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)
        
        // Forward to primary implementation.
        self.qt_pushViewController(viewController, animated: animated)
    }
    
    public func qt_setupViewControllerBasedNavigationBarAppearanceIfNeeded(_ appearingViewController: UIViewController) {
        
        if !self.qt_viewControllerBasedNavigationBarAppearanceEnabled {
            return
        }
        
        let blockContainer = _QTViewControllerWillAppearInjectBlockContainer() { [weak self] (_ viewController: UIViewController, _ animated: Bool) -> Void in
            self?.setNavigationBarHidden(viewController.qt_prefersNavigationBarHidden, animated: animated)
        }
        
        // Setup will appear inject block to appearing view controller.
        // Setup disappearing view controller as well, because not every view controller is added into
        // stack by pushing, maybe by "-setViewControllers:".
        appearingViewController.qt_willAppearInjectBlockContainer = blockContainer
        let disappearingViewController = self.viewControllers.last
        if let vc = disappearingViewController {
            if vc.qt_willAppearInjectBlockContainer == nil {
                vc.qt_willAppearInjectBlockContainer = blockContainer
            }
        }
    }
    
    /// The gesture recognizer that actually handles interactive pop.
    public var qt_fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        guard let pan = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer else {
            let panGesture = UIPanGestureRecognizer()
            panGesture.maximumNumberOfTouches = 1;
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_fullscreenPopGestureRecognizer, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return panGesture
        }
        return pan
    }
    
    /// A view controller is able to control navigation bar's appearance by itself,
    /// rather than a global way, checking "fd_prefersNavigationBarHidden" property.
    /// Default to true, disable it if you don't want so.
    public var qt_viewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            guard let bools = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_viewControllerBasedNavigationBarAppearanceEnabled) as? Bool else {
                self.qt_viewControllerBasedNavigationBarAppearanceEnabled = true
                return true
            }
            return bools
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_viewControllerBasedNavigationBarAppearanceEnabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

fileprivate typealias _QTViewControllerWillAppearInjectBlock = (_ viewController: UIViewController, _ animated: Bool) -> Void

fileprivate class _QTViewControllerWillAppearInjectBlockContainer {
    var block: _QTViewControllerWillAppearInjectBlock?
    init(_ block: @escaping _QTViewControllerWillAppearInjectBlock) {
        self.block = block
    }
}

extension UIViewController {
    
    fileprivate var qt_willAppearInjectBlockContainer: _QTViewControllerWillAppearInjectBlockContainer? {
        get {
            return objc_getAssociatedObject(self, RuntimeKey.KEY_qt_willAppearInjectBlockContainer) as? _QTViewControllerWillAppearInjectBlockContainer
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_willAppearInjectBlockContainer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public class func qt_exchangeViewWillAppear() {
        
        DispatchQueue.once(token: "com.UIViewController.MethodSwizzling", block: {
            var originalMethod = class_getInstanceMethod(self, #selector(viewWillAppear(_:)))
            var swizzledMethod = class_getInstanceMethod(self, #selector(qt_viewWillAppear(_:)))
            method_exchangeImplementations(originalMethod, swizzledMethod)
            originalMethod = class_getInstanceMethod(self, #selector(viewDidLoad))
            swizzledMethod = class_getInstanceMethod(self, #selector(qt_viewDidLoad))
            method_exchangeImplementations(originalMethod, swizzledMethod)
        })
    }
    
    @objc private func qt_viewDidLoad(){
        // Forward to primary implementation
        self.qt_viewDidLoad()
        
        if(self.navigationController != nil){
            // if self controller is root, the navigation controller's pushViewController method will not be called, so set up logic here
            if(self.navigationController!.viewControllers.last == self){
                self.navigationController!.qt_setupViewControllerBasedNavigationBarAppearanceIfNeeded(self)
            }
        }
    }
    
    @objc private func qt_viewWillAppear(_ animated: Bool) {
        // Forward to primary implementation.
        self.qt_viewWillAppear(animated)
        
        if let block = self.qt_willAppearInjectBlockContainer?.block {
            block(self, animated)
        }
    }
    
    /// Whether the interactive pop gesture is disabled when contained in a navigation stack.
    public var qt_interactivePopDisabled: Bool {
        get {
            guard let bools = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_interactivePopDisabled) as? Bool else {
                return false
            }
            return bools
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_interactivePopDisabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// Indicate this view controller prefers its navigation bar hidden or not,
    /// checked when view controller based navigation bar's appearance is enabled.
    /// Default to false, bars are more likely to show.
    public var qt_prefersNavigationBarHidden: Bool {
        get {
            guard let bools = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_prefersNavigationBarHidden) as? Bool else {
                return false
            }
            return bools
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_prefersNavigationBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// Max allowed initial distance to left edge when you begin the interactive pop
    /// gesture. 0 by default, which means it will ignore this limit.
    public var qt_interactivePopMaxAllowedInitialDistanceToLeftEdge: Double {
        get {
            guard let doubleNum = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_interactivePopMaxAllowedInitialDistanceToLeftEdge) as? Double else {
                return 0.0
            }
            return doubleNum
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_interactivePopMaxAllowedInitialDistanceToLeftEdge, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
}

private class _QTFullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let navigationC = self.navigationController else {
            return false
        }
        
        // Ignore when no view controller is pushed into the navigation stack.
        guard navigationC.viewControllers.count > 1 else {
            return false
        }
        
        // Disable when the active view controller doesn't allow interactive pop.
        guard let topViewController = navigationC.viewControllers.last else {
            return false
        }
        guard !topViewController.qt_interactivePopDisabled else {
            return false
        }
        
        // Ignore pan gesture when the navigation controller is currently in transition.
        guard let trasition = navigationC.value(forKey: "_isTransitioning") as? Bool else {
            return false
        }
        guard !trasition else {
            return false
        }
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        // Ignore when the beginning location is beyond max allowed initial distance to left edge.
        let beginningLocation = panGesture.location(in: panGesture.view)
        let maxAllowedInitialDistance = topViewController.qt_interactivePopMaxAllowedInitialDistanceToLeftEdge
        guard maxAllowedInitialDistance <= 0 || Double(beginningLocation.x) <= maxAllowedInitialDistance else {
            return false
        }
        
        // Prevent calling the handler when the gesture begins in an opposite direction.
        let translation = panGesture.translation(in: panGesture.view)
        guard translation.x > 0 else {
            return false
        }
        
        return true
    }
}

fileprivate struct RuntimeKey {
    static let KEY_qt_willAppearInjectBlockContainer
        = UnsafeRawPointer(bitPattern: "KEY_qt_willAppearInjectBlockContainer".hashValue)
    static let KEY_qt_interactivePopDisabled
        = UnsafeRawPointer(bitPattern: "KEY_qt_interactivePopDisabled".hashValue)
    static let KEY_qt_prefersNavigationBarHidden
        = UnsafeRawPointer(bitPattern: "KEY_qt_prefersNavigationBarHidden".hashValue)
    static let KEY_qt_interactivePopMaxAllowedInitialDistanceToLeftEdge
        = UnsafeRawPointer(bitPattern: "KEY_qt_interactivePopMaxAllowedInitialDistanceToLeftEdge".hashValue)
    static let KEY_qt_fullscreenPopGestureRecognizer
        = UnsafeRawPointer(bitPattern: "KEY_qt_fullscreenPopGestureRecognizer".hashValue)
    static let KEY_qt_popGestureRecognizerDelegate
        = UnsafeRawPointer(bitPattern: "KEY_qt_popGestureRecognizerDelegate".hashValue)
    static let KEY_qt_viewControllerBasedNavigationBarAppearanceEnabled
        = UnsafeRawPointer(bitPattern: "KEY_qt_viewControllerBasedNavigationBarAppearanceEnabled".hashValue)
    static let KEY_qt_scrollViewPopGestureRecognizerEnable
        = UnsafeRawPointer(bitPattern: "KEY_qt_scrollViewPopGestureRecognizerEnable".hashValue)
}

extension UIScrollView: UIGestureRecognizerDelegate {
    
    public var qt_scrollViewPopGestureRecognizerEnable: Bool {
        get {
            guard let bools = objc_getAssociatedObject(self, RuntimeKey.KEY_qt_scrollViewPopGestureRecognizerEnable) as? Bool else {
                return false
            }
            return bools
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.KEY_qt_scrollViewPopGestureRecognizerEnable, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    //UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.qt_scrollViewPopGestureRecognizerEnable, self.contentOffset.x <= 0, let gestureDelegate = otherGestureRecognizer.delegate {
            if gestureDelegate.isKind(of: _QTFullscreenPopGestureRecognizerDelegate.self) {
                return true
            }
        }
        return false
    }
}

extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

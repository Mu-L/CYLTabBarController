//
//  CYLLOTAnimationView.swift
//  CYLTabBarController
//
//  Created by 菜鸽途讯 on 2023/6/27.
//

import UIKit
import Lottie

@objcMembers
open class CYLLOTAnimationView: UIView {
    
    var aniFilePath: String?
    var aniView: LottieAnimationView?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        aniView?.frame = self.bounds
    }
    
    @objc public init(filePath: String? = nil) {
        super.init(frame: .zero)
        self.aniFilePath = filePath
        if let aFilePath = filePath {
            aniView = LottieAnimationView(filePath: aFilePath)
            aniView!.isUserInteractionEnabled = false
            aniView!.contentMode = .scaleToFill
            aniView!.clipsToBounds = false
            self.addSubview(aniView!)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func animationProgress(_ progress: CGFloat){
        aniView?.currentProgress = progress
    }
    
    @objc public func forceDrawingUpdate() {
        aniView?.forceDisplayUpdate()
    }
    
    @objc public func play() {
        aniView?.play()
    }
    
    @objc public func stop() {
        aniView?.stop()
    }
}

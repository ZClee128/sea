//
//  AZLoadingOverlay.swift

//
//  Created by Joeyoung on 2022/9/1.
//

import UIKit

let kAZLoadingOverlay_W            = 80.0
let kAZLoadingOverlay_cornerRadius = 14.0
let kAZLoadingOverlay_alpha        = 0.9
let kBackgroundView_alpha     = 0.6
let kAnimationInterval        = 0.2
let kTransformScale           = 0.9

open class AZLoadingOverlay: UIView {
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var shared = AZLoadingOverlay()
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.addSubview(activityIndicator)
    }
    open override func copy() -> Any { return self }
    open override func mutableCopy() -> Any { return self }
    
    class func show() {
        show(superView: nil)
    }
    class func show(superView: UIView?) {
        if superView != nil {
            DispatchQueue.main.async {
                AZLoadingOverlay.shared.frame = superView!.bounds
                AZLoadingOverlay.shared.activityIndicator.center = AZLoadingOverlay.shared.center
                superView!.addSubview(AZLoadingOverlay.shared)
            }
        } else {
            DispatchQueue.main.async {
                AZLoadingOverlay.shared.frame = UIScreen.main.bounds
                AZLoadingOverlay.shared.activityIndicator.center = AZLoadingOverlay.shared.center
                AZAppEnvironment.p_l2a8().addSubview(AZLoadingOverlay.shared)
            }
        }
        AZLoadingOverlay.shared.p_ca3f1()
    }
    class func dismiss() {
        AZLoadingOverlay.shared.p_cb6a4()
    }
    
    private func p_ca3f1() {
        DispatchQueue.main.async {
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
            self.activityIndicator.alpha = 0
            UIView.animate(withDuration: kAnimationInterval) {
                self.backgroundColor = UIColor(white: 0, alpha: kBackgroundView_alpha)
                self.activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.activityIndicator.alpha = kAZLoadingOverlay_alpha
                self.activityIndicator.startAnimating()
            }
        }
    }
    private func p_cb6a4() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: kAnimationInterval) {
                self.backgroundColor = UIColor(white: 0, alpha: 0)
                self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
                self.activityIndicator.alpha = 0
            } completion: { finished in
                self.activityIndicator.stopAnimating()
                AZLoadingOverlay.shared.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Lazy load
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.bounds = CGRect(x: 0, y: 0, width: kAZLoadingOverlay_W, height: kAZLoadingOverlay_W)
        indicator.center = self.center
        indicator.backgroundColor = .black
        indicator.layer.cornerRadius = kAZLoadingOverlay_cornerRadius
        indicator.layer.masksToBounds = true
        return indicator
    }()
}

extension AZLoadingOverlay {
    class func toast(_ str: String?) {
        toast(str, showTime: 1)
    }
    class func toast(_ str: String?, showTime: CGFloat) {
        guard str != nil else { return }
        let titleLab = UILabel()
        titleLab.backgroundColor = UIColor(white: 0, alpha: 0.8)
        titleLab.layer.cornerRadius = 5
        titleLab.layer.masksToBounds = true
        titleLab.text = str
        titleLab.font = .systemFont(ofSize: 16)
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        titleLab.textColor = .white
        AZAppEnvironment.p_l2a8().addSubview(titleLab)
        let size = titleLab.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat(MAXFLOAT)))
        titleLab.center = AZAppEnvironment.p_l2a8().center
        titleLab.bounds = CGRect(x: 0, y: 0, width: size.width + 30, height: size.height + 30)
        titleLab.alpha = 0
        UIView.animate(withDuration: 0.2) {
            titleLab.alpha = 1
        } completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
                UIView.animate(withDuration: 0.2) {
                    titleLab.alpha = 1
                } completion: { finished in
                    titleLab.removeFromSuperview()
                }
            }
        }
    }
}

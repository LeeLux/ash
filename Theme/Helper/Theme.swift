//
//  Theme.swift
//  Theme
//
//  Created by Laziest on 2020/7/29.
//  Copyright © 2020 LaziestLee. All rights reserved.
//

import Foundation
import UIKit

let themeChangedIdentify = "themeChangedIdentify"
var hooksKey: String = "hooksKey"
var imageHookKey: String = "imageHookKey"

public typealias ImageHoock = () -> UIImage?

enum ThemeType: Int {
    case normal = 0 // 正常模式
    case ash // 灰色模式
}

open class ThemeHelper: NSObject {
    static let helper = ThemeHelper()
    private var tempTheme: ThemeType = .normal
    var theme: ThemeType {
        get {
            return tempTheme
        }
        set {
            tempTheme = newValue
            NotificationCenter.default.post(name: NSNotification.Name(themeChangedIdentify), object: nil)
        }
    }
}


public extension NSObject {

    var hooks: Dictionary<String, Any>? {
        set(newValue) {
            objc_setAssociatedObject(self, &hooksKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            NotificationCenter.default.addObserver(self, selector: #selector(themeNeedUpdate), name: NSNotification.Name(themeChangedIdentify), object: nil)
        }
        get {
            guard let info = objc_getAssociatedObject(self, &hooksKey) as? Dictionary<String, Any> else {
                let dic = Dictionary<String, Any>()
                objc_setAssociatedObject(self, &hooksKey, dic, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                NotificationCenter.default.addObserver(self, selector: #selector(themeNeedUpdate), name: NSNotification.Name(themeChangedIdentify), object: nil)
                return dic
            }
            return info
        }
    }

    @objc func themeNeedUpdate() {
        if let hookers = hooks {
            for sequence in hookers.enumerated() {
                let sel = NSSelectorFromString(sequence.element.key)
                if let imageHoock = sequence.element.value as? ImageHoock {
                    UIView.animate(withDuration: 0.3) {
                        if self.responds(to: sel) {
                            self.perform(sel, with: imageHoock())
                        }
                    }
                } else {
                }
            }
        }
    }
}

public extension UIImage {
   static func theme_imageNamed(name: String) -> ImageHoock {
        return ({ () -> UIImage? in
            var image: UIImage? = UIImage(named: name)
            switch ThemeHelper.helper.theme {
            case .ash:
                if let img = image{
                    image = img.grayImage()
                }
                break
            default:
                break
            }
            return image
        })
    }
    func grayImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil , width: Int(self.size.width), height: Int(self.size.height),bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        context?.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let cgImage = context!.makeImage()
        let grayImage = UIImage.init(cgImage: cgImage!)
        return grayImage
    }
}

public extension UIImageView {
    var theme_image: ImageHoock? {
        set(newValue) {
            image = newValue?()
            objc_setAssociatedObject(self, &imageHookKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if let image = theme_image {
                hooks?.updateValue(image, forKey: NSStringFromSelector(#selector(setter: UIImageView.image)))
            }
        }
        get {
            return objc_getAssociatedObject(self, &imageHookKey) as? ImageHoock
        }
    }
    
}

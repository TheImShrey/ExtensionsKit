import UIKit
import RxSwift
import RxCocoa

/**
Property wrapper provides a blurred background effect for a given UIView. It adds a UIVisualEffectView with a specified UIBlurEffect.Style behind the wrapped view.

 - Parameter wrappedValue: The view to which the blurred background effect will be applied.
 - Parameter style: The style of the blur effect (e.g., `.light`, `.dark`, `.extraLight`).

# Example #
    
  ```@BlurredBackground(style: .light)
    let awesomeLabel = UILabel()
    // Now `awesomeLabel` has a blurred background effect.
 ```
 */
@propertyWrapper
struct BlurredBackground<Content> where Content: UIView {
    var disposeBag = DisposeBag()
    private let blurEffectView: UIVisualEffectView
    
    var wrappedValue: Content {
        didSet {
            self.manageHierarchy()
            disposeBag = DisposeBag()
            self.trackHierarchy()
        }
    }
    
    init(wrappedValue: Content, style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.wrappedValue = wrappedValue
        self.resetHierarchy()
        self.trackHierarchy()
    }
    
    func resetHierarchy() {
        if let superview = wrappedValue.superview {
            blurEffectView.cornerRadius = wrappedValue.cornerRadius
            
            if superview != blurEffectView.superview {
                blurEffectView.snp.removeConstraints()
                superview.insertSubview(blurEffectView, belowSubview: wrappedValue)
                blurEffectView.edgesEqual(to: wrappedValue)
            }
        } else {
            blurEffectView.cornerRadius = 0
            blurEffectView.snp.removeConstraints()
            blurEffectView.removeFromSuperview()
        }
    }
    
    func trackHierarchy() {
        self.wrappedValue.rx.methodInvoked(#selector(UIView.didMoveToSuperview))
            .subscribe(onNext: { [self] _ in
                /// Notice: No retain cycle`self` as this is struct
                self.resetHierarchy()
            })
            .disposed(by: self.disposeBag)
    }
}

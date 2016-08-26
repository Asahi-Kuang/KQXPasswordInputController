//
//  Created by Qingxu Kuang on 16/8/25.
//  Copyright © 2016年 Asahi Kuang. All rights reserved.
//

import UIKit


class KQXPasswordInputTipView: UIView {
    
    
    @IBOutlet weak private var symbolImage: UIImageView!
    @IBOutlet weak private var tipContentLabel: UILabel!
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    let tipHeight:CGFloat = 64.0
    
    // 图片bundle
    /*
    let imageBundlePath = Bundle.main.path(forResource: "KQXPasswordInputResource", ofType: "bundle")
    var imageBundle: Bundle? {
        return Bundle(path: imageBundlePath!)
    }
     */
    // bundle内图片路径
    let imagePathPrefix: String = "KQXPasswordInputResource.bundle/Contents/Resources/"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x:0.0,y:0.0,width:screenWidth,height:tipHeight)
    }
    
    // MARK: - Methods
    func showTipCorrect(content:String) {
        configure(type: "correct", content: content)
    }
    
    func showTipIncorrect(content:String) {
        configure(type: "incorrect", content: content)
    }
    
    private func configure(type:String, content:String) {
        let imageName = type == "correct" ? "tip_green@2x" : "tip_red@2x"
        let image = UIImage.init(named: imagePathPrefix + imageName)
        self.symbolImage.image = image
        self.tipContentLabel.text = content
    }
    
}

//=====>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//MARK: -                           南 无 阿 弥 陀 佛                                       //
//=====>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


protocol KQXPasswordInputControllerDelegate: NSObjectProtocol {
    func passwordInputControllerDidDismissed()
}

enum KQXPasswordInputStyle:Int {
    case KQXPasswordInputWithDescription = 0
    case KQXPasswordInputWithoutDescription
}

class KQXPasswordInputController: UIViewController {
    
    @IBOutlet weak private var bodyView          : UIView!
    @IBOutlet weak private var closeButton       : UIButton!
    @IBOutlet weak private var titleLabel        : UILabel!
    @IBOutlet weak private var subtitleLabel     : UILabel!
    @IBOutlet weak private var descriptionLabel  : UILabel!
    @IBOutlet weak private var passwordInputField: UITextField!
    @IBOutlet weak private var symbolView        : UIView!
    
    // tip
    lazy private var tipView = Bundle.main.loadNibNamed("KQXPasswordInputTipView", owner: nil, options: nil)?.first as! KQXPasswordInputTipView
    
    var bodyLayer:CALayer{ return bodyView.layer }
    var symbolLayer:CALayer{ return symbolView.layer }
    var keyWindow: UIWindow{ return UIApplication.shared.keyWindow! }
    
    var numberOfPassword:Int = 4
    var widthOfCircle:CGFloat = 10
    
    var titleString = "输入标题"
    var subtitle = "输入副标题"
    var descriptionString:String?
    
    var style = KQXPasswordInputStyle(rawValue:1)!
    
    var circleArray = [CAShapeLayer]()
    var spotArray   = [CAShapeLayer]()
    
    // 协议
    weak var delegate: KQXPasswordInputControllerDelegate!
    
    // 输入完成closure
    var inputComplete: ((password: String)->Void)?
    
    // keywindow 负责承载tipview
    var keywindow:UIWindow {
        return UIApplication.shared.keyWindow!
    }
    
    // MARK: - initial method
    init(title:String, subtitle:String, passwordInputStyle style:KQXPasswordInputStyle) {
        self.titleString = title
        self.subtitle = subtitle
        self.style = style
        
        super.init(nibName: "KQXPasswordInputController", bundle: nil)
        
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        
        bodyView.makeCornerRadius(cornerRadius: 10.0, masksToBounds: false)
        
        drawCircle()
        drawSpot()
        originalConfigure()
        
        passwordInputField.addTarget(self, action: #selector(passwordInputFieldDidChanged(sender:)), for: .editingChanged)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 让输入框成为第一响应
        passwordInputField.becomeFirstResponder()
        
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        drawLineOnTop()
        
        // 圆点布局
        for i in 0..<circleArray.count {
            
            let symbolWidth = symbolView.width
            let symbolHeight = symbolView.heigth
            let perWidth = symbolWidth / numberOfPassword.cgFloatValue
            let position_x = (perWidth - widthOfCircle)/2+perWidth*i.cgFloatValue
            let position_y = (symbolHeight-widthOfCircle)/2
            let circle: CAShapeLayer = circleArray[i]
            let spot: CAShapeLayer = spotArray[i]
            circle.position = CGPoint(x:position_x,y:position_y)
            spot.position = CGPoint(x:position_x,y:position_y)
        }
        
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setDescriptionString(descriptionString:String) {
        self.descriptionString = descriptionString
    }
    
    func clearContents() {
        if passwordInputField.text!.lengthOfBytes(using: String.Encoding.utf8) != 0 {
            passwordInputField.text = nil
        }
        for spot in spotArray {
            spot.isHidden = true
        }
    }
    
    func showRightTipWithContent(content:String) {
        tipView.showTipCorrect(content: content)
        animationForTipViewShown()
    }
    
    func showErrorTipWithContent(content:String) {
        tipView.showTipIncorrect(content: content)
        animationForTipViewShown()
    }
    
    private func animationForTipViewShown() {
        keyWindow.addSubview(tipView)
        tipView.transform = CGAffineTransform.init(translationX: 0.0, y: -tipView.heigth)
        UIView.animate(withDuration: 0.3, animations: {
            () in
            self.tipView.transform = CGAffineTransform.init(translationX: 0.0, y: 0.0)
            }, completion: {
                (finished) in
                self.delay(2.0, closure: {
                    self.animationForTipViewDismiss()
                })
        })
    }
    
    private func animationForTipViewDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            () in
            self.tipView.transform = CGAffineTransform.init(translationX: 0.0, y: -self.tipView.heigth)
            }, completion: {
                (finished) in
                self.tipView.removeFromSuperview()
        })
    }
    
    private func originalConfigure() {
        
        titleLabel.text = titleString
        subtitleLabel.text = subtitle
        descriptionLabel.text = descriptionString
        descriptionLabel.isHidden = style.rawValue == 1 ? true : false
        
    }
    
    
    private func drawCircle() {
        for _ in 0..<numberOfPassword {
            let circleBezier = UIBezierPath.init(ovalIn: CGRect(x:0.0,y:0.0,width:widthOfCircle,height:widthOfCircle))
            let circleShape = CAShapeLayer()
            circleShape.path = circleBezier.cgPath
            circleShape.lineWidth = 1.0
            circleShape.strokeColor = UIColor.black.cgColor
            circleShape.fillColor = UIColor.clear.cgColor
            symbolLayer.insertSublayer(circleShape, at: 0)
            circleArray.append(circleShape)
        }
    }
    
    private func drawSpot() {
        for _ in 0..<numberOfPassword {
            let spotBezier = UIBezierPath.init(ovalIn: CGRect(x:0.0,y:0.0,width:widthOfCircle,height:widthOfCircle))
            let spotShape = CAShapeLayer()
            spotShape.path = spotBezier.cgPath
            spotShape.fillColor = UIColor.black.cgColor
            spotShape.isHidden = true
            symbolLayer.insertSublayer(spotShape, at: 0)
            spotArray.append(spotShape)
        }
    }
    
    private func drawLineOnTop() {
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x:0.0, y:closeButton.heigth+10))
        bezier.addLine(to: CGPoint(x:bodyView.width, y:closeButton.heigth+10))
        bezier.close()
        let shape = CAShapeLayer()
        shape.path = bezier.cgPath
        shape.strokeColor = UIColor.lightGray.cgColor
        shape.lineWidth = 0.35
        bodyLayer.insertSublayer(shape, at: 0)
    }
    
    private func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func dismissPasswordInputController() {
        self.dismiss(animated: false, completion: {
            () in
            self.delegate!.passwordInputControllerDidDismissed()
        })
    }
    
    // MARK: - selectors
    func passwordInputFieldDidChanged(sender:UITextField) {
        
        let length = sender.text!.lengthOfBytes(using: String.Encoding.utf8)
        
        if length > numberOfPassword {
            // 如果密码输入超过限制位数 截断
            
            let idx = sender.text!.index(sender.text!.startIndex, offsetBy: numberOfPassword)
            sender.text = sender.text!.substring(to: idx)
            return
        }
        
        for idx in 0..<spotArray.count {
            let spot: CAShapeLayer = spotArray[idx]
            spot.isHidden = idx < length ? false : true
        }
        
        if length == numberOfPassword {
            // 密码输入完成,闭包抛出密码
            delay(0.5, closure: {
                self.inputComplete!(password:sender.text!)
            })
        }
    }
    
    @IBAction func closePasswordInputController() {
        dismissPasswordInputController()
    }
}

// MARK: - extension
extension UIView {
    var heigth:CGFloat{
        return self.frame.size.height
    }
    var width:CGFloat{
        return self.frame.size.width
    }
    
    func makeCornerRadius(cornerRadius radius:CGFloat, masksToBounds:Bool) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = masksToBounds
    }
}

extension Int {
    var cgFloatValue:CGFloat {
        return CGFloat(self)
    }
}

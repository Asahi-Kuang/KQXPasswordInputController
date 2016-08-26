//
//  ViewController.swift
//  KQXPasswordInput_Swift
//
//  Created by Qingxu Kuang on 16/8/25.
//  Copyright © 2016年 Asahi Kuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KQXPasswordInputControllerDelegate {

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    // MARK: - Methods
    @IBAction func callOutPasswordInputController(sender:UIButton) {
        let passwordInputView = KQXPasswordInputController.init(title: "请输入支付密码", subtitle: "向 邝叔叔 转账", passwordInputStyle: .KQXPasswordInputWithDescription)
        passwordInputView.setDescriptionString(descriptionString: "￥88.88")
        passwordInputView.delegate = self
        passwordInputView.inputComplete = {
        
            $0 == "1234" ? passwordInputView.showRightTipWithContent(content: "密码正确") : passwordInputView.showErrorTipWithContent(content: "密码错误")
//            passwordInputView.dismissPasswordInputController()
            
        }
    
        self.present(passwordInputView, animated: false, completion: nil)
    }
    
    // MARK: - delegate
    func passwordInputControllerDidDismissed() {
        print("passwordInputController did dismissed.")
    }

}



import UIKit

@IBDesignable
class CommentFieldView: UIView, UITextFieldDelegate {

    var view: UIView!
    
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var getUpdatedText:(String)->() = { string in
        
    }
    
  
    
  
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.txtField.delegate = self
        self.txtField.setLeftPaddingPoints(10)
        self.txtField.setRightPaddingPoints(5)
        self.txtField.backgroundColor = UIColor.white
        self.txtField.layer.cornerRadius = 3
        self.txtField.layer.masksToBounds = true
        self.sendBtn.layer.cornerRadius = 3
        self.sendBtn.layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        
        
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CommentFieldView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
//        if let text = textField.text, let textRange = Range(range, in: text) {
//            let updatedText = text.replacingCharacters(in: textRange,
//                                                       with: string)
//            let str = updatedText.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
//
//            if str.count < 15 {
//                textField.text = str
//                getUpdatedText(str)
//            }
//
//            return false
//        }
        return true
    }

    @IBAction func btnAction(_ sender: UIButton) {
        getUpdatedText(self.txtField.text ?? "")
    }
    
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

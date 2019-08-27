
import UIKit

@IBDesignable
class MobileNumberView: UIView, UITextFieldDelegate {

    var view: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var txtField: UITextField!
    
    var getUpdatedText:(String)->() = { string in
        
    }
    
    
    @IBInspectable var titleText: String = "Title"{
        didSet{
            self.titleLbl.text = titleText
            
        }
    }
    @IBInspectable var placeholderText: String = "Title"{
        didSet{
            self.txtField.placeholder = placeholderText
            
        }
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
        let nib = UINib(nibName: "MobileNumberView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            let str = updatedText.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
            
            if str.count < 15 {
                textField.text = str
                getUpdatedText(str)
            }
            
            return false
        }
        return true
    }

    @IBAction func btnAction(_ sender: UIButton) {
        self.txtField.becomeFirstResponder()
    }
}


import UIKit

@IBDesignable
class ChipView: UIView {

    var view: UIView!
    
    @IBOutlet weak var titileLEadingConstant: NSLayoutConstraint!
    @IBOutlet weak var accessoryImgWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var accessoryImgView: UIImageView!
    
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
    
        self.accessoryImgView.isHidden  =   true
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
        let nib = UINib(nibName: "ChipView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
 

    @IBAction func btnAction(_ sender: UIButton) {
        getUpdatedText(self.titleLbl.text ?? "")
    }
}

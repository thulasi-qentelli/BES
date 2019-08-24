
import UIKit

@IBDesignable
class SideMenuCell: UIView {

    var view: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var accessoryImgView: UIImageView!
    
    var btnClickAction:()->(Void) = {
        
    }
    
    @IBInspectable var title : String = "" {
        didSet {
            self.titleLbl?.text = title
        }
    }
    
    @IBInspectable var backImage: UIImage = UIImage(named: "home") ?? UIImage() {
        didSet{
            self.accessoryImgView.image = backImage
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
        let nib = UINib(nibName: "SideMenuCell", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        btnClickAction()
    }
    
}

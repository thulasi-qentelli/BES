
import UIKit
import SDWebImage

@IBDesignable
class ProfileDisplayView: UIView {
    
    var view: UIView!
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileImgPlaceholderView: UIImageView!
    @IBOutlet weak var textLbl: UILabel!
    
    var user:User? {
        didSet {
            if let urlString = AppController.shared.user?.pic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                if let url  = URL(string: urlString){
                    profileImgView.sd_setImage(with:url, completed: nil)
                    profileImgPlaceholderView.isHidden = true
                }
            }
            textLbl.text = user?.getName()
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
        
        self.profileImgView.layer.cornerRadius  =   20
        self.profileImgView.layer.borderWidth   =   2.0
        self.profileImgView.layer.borderColor   =   UIColor.white.cgColor
        self.profileImgView.layer.masksToBounds =   true
  
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
        let nib = UINib(nibName: "ProfileDisplayView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
    }
    
}

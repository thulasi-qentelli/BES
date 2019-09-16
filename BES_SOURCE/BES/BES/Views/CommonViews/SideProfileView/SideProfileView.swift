
import UIKit
import SDWebImage

@IBDesignable
class SideProfileView: UIView {
    
    var view: UIView!
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileImgPlaceholderView: UIImageView!
    @IBOutlet weak var profileSubIcon: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    
    var editTapped:()->Void = {
        
    }
    
    var user:User? {
        didSet {
            profileImgView.image = nil
            profileImgPlaceholderView.isHidden = false
            if let urlString = AppController.shared.user?.pic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                if let url  = URL(string: urlString){
                    profileImgView.sd_setImage(with:url, completed: nil)
                    profileImgPlaceholderView.isHidden = true
                    
                }
            }
            nameLbl.text = user?.getName()
            roleLbl.text = user?.getRole()
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
        
        self.profileImgView.layer.cornerRadius  =   50
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
        let nib = UINib(nibName: "SideProfileView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        editTapped()
    }
    
}

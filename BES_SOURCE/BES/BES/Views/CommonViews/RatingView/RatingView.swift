
import UIKit

@IBDesignable
class RatingView: UIView, UITextFieldDelegate {

    var view: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBInspectable var titleText: String = "Title"{
        didSet{
            self.titleLbl.text = titleText
            
        }
    }

    var selectedRating = 0 {
        didSet{
            for i in 1...5 {
                if let kbutton = self.viewWithTag(i) as? UIButton {
                    if i <= selectedRating {
                        kbutton.isSelected = true
                    }
                    else {
                        kbutton.isSelected = false
                    }
                }
            }
        }
    }
    
    @IBInspectable var rating: Int = 0{
        didSet{
            self.selectedRating = rating
            for i in 1...5 {
                if let kbutton = self.viewWithTag(i) as? UIButton {
                    if i <= rating {
                        kbutton.isSelected = true
                    }
                    else {
                        kbutton.isSelected = false
                    }
                }
            }
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
        let nib = UINib(nibName: "RatingView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    @IBAction func btnAction(_ sender: UIButton) {
        self.selectedRating = sender.tag
        
        for i in 1...5 {
            if let kbutton = self.viewWithTag(i) as? UIButton {
                if i <= sender.tag {
                    kbutton.isSelected = true
                }
                else {
                    kbutton.isSelected = false
                }
            }
        }
    }
    
}


import UIKit

@IBDesignable
class TableSectionHeaderView: UIView, UITextFieldDelegate {

    var view: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var filterView: UIView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var title: String =  "" {
        didSet{
            self.titleLbl.text = title
        }
    }
    
    @IBInspectable var hideFilterView: Bool = false{
        didSet{
            self.filterView.isHidden = true            
        }
    }
    
    
    var filterBtnAction:()->Void = {
        
    }
    
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
        let nib = UINib(nibName: "TableSectionHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    @IBAction func filterBtnAction(_ sender: UIButton) {
        filterBtnAction()
    }
}

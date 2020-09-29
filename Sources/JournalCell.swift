
import UIKit

class JournalCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var ScreenOneVC: ScreenOneViewController?
    
    var place: Place!
    
    @IBAction func editButtonPressed(_ sender: Any) {
        ScreenOneVC?.editPressed(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(place: Place) {
        locationLabel.text = place.name
        textView.text = place.userDescription
        self.place = place
        
    }
    
}

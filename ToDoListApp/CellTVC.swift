//
//  CellTVC.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/2/24.
//

import UIKit

class CellTVC: UITableViewCell {
    
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var catLabel: UILabel!
    
    
    // For check button handler (Assinged in TVC)
    var checkButtonHandler: (() -> Void)?;
    
    @IBAction func buttonDown(_ sender: Any) {
        checkButtonHandler?();
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

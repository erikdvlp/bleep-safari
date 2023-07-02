//
//  PresetLists_TableViewCell.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import UIKit

class PresetLists_TableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var listDescLabel: UILabel!
    @IBOutlet weak var installButton: UIButton!

    // MARK: - Class variables

    var listForRow: List?

    // MARK: - Override functions

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Touch event handlers

    @IBAction func installButtonTouch(_ sender: Any) {
        if let listForRow = self.listForRow {
            let listMgr = ListManager()
            listMgr.installListToMemory(targetList: listForRow)
            self.installButton.isEnabled = false
        }
    }

}

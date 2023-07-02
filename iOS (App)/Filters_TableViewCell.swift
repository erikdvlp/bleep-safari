//
//  Filters_UITableViewCell.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import UIKit

class Filters_TableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var listActiveSwitch: UISwitch!

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

    @IBAction func listActiveSwitchTouch(_ sender: Any) {
        if let listForRow = self.listForRow {
            let listMgr = ListManager()
            listMgr.userEnableDisableListInMemory(targetList: listForRow, isEnabled: listActiveSwitch.isOn)
        }
    }

}

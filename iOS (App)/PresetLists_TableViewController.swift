//
//  PresetLists_TableViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import UIKit

class PresetLists_TableViewController: UITableViewController {

    // MARK: - Class variables

    let listMgr = ListManager()
    var publicLists: [List] = []
    var installedLists: [List] = []

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.publicLists = listMgr.getAllPublicLists()
        self.installedLists = listMgr.getInstalledListsFromMemory()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publicLists.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Handle rendering of rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "presetListCell", for: indexPath)
        guard let presetCell = cell as? PresetLists_TableViewCell else { return cell }
        let list = self.publicLists[indexPath.row]

        presetCell.listForRow = list
        presetCell.listNameLabel.text = list.name
        presetCell.listDescLabel.text = list.description
        presetCell.installButton.isEnabled = !self.installedLists.contains(list)

        return cell
    }
}

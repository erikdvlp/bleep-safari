//
//  FiltersMenu_ViewController.swift
//  bleep-safari (macOS)
//
//  Created by erikdvlp on 2023-03-13.
//

import Cocoa

class FiltersMenu_ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - Outlets

    @IBOutlet weak var tableView: NSTableView!

    // MARK: - Class variables

    let listMgr = ListManager()
    var installedLists: [List] = []

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUserSettings()
        self.installedLists = listMgr.getInstalledListsFromMemory()
    }

    // MARK: - State control

    func initUserSettings() {
        let defaults = UserDefaults(suiteName: "group.bleep-safari")
        let userSettingsInitValues = [
            "installedLists": listMgr.getDefaultInstalledLists() as [List],
            "filterStyle": 0,
            "showFirstLetter": false,
            "wordsFiltered": 0,
            "appFirstRun": true
        ] as [String: Any]
        // swiftlint:disable:next force_unwrapping
        for (key, value) in userSettingsInitValues where defaults!.object(forKey: key) == nil {
            if let listValue = value as? [List] {
                defaults?.set(listMgr.jsonEncodeLists(targetLists: listValue), forKey: key)
            } else {
                defaults?.set(value, forKey: key)
            }
        }
    }

    // MARK: - Table view

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.installedLists.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let filtersMenuCell = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "filtersMenuCell"),
            owner: self
        ) as? FiltersMenu_TableCellView else { return nil }

        let list = self.installedLists[row]
        filtersMenuCell.listName.stringValue = list.name

        return filtersMenuCell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.tableView.selectedRow
        let selectedList = self.installedLists[selectedRow]
        let package = ["selectedList": selectedList]
        NotificationCenter.default.post(
            name: Notification.Name("filtersListSelectionChanged"),
            object: self,
            userInfo: package
        )
    }

}

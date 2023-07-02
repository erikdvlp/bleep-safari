//
//  FilterStyle_TableViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-21.
//

import UIKit

class FilterStyle_TableViewController: UITableViewController {

    // MARK: - Class variables

    let logMgr = LogManager(senderName: String(describing: FilterStyle_TableViewController.self))
    let numberOfFilters = 3

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
        self.selectRowFromMemory()
    }

    // MARK: - State control

    func selectRowFromMemory() {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        let filterStyle = defaults.integer(forKey: "filterStyle")
        let index = IndexPath(row: filterStyle, section: 0)
        tableView.selectRow(at: index, animated: true, scrollPosition: .bottom)
        self.addCheckmarkToRow(selectedIndex: index)
    }

    func changeFilterStyleInMemory(index: Int) {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        defaults.set(index, forKey: "filterStyle")
    }

    // MARK: - View control

    func addCheckmarkToRow(selectedIndex: IndexPath) {
        for currRowIndex in 0...self.numberOfFilters - 1 {
            let currRow = IndexPath(row: currRowIndex, section: 0)
            let currCell = tableView.cellForRow(at: currRow)
            if currRowIndex == selectedIndex.row {
                currCell?.accessoryType = .checkmark
            } else {
                currCell?.accessoryType = .none
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfFilters
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addCheckmarkToRow(selectedIndex: indexPath)
        self.changeFilterStyleInMemory(index: indexPath.row)
    }

}

//
//  Filters_TableViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import StoreKit
import UIKit

class Filters_TableViewController: UITableViewController {

    // MARK: - Class variables

    let listMgr = ListManager()
    let logMgr = LogManager(senderName: String(describing: Filters_TableViewController.self))
    var installedLists: [List] = []

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUserSettings()
        self.installedLists = listMgr.getInstalledListsFromMemory()
        self.showTutorial()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.installedLists = listMgr.getInstalledListsFromMemory()
        self.tableView.reloadData()
        self.reviewPrompt()
    }

    // Send data to new view controller on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showViewEditList" {
            if let viewListViewController = segue.destination as? ViewList_ViewController {
                guard let segueData = sender as? [String: Any] else { return }
                guard let viewType = segueData["viewType"] as? String else { return }
                viewListViewController.viewType = viewType
                if let listForRow = segueData["listForRow"] as? List {
                    viewListViewController.listForRow = listForRow
                }
            }
        }
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

    // MARK: - View control

    // Pop-up view to explain how to enable the extension
    func showTutorial() {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        let appFirstRun = defaults.bool(forKey: "appFirstRun")
        if appFirstRun {
            self.performSegue(withIdentifier: "showTutorial", sender: nil)
            defaults.set(false, forKey: "appFirstRun")
        }
    }

    // Pop-up view to request an App Store rating or review
    func reviewPrompt() {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        let appFirstRun = defaults.bool(forKey: "appFirstRun")
        if !appFirstRun {
            SKStoreReviewController.requestReview()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.installedLists.count
    }

    // Handle rendering of rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterListCell", for: indexPath)
        guard let filterCell = cell as? Filters_TableViewCell else { return cell }

        let list = self.installedLists[indexPath.row]
        filterCell.listForRow = list
        filterCell.listNameLabel.text = list.name
        filterCell.listActiveSwitch.isOn = list.userEnabled

        return cell
    }

    // Handle deletion of row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listMgr.uninstallListFromMemory(targetList: self.installedLists[indexPath.row])
            self.installedLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Handle row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segueData = [
            "viewType": "view",
            "listForRow": self.installedLists[indexPath.row]
        ] as [String: Any]
        self.performSegue(withIdentifier: "showViewEditList", sender: segueData)
    }

    // MARK: - Touch event handlers

    @IBAction func addButtonTouch(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        alertController.view.tintColor = UIColor(named: "AccentColor")
        alertController.addAction(
            .init(title: "Add preset list", style: .default) { _ in
                self.performSegue(withIdentifier: "showPresetLists", sender: nil)
            }
        )
        alertController.addAction(
            .init(title: "Create custom list", style: .default) { _ in
                let segueData = [
                    "viewType": "new",
                    "listForRow": nil
                ]
                self.performSegue(withIdentifier: "showViewEditList", sender: segueData)
            }
        )
        alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
}

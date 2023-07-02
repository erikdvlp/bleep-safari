//
//  ViewList_ViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import UIKit

class ViewList_ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var regexSwitch: UISwitch!
    @IBOutlet weak var listValuesTextField: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var editSaveButton: UIBarButtonItem!

    // MARK: - Class variables

    var viewType = "view"
    var listForRow: List?

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleComponents()
        self.setControlsByViewType()
    }

    // MARK: - State control

    func createListFromInput() -> List? {
        if let listName = self.listNameTextField.text {
            if let listValuesRaw = self.listValuesTextField.text {
                if !listName.isEmpty && !listValuesRaw.isEmpty {
                    let listValuesLines = listValuesRaw.split(whereSeparator: \.isNewline)
                    var listValues: [String] = []
                    for value in listValuesLines {
                        listValues.append(String(value))
                    }
                    let newList = List(
                        id: self.listForRow?.id ?? UUID.init().uuidString,
                        name: listName,
                        description: self.listForRow?.description ?? nil,
                        values: listValues,
                        isPublic: false,
                        isRegex: self.regexSwitch.isOn,
                        isEncoded: false,
                        userEnabled: true
                    )
                    return newList
                }
            }
        }
        return nil
    }

    // MARK: - View control

    func styleComponents() {
        listValuesTextField.layer.cornerRadius = 4
        listValuesTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        listValuesTextField.layer.borderWidth = 0.5
        listValuesTextField.clipsToBounds = true
    }

    func enableDisableControls(isEnabled: Bool) {
        self.listNameTextField.isEnabled = isEnabled
        self.regexSwitch.isEnabled = isEnabled
        self.listValuesTextField.isEditable = isEnabled

        let enabledTextColor: UIColor = .black
        let disabledTextColor: UIColor = .systemGray
        if isEnabled {
            self.listNameTextField.textColor = enabledTextColor
            self.listValuesTextField.textColor = enabledTextColor
        } else {
            self.listNameTextField.textColor = disabledTextColor
            self.listValuesTextField.textColor = disabledTextColor
        }
    }

    func setControlsByViewType() {
        if self.viewType == "new" {
            self.navBar.title = "New custom list"
            self.editSaveButton.title = "Save"
            self.enableDisableControls(isEnabled: true)
        } else if self.viewType == "edit" {
            self.navBar.title = "Edit list"
            self.editSaveButton.title = "Save"
            self.enableDisableControls(isEnabled: true)
        } else { // "view"
            self.navBar.title = "View list"
            self.editSaveButton.title = "Edit"
            self.enableDisableControls(isEnabled: false)
            if let list = self.listForRow {
                self.listNameTextField.text = list.name
                self.regexSwitch.isOn = list.isRegex
                if list.isEncoded {
                    self.listValuesTextField.text = "(Values are hidden for this list)"
                } else {
                    self.listValuesTextField.text = list.values.joined(separator: "\n")
                }
                self.editSaveButton.isEnabled = !list.isPublic
            }
        }
    }

    // MARK: - Touch event handlers

    @IBAction func editSaveButtonTouch(_ sender: Any) {
        if self.viewType == "new" {
            if let newList = self.createListFromInput() {
                let listMgr = ListManager()
                listMgr.installListToMemory(targetList: newList)
                _ = navigationController?.popViewController(animated: true)
            }
        } else if self.viewType == "edit" {
            if let newList = self.createListFromInput() {
                let listMgr = ListManager()
                listMgr.replaceListInMemory(targetList: newList)
                _ = navigationController?.popViewController(animated: true)
            }
        } else { // "view"
            self.viewType = "edit"
            self.setControlsByViewType()
        }
    }

}

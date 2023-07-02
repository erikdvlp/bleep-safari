//
//  Settings_TableViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import MessageUI
import UIKit

class Settings_TableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    // MARK: - Outlets

    @IBOutlet weak var showFirstLetterSwitch: UISwitch!

    // MARK: - Class variables

    let logMgr = LogManager(senderName: String(describing: Settings_TableViewController.self))

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
    }

    // MARK: - State control

    func setShowFirstLetterSwitchState() {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        let showFirstLetter = defaults.bool(forKey: "showFirstLetter")
        showFirstLetterSwitch.isOn = showFirstLetter
    }

    // MARK: - View control

    // Handler for when mail compose controller is dismissed
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowsInSection = [
            0: 2,
            1: 2
        ]
        // swiftlint:disable:next force_unwrapping
        return rowsInSection[section]!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - Touch event handlers

    @IBAction func showFirstLetterSwitchChange(_ sender: UISwitch) {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        defaults.set(sender.isOn, forKey: "showFirstLetter")
    }

    @IBAction func feedbackButtonTouch(_ sender: Any) {
        // Handle condition no email accounts on user's device
        if !MFMailComposeViewController.canSendMail() {
            let alertController = UIAlertController(
                title: "No email",
                message: "You have to set up email on your device first.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            let supportEmail = "email@support.com"
            let ticketNum = Int.random(in: 1000..<9999)
            let emailComposeView = MFMailComposeViewController()
            emailComposeView.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
            emailComposeView.setToRecipients([supportEmail])
            emailComposeView.setSubject("Bleep ticket #\(ticketNum)")
            emailComposeView.setMessageBody("(Please write your feedback here.)", isHTML: false)
            self.present(emailComposeView, animated: true, completion: nil)
        }
    }

}

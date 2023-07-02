//
//  Statistics_ViewController.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-21.
//

import UIKit

class Statistics_ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var wordsFilteredView: UIView!
    @IBOutlet weak var wordsEnabledView: UIView!
    @IBOutlet weak var wordsFilteredLabel: UILabel!
    @IBOutlet weak var wordsEnabledLabel: UILabel!

    // MARK: - Class variables

    let logMgr = LogManager(senderName: String(describing: Statistics_ViewController.self))

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleComponents()
        self.updateLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLabels()
    }

    // MARK: - View control

    func styleComponents() {
        let allViews = [self.wordsFilteredView, self.wordsEnabledView]
        for view in allViews {
            view?.layer.cornerRadius = 4
            view?.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
            view?.layer.borderWidth = 0.5
            view?.clipsToBounds = true
        }
    }

    func updateLabels() {

        func formatNumber(number: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let formatted = formatter.string(from: number as NSNumber) {
                return formatted
            } else {
                return String(number)
            }
        }

        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return
        }
        let listMgr = ListManager()

        let wordsFiltered = defaults.integer(forKey: "wordsFiltered")
        let wordsEnabled = listMgr.getNumWordsEnabled()

        self.wordsFilteredLabel.text = formatNumber(number: wordsFiltered)
        self.wordsEnabledLabel.text = formatNumber(number: wordsEnabled)
    }

}

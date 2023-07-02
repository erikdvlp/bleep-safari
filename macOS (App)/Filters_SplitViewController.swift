//
//  Filters_SplitViewController.swift
//  bleep-safari (macOS)
//
//  Created by erikdvlp on 2023-03-13.
//

import Cocoa

class Filters_SplitViewController: NSSplitViewController {

    // MARK: Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObservers()
    }

    // MARK: Notifications

    func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleListSelectionChange(_:)),
            name: Notification.Name("filtersListSelectionChanged"),
            object: nil
        )
    }

    // Listens for menu selection changes
    @objc
    private func handleListSelectionChange(_ notification: Notification) {
        if let selectedList = notification.userInfo?["selectedList"] {
            print(selectedList)
        }
    }

}

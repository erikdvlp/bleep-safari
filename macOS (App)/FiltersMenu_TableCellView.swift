//
//  FiltersMenu_TableCellView.swift
//  bleep-safari (macOS)
//
//  Created by erikdvlp on 2023-03-13.
//

import Cocoa

class FiltersMenu_TableCellView: NSTableCellView {

    // MARK: - Outlets

    @IBOutlet weak var listName: NSTextField!

    // MARK: - Override functions

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

}

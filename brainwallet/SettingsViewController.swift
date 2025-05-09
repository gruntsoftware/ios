//
//  SettingsViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-30.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//
import LocalAuthentication
import UIKit

class SettingsViewController: UITableViewController {
	init(sections: [String], rows: [String: [Setting]], optionalTitle _: String? = nil) {
		self.sections = sections
		if UserDefaults.isBiometricsEnabled {
			self.rows = rows
		} else {
			var tempRows = rows
			let biometricsLimit = LAContext.biometricType() == .face ? "Face ID Spending Limit" : "Touch ID Spending Limit"
			tempRows["Manage"] = tempRows["Manage"]?.filter { $0.title != biometricsLimit }
			self.rows = tempRows
		}

		customTitle = "Settings"
		titleLabel.text = "Settings"
		super.init(style: .plain)
	}

	private let sections: [String]
	private var rows: [String: [Setting]]
	private let cellIdentifier = "CellIdentifier"
	var titleLabel = UILabel(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)
	let customTitle: String
	private var walletIsEmpty = true

	override func viewDidLoad() {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48.0))


        headerView.backgroundColor = BrainwalletUIColor.surface
		tableView.backgroundColor = BrainwalletUIColor.surface
        titleLabel = UILabel(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)

		headerView.addSubview(titleLabel)
		titleLabel.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: C.padding[2], bottom: 0, right: 0))
		tableView.register(SeparatorCell.self, forCellReuseIdentifier: cellIdentifier)
		tableView.tableHeaderView = headerView
		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .none

		//addCustomTitle()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func numberOfSections(in _: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows[sections[section]]?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

		if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
			cell.textLabel?.text = setting.title
			cell.textLabel?.font = .customBody(size: 16.0)

			let label = UILabel(font: .customMedium(size: 14.0), color: BrainwalletUIColor.content)
			label.text = setting.accessoryText?()
			label.sizeToFit()
			cell.accessoryView = label
			if sections[indexPath.section] == "About" {
				cell.selectionStyle = .none
			}

            cell.textLabel?.textColor = BrainwalletUIColor.content
			
		}
		return cell
	}

	override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
		let label = UILabel(font: .customBold(size: 14.0), color: BrainwalletUIColor.content)
		let separator = UIView()
        
        view.backgroundColor = BrainwalletUIColor.surface

		view.addSubview(label)
		switch sections[section] {
		case "About":
			label.text = "About"
		case "Wallet":
			label.text = "Wallet"
		case "Manage":
			label.text = "Manage"
		case "Support":
			label.text = "Support"
		case "Blockchain":
			label.text = "Blockchain"
		default:
			label.text = ""
		}

        separator.backgroundColor = BrainwalletUIColor.gray
        
		view.addSubview(separator)
		separator.constrain([
			separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			separator.heightAnchor.constraint(equalToConstant: 1.0),
		])

		label.constrain([
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -4.0),
		])

		return view
	}

	override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
			setting.callback()
		}
	}

	override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
		return 47.0
	}

	override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
		return 48.0
	}

    @available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

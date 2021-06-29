//
//  SearchViewController.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/06/29.
//

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinate: CLLocationCoordinate2D?)
}

final class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    private var locations: [Location] = []
    
    private lazy var tableY: CGFloat = {
        let tableY: CGFloat = textField.frame.origin.y + textField.frame.size.height + 8
        return tableY
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "どこへ行く？"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private lazy var textField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "目的地を入力してください"
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .tertiarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 48))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 8, y: 8, width: label.frame.size.width, height: label.frame.size.height)
        textField.frame = CGRect(x: 8, y: 16 + label.frame.size.height, width: view.frame.size.width - 16, height: 48)
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height - tableY)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            LocationManager.shared.findLocation(with: text) { [weak self] (locations) in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coordinate = locations[indexPath.row].coodinate
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
}

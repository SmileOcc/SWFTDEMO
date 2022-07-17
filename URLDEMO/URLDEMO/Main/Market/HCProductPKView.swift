//
//  HCProductPKView.swift
//  URLDEMO
//
//  Created by odd on 7/17/22.
//

import UIKit

class HCProductPKView: UIView {

    lazy var categoryTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.blue
        table.bounces = false
        table.delegate = self
        table.dataSource = self
        table.register(HCProductPKCategloryCell.self, forCellReuseIdentifier: NSStringFromClass(HCProductPKCategloryCell.self))
        return table
    }()
    
    lazy var detilTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.lightGray
        table.bounces = false

        table.delegate = self
        table.dataSource = self
        table.register(HCProductPKCategloryCell.self, forCellReuseIdentifier: NSStringFromClass(HCProductPKCategloryCell.self))

        return table
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(categoryTable)
        addSubview(detilTable)
        
        categoryTable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(100)
        }
        
        detilTable.snp.makeConstraints { make in
            make.left.equalTo(self.categoryTable.snp.right)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.right.equalTo(self.snp.right)
        }
    }
    
}

extension HCProductPKView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        13
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HCProductPKCategloryCell.self), for: indexPath)
        cell.backgroundColor = UIColor.purple
        
        if tableView == detilTable {
            cell.backgroundColor = UIColor.green
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

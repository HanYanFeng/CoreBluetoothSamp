//
//  HFTableView.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/6/5.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
protocol HFTableViewDelegate: NSObjectProtocol {
    
    func hftableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?

    func hftableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    
    func hftableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    
    func hftableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
}

/// 可快速完成tableVeiw的消息传递
class HFTableView: UITableView {
    var registName: [String] = []
    var tipAction: ((_ indexPath: IndexPath ,_ btnIndex: Int , _ object: AnyObject?) -> Void)!
    var dataSourceArr: [[AnyObject]]?
    var dataFormatArr: [[String]]?
    var hfDelegate: HFTableViewDelegate?
    init(frame: CGRect, style: UITableViewStyle ,tipAction: @escaping ((_ indexPath: IndexPath ,_ btnIndex: Int,_ object: AnyObject?) -> Void) ) {
        super.init(frame: frame, style: style)
        self.tipAction = tipAction
        self.registName = []
        self.delegate = self
        self.dataSource = self
    }
    
    func reloadData(dataSourceArr: [[AnyObject]] ,dataFormatArr: [[String]]) {
        self.dataSourceArr = dataSourceArr
        self.dataFormatArr = dataFormatArr
        judge()
        reloadData()
    }
    
    /// 判断传入的数据是否符合格式
    func judge(){
        if self.dataFormatArr?.count != self.dataSourceArr?.count {
            assert(false)
        }
        var index:Int = 0
        for arr in self.dataFormatArr! {
            if arr.count != dataSourceArr?[index].count {
                assert(false)
            }
            index += 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HFTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.hfDelegate == nil {
            return 0.001
        }else{
            return (self.hfDelegate?.hftableView(self, heightForFooterInSection: section))!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.hfDelegate == nil {
            return 0.001
        }else{
            return (self.hfDelegate?.hftableView(self, heightForHeaderInSection: section))!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.hfDelegate == nil {
            return nil
        }else{
            return self.hfDelegate?.hftableView(self, viewForFooterInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.hfDelegate == nil {
            return nil
        }else{
            return self.hfDelegate?.hftableView(self, viewForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tipAction(indexPath,-1,self.dataSourceArr?[indexPath.section][indexPath.row])
        self.deselectRow(at: indexPath, animated: true)
    }
}

extension HFTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSourceArr = self.dataSourceArr {
            return dataSourceArr[section].count
        }else{
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let dataSourceArr = self.dataSourceArr {
            return dataSourceArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HFTableViewCell = tableView.dequeueReusableCell(withIdentifier: (self.dataFormatArr?[indexPath.section][indexPath.row])!, for: indexPath) as! HFTableViewCell
        let anyObject = (self.dataSourceArr?[indexPath.section][indexPath.row])!
        self.rowHeight = cell.addData(anyObject: anyObject)
        return cell
    }
}

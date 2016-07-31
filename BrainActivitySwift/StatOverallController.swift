//
//  StatOverallController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 28/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//


class StatTableController : NSObject, UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    @objc func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height))
        headerView.text = "Concentration/Attention"
        //print(tableView.frame.size.width)
        headerView.tag = section
        headerView.layer.borderWidth = 1
        
        //let headerTapped = UITapGestureRecognizer (target: self, action:#selector(SessionsVC.sectionHeaderTapped(_:)))
        // headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    @objc func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 50
    }
    
    @objc func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1
    }
    
}
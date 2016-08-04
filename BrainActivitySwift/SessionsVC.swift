//
//  SessionsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 04/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionsVC : BatteryBarVC ,UITableViewDataSource,UITableViewDelegate {
    var arrayForBool : [Bool]! = []
    let sectionHeight : CGFloat = 60.0
    var sessionList = [String]()
    var context : Context!
    var sectionList = [Int:SessionHeaderView]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        arrayForBool = [Bool](count :4,repeatedValue : false)
        
        //self.tableView.registerClass(SessionCellContainer.self, forCellReuseIdentifier: "Cell")
        //self.tableView.registerClass(SessionHeadCell.self, forCellReuseIdentifier: "Session")
        tableView.delegate = self
        tableView.dataSource = self
        context = Context(idToken: userDefaults.valueForKey(UserDefaultsKeys.idToken)! as! String, accessToken: userDefaults.valueForKey(UserDefaultsKeys.accessToken)! as!  String,URL : "http://cloudin.incoding.biz/Dispatcher/Query")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let req = GetSessionsQuery<GetSessionsQueryResponse>(context: context)
        req.On(success: { (resp : Array<GetSessionsQueryResponse>) in
            for r in resp {
                self.sessionList.append(r.StartDate)
            }
            self.arrayForBool = [Bool](count :resp.count,repeatedValue : false)
            self.tableView.reloadData()
            }, error: {})
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sessionList.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = SessionHeaderView(dateText: sessionList[section],moodText: sessionList[section],frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height))
        let collapsed = arrayForBool[section]
        if collapsed {
            headerView.image.image = UIImage(named: "minus")
            headerView.moodLabel.textColor = Colors.orange
        }else {
            headerView.image.image = UIImage(named: "plus")
            headerView.moodLabel.textColor = Colors.gray
        }
        //print(tableView.frame.size.width)
        headerView.tag = section
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = Colors.gray.CGColor
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(SessionsVC.sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)
        sectionList[section] = headerView
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let indexPath  = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            var collapsed = arrayForBool[indexPath.section]
            collapsed       = !collapsed
            arrayForBool[indexPath.section] = collapsed
            //reload specific section animated
            self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let Cell : UITableViewCell
        
        if indexPath.row == 0 {
             Cell = self.tableView.dequeueReusableCellWithIdentifier("SessionCellHeadId")!
            let cell : SessionHeadCell = Cell as! SessionHeadCell
            cell.TimeLabel.text = "04:44:13"
        }else {
            Cell = self.tableView.dequeueReusableCellWithIdentifier("SessionCellContainerId")!
            let cell : SessionCellContainer = Cell as! SessionCellContainer
            let crcl = cell.CircleImg.image
            cell.CircleImg.image = crcl?.imageWithRenderingMode(.AlwaysTemplate)
            cell.CircleImg.tintColor = UIColor.whiteColor()
            cell.ActivityImage.image = UIImage(named: "activiti-working")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.ActivityImage.tintColor = UIColor.whiteColor()
        }
        
        
        //        view.activityImageView.image = UIImage(named: "activity-working")?.imageWithRenderingMode(.AlwaysTemplate)
        //let view = UIView()
        
        if indexPath.row % 2 == 0 {
            Cell.contentView.backgroundColor = Colors.orange
        }else {
            Cell.contentView.backgroundColor = Colors.dorange
        }

        Cell.layer.borderColor = Colors.orange.CGColor
        Cell.layer.borderWidth = 1
        
        return Cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(arrayForBool[section])
        {
            return 5
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if arrayForBool[indexPath.section]{
            return sectionHeight
        }
        return 0
    }
}

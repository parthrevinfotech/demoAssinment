//
//  TableViewController.swift
//  testAssignment
//
//  Created by Hiteshi on 21/10/19.
//  Copyright © 2019 demo. All rights reserved.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController {

    private var reachability: NetworkReachabilityManager!
    
    let refreshController = UIRefreshControl.init()
    
    var arrData : [model] = [model]()
    var pageCount : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability = NetworkReachabilityManager.init()
        reachability.startListening()
        self.pageCount = 1
        self.fetchDatafromAPI(page: pageCount)
        
        self.refreshController.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshController)
        
    }
    
    @objc func handleRefresh(){
          self.refreshController.endRefreshing()
          self.pageCount = 1
          self.fetchDatafromAPI(page: pageCount)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 50
        return arrData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.row == self.arrData.count - 3){
            self.fetchDatafromAPI(page: self.pageCount + 1)
        }
    
        let cellVi = Int (tableView.frame.height/85)
       
        self.navigationItem.title = "VisibleCell \(cellVi) arrayCount = \(self.arrData.count)"
        
        
        if let cell : CustomCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCellTableViewCell", for: indexPath) as? CustomCellTableViewCell{
            
            let obj = arrData[indexPath.row]
            
            // Configure the cell...
            cell.lblTitle.text = obj.strTitle
            cell.lblSubTitle.text = obj.strSubTitle
            
            return cell
            
        }else{
           return UITableViewCell()
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension TableViewController {
    
    func fetchDatafromAPI(page : Int = 1) {
        
        if !reachability.isReachable {
            refreshController.endRefreshing()
            let alert : UIAlertController =  UIAlertController.init(title: "No network", message: "No Network Connecction", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            self.navigationController?.visibleViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        if (page == 1){
            self.arrData.removeAll()
            self.tableView.reloadData()
        }
        
        
        let strUrl = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(page)"
    
        Alamofire.request(strUrl, method: .get, parameters: nil ,encoding: JSONEncoding.default).responseJSON {
            response in
            self.refreshController.endRefreshing()
            switch response.result {
            case .success:
                print(response)
                do{
                    
                    if let dict = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]{
                        self.parseAPIResponce(dict: dict, page: page)
                    }
                    
                }catch let err {
                   print(err)
                }
                break
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func parseAPIResponce(dict : [String : Any], page : Int) {
    
        if let arr = dict["hits"] as? [[String:Any]]{
            self.pageCount = page
            for dataDict in arr {
                let obj : model = model.init(dict: dataDict)
                self.arrData.append(obj)
            }
        }
        self.tableView.reloadData()
        if self.arrData.count > 0 {
            print("\n data count = \(self.arrData.count)")
        }else{
            print("\n no data found")
        }
    }
    
 
}

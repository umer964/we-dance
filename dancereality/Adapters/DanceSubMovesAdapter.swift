//
//  DanceSubMovesAdapter.swift
//  dancereality
//
//  Created by Saad Khalid on 08.08.22.
//

import Foundation
import UIKit

public class DanceSubMovesAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    var selection = 0
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomSubDanceTableViewCell else {
            fatalError("something went wrong")
        }
        if(indexPath.row > 2){
            cell.backgroundColor = UIColor.red
        }
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMaleTap(_:)))
                // Add the gesture recognizer to the cell's content view
        cell.male!.addGestureRecognizer(tapGesture)
        cell.male!.isUserInteractionEnabled = true
        
        let tapFemaleGesture = UITapGestureRecognizer(target: self, action: #selector(handleFemaleTap(_:)))
                
                // Add the gesture recognizer to the cell's content view
        cell.female!.addGestureRecognizer(tapFemaleGesture)
        cell.female!.isUserInteractionEnabled = true
        cell.name.text = self.classes[indexPath.row].name
        cell.des.text = ""
        cell.des.textColor = UIColor.gray
        cell.male.image = UIImage(named: "dancing_m")
        cell.female.image = UIImage(named: "dancing_w")
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        return cell
    }
    
    @objc func handleMaleTap(_ gesture: UITapGestureRecognizer) {
            // Implement your tap handling code here
        
            let dance = classes[selection].male
            completion(dance.id, dance.hash, classes[selection].hash)
        
            // For example, you can notify your delegate or perform a specific action
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func handleFemaleTap(_ gesture: UITapGestureRecognizer) {
            // Implement your tap handling code here
        
            let dance = classes[selection].female
        completion(dance.id, dance.hash, classes[selection].hash)
        
            // For example, you can notify your delegate or perform a specific action
    }
    
    var classes :[SubDance]
    let completion :(Int, String, String) -> Void
    let tapItem: () -> Void
    
    init(classes :[SubDance], tapItem:@escaping () -> Void , completion:@escaping (Int, String, String) -> Void){
        self.classes = classes
        self.classes = self.classes.sorted(){
            $0.priority < $1.priority
        }
        self.tapItem = tapItem
        self.completion = completion
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classes.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection = indexPath.row
        tapItem()
        guard var cell = tableView.cellForRow(at: indexPath) as? CustomSubDanceTableViewCell else {
            fatalError("something went wrong")
        }
    }
}

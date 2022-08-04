//
//  AppointmentViewController.swift
//  AppointmentManager
//
//  Created by Vishal Bavaliya on 03/08/22.
//

import UIKit
import EventKit
import EventKitUI
import SDWebImage

class AppointmentViewController: UIViewController {
 
    
    //MARK: - Outlets
    @IBOutlet weak var appointmentTableView: UITableView!
    
    //MARK: - Variables
    var businessFile: AppointmentViewModel = AppointmentViewModel()
    let placeHolderImage = UIImage(named: "noImageAvailable")!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
}

//MARK: - Tableview Delegate and DataSourse Method.
extension AppointmentViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessFile.numOfRow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentTableViewCell", for: indexPath) as! AppointmentTableViewCell
        let appointment = businessFile.numCellRow(index: indexPath.row)
        let dateTime = businessFile.generateTimeFormat(date: appointment.time, name: appointment.name, description: appointment.image_url)
        let candidateImage = appointment.image_url
        cell.candidateImage?.sd_setImage(with: URL(string: candidateImage),
                                         placeholderImage: placeHolderImage,
                                         options: SDWebImageOptions.highPriority,
                                         context: nil, progress: nil) { downloadImage, downloadException, cacheType, downloadURL in
            if downloadException != nil {
                print("Error Downloading the Image")
            } else {
                print("Successfully Download Image")
            }
        }
        cell.candidateImage.layer.cornerRadius = cell.candidateImage.frame.width / 2
        cell.candidateImage.clipsToBounds = true
        cell.candidateName.text = appointment.name
        cell.appointmentTime.text = dateTime
        return cell
    }
}

//MARK: - User Defined Functions
extension AppointmentViewController {
    
    func configureTableView() {
        appointmentTableView.register(UINib(nibName: "AppointmentTableViewCell", bundle: nil), forCellReuseIdentifier: "AppointmentTableViewCell")
        businessFile.callTheAppointmentApi()
        DispatchQueue.main.async {
            self.appointmentTableView.reloadData()
        }
        businessFile.fetchDataFromCoreData()
    }
}



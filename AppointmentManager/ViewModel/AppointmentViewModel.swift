//
//  AppointmentViewModel.swift
//  AppointmentManager
//
//  Created by Vishal Bavaliya on 03/08/22.
//

import Foundation
import EventKit
import EventKitUI
import CoreData

class AppointmentViewModel {
    
    //MARK: - Declare this array for storing data.
    var arrOfAppointments: [Appointments] = []
    var arrOfAppointmentsOfflineData: [Appointments] = []
    
    //MARK: - This variable will access the NetworkLayerFunction
    var callApi: WebServices = WebServices()
    
    
    //MARK: - This are the methods of Table View
    func numOfRow() -> Int {
        return arrOfAppointmentsOfflineData.count
    }
    
    func numCellRow(index: Int) -> Appointments {
        return arrOfAppointmentsOfflineData[index]
    }
    
    //MARK: - Convert UTC time to Phone Format Time Zone.
    func utcToLocal(dateStr: String) -> [Date]? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
            
            return [date, date.addingTimeInterval(15*60)]
        }
        return nil
    }
    
    //MARK: - Changing Date Formate.
    func dateFormateChange(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.dateFormat = "d MMM"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    //MARK: - Generates Time Formate  like this (2 May, 1:45 PM - 2:00 PM)
    func generateTimeFormat(date: String, name: String, description: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "h:mm a"
        let dateTime = date
        let dateTimeArr : [String] = dateTime.components(separatedBy: " ")
        
        // And then to access the individual words:
        let date : String = dateTimeArr[0]
        let time : String = dateTimeArr[1]
        
        if let arrTime = utcToLocal(dateStr: time) {
            addEventToCalendar(title: name, description: description, startDate: arrTime[0], endDate: arrTime[1])
            
            return "\(dateFormateChange(dateStr: date) ?? "")" + ", " + "\(dateFormatter.string(from: arrTime[0])) - \(dateFormatter.string(from: arrTime[1]))"
        }
        return nil
    }
    
    //MARK: - Saving All data in Coredata for offline mode.
    func saveDataInCoreData(data: [Appointments]){
        clearDatabase()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Appoitment", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        for dataOfAppointment in data {
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(dataOfAppointment._id, forKey: "id")
            user.setValue(dataOfAppointment.name, forKeyPath: "name")
            user.setValue(dataOfAppointment.time, forKey: "time")
            user.setValue(dataOfAppointment.image_url, forKey: "imageURL")
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Retrive Data from CoreData.
    func fetchDataFromCoreData() {
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Appoitment")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
                self.arrOfAppointmentsOfflineData.append(Appointments(_id: data.value(forKey: "id") as? String ?? "",
                                                                      image_url: data.value(forKey: "imageURL") as! String,
                                                                      name: data.value(forKey: "name") as! String,
                                                                      time: data.value(forKey: "time") as! String))
            }
        } catch {
            print("Failed")
        }
    }
    
    //MARK: - Delete All Data
    public func clearDatabase() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //delete all data
        let context = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Appoitment")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    //MARK: - In This we will call the Appointments list Api
    func callTheAppointmentApi() {
        callApi.requestGetURL(enterURL: "https://interview.avital.in/ios_interview.json") { (decoder, data) in
            do {
                let responseJson = try decoder.decode(AppointmentsData.self, from: data)
                DispatchQueue.main.async {
                    self.saveDataInCoreData(data: responseJson.data)
                }
            } catch {
                print(error.localizedDescription)
            }
        } failure: { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Handle schedule in Calender for Notify.
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        //if access the calender app, then excecute following code.
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event Save")
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
}

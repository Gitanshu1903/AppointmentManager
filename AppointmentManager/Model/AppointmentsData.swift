//
//  AppointmentsData.swift
//  AppointmentManager
//
//  Created by Vishal Bavaliya on 03/08/22.
//

import Foundation

struct AppointmentsData: Codable {
    var message: String
    var data: [Appointments]
}

struct Appointments: Codable {
    var _id: String
    var image_url: String
    var name: String
    var time: String
}

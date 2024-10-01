//
//  VehicleDetailsView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.10.2021.
//

import UIKit


final class VehicleDetailsView: UIView {
	@IBOutlet private weak var vehicleModelLabel: UILabel!
	@IBOutlet private weak var vehiclePlateNumberLabel: UILabel!
	@IBOutlet private weak var vehicleParkingStatusLabel: UILabel!
	@IBOutlet private weak var vehicleParkingTimeLabel: UILabel!
	
	var data: VehicleDetails? {
		didSet {
			vehicleModelLabel.text = (data?.vehicleModel ?? "nil") + " " + (data?.vehicleMake ?? "nil")
            vehiclePlateNumberLabel.text = data?.vehicleLicense ?? "-"
			vehicleParkingStatusLabel.text = data?.vehicleStateName
            vehicleParkingTimeLabel.text = "-"
            if let secondsRemain = data?.vehicleRequestedRemainingSec {

                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                formatter.unitsStyle = .abbreviated

                let formattedString = formatter.string(from: TimeInterval(abs(secondsRemain)))
                
                vehicleParkingTimeLabel.text = formattedString
            }
		}
	}
}

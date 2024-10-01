//
//  ApartmentList.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.01.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation


protocol ApplyingLabelProtocol: AnyObject {
    func applyRoomFormat(format: String, currentRoom: Room)
}

final class ApartmentList: Assembly {
    
    private var parametersController: ParametersController?
    let panelTransition = PanelTransition()
    var title: String = "" {
        didSet {
            parametersController?.setTitleLabel(str: title)
        }
    }
    
    weak var presenterView: ApplyingLabelProtocol?
    
    private let requestService = RequestService.shared
    
    init(view: ApplyingLabelProtocol) {
        presenterView = view
        updateParameters()
    }
    
    func updateParameters() {
        guard let rooms = LocalAuthService.shared.user?.parcingRooms,
              let currentRoom = LocalAuthService.shared.apartment
        else { return }
        
        let currentFormatedRoom = currentRoom.strFormat()
        
         var arr = [ParametersData]()
        
        var lastSelectedRoomRow = 0
        
        for (i, room) in rooms.enumerated() {
            var param = ParametersData(name: room.strFormat())
            param.isSelected = param.name == currentFormatedRoom
            lastSelectedRoomRow = param.isSelected ? i : lastSelectedRoomRow
            print(param.isSelected)
            arr.append(param)
        }
        
        parametersController = ParametersAssembly(
            content: arr,
            selectedRow: lastSelectedRoomRow
        ).makeAsInheritor
        
        parametersController?.choosenClosure = { (content, row) in
            guard
                let choosenRoom = rooms[safe: row],
                let index = choosenRoom.getRoomIndex(rooms)
            else { return }
            self.apartmentDidChange(choosenRoom)
            self.presenterView?.applyRoomFormat(format: choosenRoom.strFormat(), currentRoom: choosenRoom)
            NotificationCenter.default.post(name: .roomChanged, object: nil, userInfo: ["roomNumber": index])
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController?.dynamicSize ?? 0)
        
        parametersController?.transitioningDelegate = panelTransition
    }
    
    func apartmentDidChange(_ room: Room) {
        LocalAuthService.shared.changeRoomImmediately(room)
        requestService.downloadConfigurations { (configs, token) in
            LocalAuthService.shared.updateAllWhenRoomChanged(
                configs: configs,
                accessToken: token,
                room: room
            )
        }
    }
    
    func make() -> UIViewController {
        return parametersController ?? UIViewController()
    }
}

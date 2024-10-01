//
//  LoadingService.swift
//  LoadingService
//
//  Created by Vanjo Lutik on 19.11.2021.
//

import Foundation

final class LoadingService {
    
    private static var loadingView = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    
    private init() {}
    
    static func startLoading() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        
        loadingView.view.addSubview(loadingIndicator)
        ModalRouter(source: nil, destination: loadingView).route()
    }
    
    static func stopLoading() {
        loadingView.dismiss {}
    }
}

//
//  SyncManager.swift
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/19.
//  Copyright © 2018 C205. All rights reserved.
//

import Foundation
import SwiftyJSON
import Digger

@objc @objcMembers class SyncManager: NSObject {
    static let shared = SyncManager()

    private var routeCount: Int = 0

    private override init() {
//        DiggerManager.shared.startDownloadImmediately = false
        DiggerManager.shared.maxConcurrentTasksCount = 4
        DiggerManager.shared.logLevel = .high
        DiggerCache.cachesDirectory = "PDFs"
    }

    func startSync() {
        guard ReachabilityManager.isReachable() else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            DiggerCache.cleanDownloadFiles()
            DiggerCache.cleanDownloadTempFiles()

            self.routeCount = 0
            self.request()
        }
    }

    func request(folderId: Int = 0) {
        let url = folderId == 0 ? "\(Server_URL)\(ServerPath)folders?from=reader" : "\(Server_URL)\(ServerPath)folders?folder_id=\(folderId)"

        WebServiceConnector().init(url,
            withParameters: nil,
            with: self,
            with: #selector(handleResponse(_:)),
            for: ServiceTypeGET,
            showDisplayMsg: "",
            showLoader: false)
    }

    func handleResponse(_ ws: WebServiceConnector) {
        let json = JSON(ws.responseDict)

        json["Roadbooks"]["routes"].arrayValue.forEach {
            cache(url: $0["cross_country_highlight_pdf"].stringValue, name: "\($0["id"].stringValue)_Highlighted_Cross_Country.pdf")
            cache(url: $0["highlight_road_rally"].stringValue, name: "\($0["id"].stringValue)_Highlighted_Road_Rally.pdf")
            cache(url: $0["pdf"].stringValue, name: "\($0["id"].stringValue)_Cross_Country.pdf")
            cache(url: $0["road_rally_pdf"].stringValue, name: "\($0["id"].stringValue)_Road_Rally.pdf")
            self.routeCount += 4
        }

        json["Roadbooks"]["folders"].arrayValue.forEach {
            if $0["id"].intValue > 0, $0["folder_type"].stringValue != "default" {
                self.request(folderId: $0["id"].intValue)
            }
        }
    }

    fileprivate func cache(url: String, name: String) {
        guard let remote = URL(string: url), let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.routeCount -= 1
            if self.routeCount <= 0 {
                print(">>>>>>>>>> COMPLETED SYNC!!!!!!!!! <<<<<<<<<<<<<<")
            }
            return
        }

        let local = dir.appendingPathComponent(name)

        DiggerManager.shared.download(with: remote).completion { result in
            switch result {
            case .success(let temp):
                do {
                    try? FileManager.default.removeItem(at: local)
                    try FileManager.default.moveItem(at: temp, to: local)
                    print(">>>>> Cache success: from = \(remote), to = \(local)")
                } catch (let error) {
                    print(">>>>> Cache failed: from = \(remote), to = \(local), error = \(error.localizedDescription)")
                }

            case .failure(let error):
                print(">>>>> Download failed: from = \(remote), to = \(local), error = \(error.localizedDescription)")

            }


            self.routeCount -= 1
            if self.routeCount <= 0 {
                print(">>>>>>>>>> COMPLETED SYNC!!!!!!!!! <<<<<<<<<<<<<<")
            }

        }
    }

}

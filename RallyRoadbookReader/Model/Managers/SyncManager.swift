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

    static let stateSynchronizing = Notification.Name("Synchronizing")
    static let stateSynchronized = Notification.Name("Synchronized")

    var processingCount: Int = 0
    var scanChild = true
    var isSyncing = false
    var requestUrls: [String] = []
    var routes: [(url: URL, name: String)] = []

    private override init() {
        DiggerManager.shared.maxConcurrentTasksCount = 1
        DiggerManager.shared.logLevel = .none
        DiggerCache.cachesDirectory = "PDFs"
    }

    func startSync(response: WebServiceConnector, scanChild: Bool) {
        guard !isSyncing, ReachabilityManager.isReachable() else {
            return
        }

        DiggerCache.cleanDownloadFiles()
        DiggerCache.cleanDownloadTempFiles()

        self.scanChild = scanChild
        processingCount = 0
        routes.removeAll()
        requestUrls.removeAll()
        isSyncing = true

        requestUrls.append(response.urlRequest.url!.absoluteString)
        handleResponse(response)
    }

    func handleResponse(_ ws: WebServiceConnector) {
        let json = JSON(ws.responseDict)

        json["Roadbooks"]["routes"].arrayValue.forEach {
            if let url = URL(string: $0["cross_country_highlight_pdf"].stringValue) {
                routes.append((url: url, name: "\($0["id"].stringValue)_Highlighted_Cross_Country.pdf"))
            }
            if let url = URL(string: $0["highlight_road_rally"].stringValue) {
                routes.append((url: url, name: "\($0["id"].stringValue)_Highlighted_Road_Rally.pdf"))
            }
            if let url = URL(string: $0["pdf"].stringValue) {
                routes.append((url: url, name: "\($0["id"].stringValue)_Cross_Country.pdf"))
            }
            if let url = URL(string: $0["road_rally_pdf"].stringValue) {
                routes.append((url: url, name: "\($0["id"].stringValue)_Road_Rally.pdf"))
            }
        }

        if scanChild {
            json["Roadbooks"]["folders"].arrayValue.forEach {
                if let id = $0["id"].int, id > 0, $0["folder_type"].stringValue != "default" {
                    let url = "\(Server_URL)\(ServerPath)folders?from=reader&folder_id=\(id)"
                    print(">>>!@#$%^&*()>>>>>>>>>> \(url)")
                    self.requestUrls.append(url)
                    WebServiceConnector().init(url, withParameters: nil, with: self, with: #selector(handleResponse), for: ServiceTypeGET, showDisplayMsg: "", showLoader: false)
                }
            }
        }

        requestUrls.removeAll { $0 == ws.urlRequest.url!.absoluteString }

        // Start caching
        if requestUrls.isEmpty {
            processingCount = 0

            if routes.isEmpty {
                checkComplete()
            } else {
                routes.forEach { cache(url: $0.url, name: $0.name) }
            }
        }
    }

    fileprivate func cache(url: URL, name: String) {
        let local = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
        DiggerManager.shared.download(with: url).completion { result in
            switch result {
            case .success(let temp):
                do {
                    try? FileManager.default.removeItem(at: local)
                    try FileManager.default.moveItem(at: temp, to: local)
                } catch {
                }

            case .failure(_):
                break
            }

            self.processingCount += 1
            self.checkComplete()
        }
    }

    fileprivate func checkComplete() {
        if processingCount >= routes.count {
            NotificationCenter.default.post(name: SyncManager.stateSynchronized, object: self, userInfo: [:])

            processingCount = 0
            routes.removeAll()
            requestUrls.removeAll()
            isSyncing = false
        } else {
            NotificationCenter.default.post(name: SyncManager.stateSynchronizing, object: self,
                userInfo: ["total": routes.count, "count": processingCount])
        }
    }

}

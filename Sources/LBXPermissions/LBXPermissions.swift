//
//  LBXPermissions.swift
//  swiftScan
//
//  Created by xialibing on 15/12/15.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary
import CoreTelephony

public class LBXPermissions: NSObject {
    
    public static func authorizeNetworkWith(completion: @escaping (Bool) -> Void) {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.restricted {
                completion(false)
            } else {
                completion(true)
            }
        }
        let state = cellularData.restrictedState
        if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.restricted {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    public static func authorizePhotoWith(completion: @escaping (Bool) -> Void) {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            completion(true)
        case PHAuthorizationStatus.denied, PHAuthorizationStatus.restricted:
            completion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ status in
                DispatchQueue.main.async {
                    completion(status == PHAuthorizationStatus.authorized)
                }
            })
        case .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    public static func authorizeCameraWith(completion: @escaping (Bool) -> Void) {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch granted {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        case .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        @unknown default:
            completion(false)
        }
    }
    
    public static func jumpToSystemPrivacySetting() {
        guard let appSetting = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appSetting)
        }
    }
    
}

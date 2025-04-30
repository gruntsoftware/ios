//
//  FailedAlertView.swift
//  loafwallet
//
//  Created by Kerry Washington on 1/29/21.
//
import UIKit

enum AlertFailureType {
	case failedResolution

//	var header: String {
//		switch self {
//		case .failedResolution:
//			return S.Send.UnstoppableDomains.lookupFailureHeader.localize()
//		}
//	}
//
//	var subheader: String {
//		switch self {
//		case .failedResolution:
//			return S.SecurityAlerts.resolvedSuccessSubheader.localize()
//		}
//	}

	var icon: UIView {
		return CheckView()
	}
}

extension AlertFailureType: Equatable {}

func == (lhs: AlertFailureType, rhs: AlertFailureType) -> Bool {
	switch (lhs, rhs) {
	case (.failedResolution, .failedResolution): return true
	}
}

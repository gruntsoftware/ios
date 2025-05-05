//
//  SignupWebViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 1/9/24.
//
import Combine
import Foundation

class SignupWebViewModel: ObservableObject {
	var showLoader = PassthroughSubject<Bool, Never>()
	var valuePublisher = PassthroughSubject<String, Never>()
}

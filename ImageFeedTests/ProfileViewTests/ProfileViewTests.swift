//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Anna Fadieieva on 2023-06-15.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testProfileViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        
        //when
        _ = profileViewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoad)
    }
    
    func testProfileLogout() {
        //given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        
        //when
        presenter.showLogoutAlert(vc: profileViewController)
        
        //then
        XCTAssertTrue(presenter.showLogoutAlert)
        XCTAssertEqual(presenter.presentedViewController, profileViewController)
    }
    
    func testUpdateProfileDetails() {
        //given
        let mockProfile = Profile(username: "vano", first_name: "Ivan", last_name: "Ivanov", bio: "hi!")
        let profileViewController = ProfileViewController()
        //when
        profileViewController.updateProfileDetails(profile: mockProfile)
        //then
        XCTAssertEqual(profileViewController.profileView.loginNameLabel.text, "@" + mockProfile.username)
        XCTAssertEqual(profileViewController.profileView.descriptionLabel.text, mockProfile.bio)
        XCTAssertEqual(profileViewController.profileView.nameLabel.text, (mockProfile.first_name) + " " + (mockProfile.last_name))
    }
    
    func testUpdateAvatarImage() {
        //given
        let profileViewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceStub()
        //when
        profileViewController.updateAvatar()
        //then
        XCTAssertNotNil(profileImageService.avatarImage)
    }
}

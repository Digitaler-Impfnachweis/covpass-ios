//
//  DefaultSceneCoordinatorTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import PromiseKit
import UIKit
import XCTest

class DefaultSceneCoordinatorTests: XCTestCase {
    enum CoordinatorTestError: Error {
        case didFail
    }

    var sut: SceneCoordinator!
    var rootViewController: NavigationControllerMock!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        rootViewController = NavigationControllerMock()
        rootViewController.pushViewController(ViewControllerMock(), animated: false)
        sut = DefaultSceneCoordinator(window: window, rootViewController: rootViewController)
    }

    override func tearDown() {
        rootViewController = nil
        window = nil
        sut = nil
        super.tearDown()
    }

    func test_initital() {
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.rootViewController, rootViewController)
    }

    func test_asRoot() {
        // given
        let viewController = ViewControllerMock()
        let scene = SceneFactoryMock(viewController: viewController)

        // when
        sut.asRoot(scene)

        // then
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.rootViewController, viewController)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.window?.rootViewController, viewController)
    }

    func test_push() {
        // given
        let exp = expectation(description: "Did push ViewController")
        let expectedViewController = ViewControllerMock()
        var receivedViewController: UIViewController?
        rootViewController.didPush = { receivedViewController = $0; exp.fulfill() }

        // when
        sut.push(SceneFactoryMock(viewController: expectedViewController))

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(receivedViewController, expectedViewController)
        XCTAssertEqual(rootViewController.currentViewControllers.last, receivedViewController)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_pop() {
        // given
        let exp = expectation(description: "Did pop ViewController")
        let expectedViewController = ViewControllerMock()
        var receivedViewController: UIViewController?
        let scene = SceneFactoryMock(viewController: expectedViewController)
        sut.push(scene)
        rootViewController.didPop = { receivedViewController = $0; exp.fulfill() }

        // when
        sut.pop()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(receivedViewController, expectedViewController)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 1)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_should_pop_if_resolver_did_fulfill() {
        // given
        let exp = expectation(description: "Did resolve Promise")
        let expectedResult = "some-result"
        var receivedResult: String?
        let scene = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result: Promise<String> = sut.push(scene)
        result.done { receivedResult = $0; exp.fulfill() }.cauterize()

        // when
        scene.resolver?.fulfill(expectedResult)

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(result.isFulfilled)
        XCTAssertEqual(receivedResult, expectedResult)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 1)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_should_pop_if_resolver_did_cancel() {
        // given
        let exp = expectation(description: "Did resolve last scene")
        let scene = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result: Promise<String> = sut.push(scene)
        result.cancelled { exp.fulfill() }.cauterize()

        // when
        scene.resolver?.cancel()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(result.isCancelled)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_should_pop_if_resolver_did_reject() {
        // given
        let exp = expectation(description: "Did reject Promise")
        let expectedError = CoordinatorTestError.didFail
        var receivedError: Error?

        let scene = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result: Promise<String> = sut.push(scene)
        result.catch { receivedError = $0; exp.fulfill() }

        // when
        scene.resolver?.reject(expectedError)

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(result.isRejected)
        XCTAssertEqual(receivedError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 1)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_should_pop_last__if_last_resolver_did_fulfill() {
        // given
        let exp1 = expectation(description: "Did pop ViewController")
        let exp2 = expectation(description: "Did resolve last scene")
        let expectedViewController = ViewControllerMock()
        var receivedViewController: UIViewController?
        let expectedResult = "some-result"
        var receivedResult: String?

        let scene1 = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result1: Promise<String> = sut.push(scene1)
        result1.done { _ in XCTFail("Should not happen") }.cauterize()

        let scene2 = ResolvableSceneFactoryMock(viewController: expectedViewController)
        let result2: Promise<String> = sut.push(scene2)
        result2.done { receivedResult = $0; exp2.fulfill() }.cauterize()

        rootViewController.didPop = { receivedViewController = $0; exp1.fulfill() }

        // when
        scene2.resolver?.fulfill(expectedResult)

        // then
        wait(for: [exp1, exp2], timeout: 2, enforceOrder: true)
        XCTAssertFalse(result1.isFulfilled)
        XCTAssertTrue(result2.isFulfilled)
        XCTAssertEqual(receivedViewController, expectedViewController)
        XCTAssertEqual(receivedResult, expectedResult)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 2)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 1)
    }

    func test_resolver_should_cancel_if_scene_did_pop_programmatically() {
        // given
        let exp = expectation(description: "Did cancelled Promise")
        let scene = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result: Promise<String> = sut.push(scene)
        result.cancelled { exp.fulfill() }.cauterize()

        // when
        sut.pop()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(result.isCancelled)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 1)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 0)
    }

    func test_last_resolver_should_cancel__if_last_scene_did_pop_programmatically() {
        // given
        let exp = expectation(description: "Did cancel last scene")

        let scene1 = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result1: Promise<String> = sut.push(scene1)
        result1.done { _ in XCTFail("Should not happen") }.cauterize()

        let scene2 = ResolvableSceneFactoryMock(viewController: ViewControllerMock())
        let result2: Promise<String> = sut.push(scene2)
        result2.cancelled { exp.fulfill() }.cauterize()

        // when
        sut.pop()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertFalse(result1.isFulfilled)
        XCTAssertTrue(result2.isCancelled)
        XCTAssertEqual(rootViewController.currentViewControllers.count, 2)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.navigationSceneStack.count, 1)
    }

    func test_present() {
        // given
        let exp = expectation(description: "Did present ViewController")
        let expectedViewController = ViewControllerMock()
        var receivedViewController: UIViewController?
        rootViewController.didPresent = { receivedViewController = $0; exp.fulfill() }

        // when
        sut.present(SceneFactoryMock(viewController: expectedViewController))

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(rootViewController.currentPresentedViewController, receivedViewController)
        XCTAssertEqual(receivedViewController, expectedViewController)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.modalSceneStack.count, 0)
    }

    func test_present_interactive_dismissible() {
        // given
        let exp = expectation(description: "Did present ViewController")
        let expectedViewController = InteractiveDismissibleViewControllerMock()
        var receivedViewController: UIViewController?
        rootViewController.didPresent = { receivedViewController = $0; exp.fulfill() }

        // when
        sut.present(SceneFactoryMock(viewController: expectedViewController))

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(rootViewController.currentPresentedViewController, receivedViewController)
        XCTAssertEqual(receivedViewController, expectedViewController)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.modalSceneStack.count, 1)
    }

    func test_dismiss() {
        // given
        let exp = expectation(description: "Did dismiss ViewController")
        let viewController = ViewControllerMock()
        viewController.didDismiss = { exp.fulfill() }
        sut.present(SceneFactoryMock(viewController: viewController))

        // when
        sut.dismiss()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.modalSceneStack.count, 0)
    }

    func test_dismiss_interactive_dismissible() {
        // given
        let exp = expectation(description: "Did dismiss ViewController")
        let viewController = InteractiveDismissibleViewControllerMock()
        viewController.didDismiss = { exp.fulfill() }
        sut.present(SceneFactoryMock(viewController: viewController))

        // when
        sut.dismiss()

        // then
        wait(for: [exp], timeout: 2)
        XCTAssertEqual((sut as? DefaultSceneCoordinator)?.modalSceneStack.count, 0)
    }

    func test_should_dismiss_if_resolver_did_fulfill() {
        // given
        let exp1 = expectation(description: "Did dismiss ViewController")
        let exp2 = expectation(description: "Did resolve Promise")
        let expectedResult = "some-result"
        var receivedResult: String?

        let viewController = ViewControllerMock()
        viewController.didDismiss = { exp1.fulfill() }

        let scene = ResolvableSceneFactoryMock(viewController: viewController)
        let result: Promise<String> = sut.present(scene)
        result.done { receivedResult = $0; exp2.fulfill() }.cauterize()

        // when
        scene.resolver?.fulfill(expectedResult)

        // then
        wait(for: [exp1, exp2], timeout: 2, enforceOrder: true)
        XCTAssertTrue(result.isFulfilled)
        XCTAssertEqual(receivedResult, expectedResult)
    }

    func test_should_dismiss_if_resolver_did_cancel() {
        // given
        let exp1 = expectation(description: "Did dismiss ViewController")
        let exp2 = expectation(description: "Did cancel Promise")

        let viewController = ViewControllerMock()
        viewController.didDismiss = { exp1.fulfill() }

        let scene = ResolvableSceneFactoryMock(viewController: viewController)
        let result: Promise<String> = sut.present(scene)
        result.cancelled { exp2.fulfill() }.cauterize()

        // when
        scene.resolver?.cancel()

        // then
        wait(for: [exp1, exp2], timeout: 2, enforceOrder: true)
        XCTAssertTrue(result.isCancelled)
    }

    func test_should_dismiss_if_resolver_did_reject() {
        // given
        let exp1 = expectation(description: "Did dismiss ViewController")
        let exp2 = expectation(description: "Did cancel Promise")
        let expectedError = CoordinatorTestError.didFail
        var receivedError: Error?

        let viewController = ViewControllerMock()
        viewController.didDismiss = { exp1.fulfill() }

        let scene = ResolvableSceneFactoryMock(viewController: viewController)
        let result: Promise<String> = sut.present(scene)
        result.catch { receivedError = $0; exp2.fulfill() }

        // when
        scene.resolver?.reject(expectedError)

        // then
        wait(for: [exp1, exp2], timeout: 2, enforceOrder: true)
        XCTAssertTrue(result.isRejected)
        XCTAssertEqual(receivedError?.localizedDescription, expectedError.localizedDescription)
    }
}

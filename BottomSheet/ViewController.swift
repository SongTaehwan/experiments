//
//  ViewController.swift
//  BottomSheet
//
//  Created by 송태환 on 2022/11/02.
//

import SnapKit
import UIKit

final class ViewController: UIViewController {
	private var dimmedView: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.alpha = 0.7
		return view
	}()

	private var contentView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		return view
	}()

	private var topPaddingConstraint: Constraint?
	private let defaultHeight: CGFloat = 300

	override func viewDidLoad() {
		super.viewDidLoad()
		layout()
		addGesture()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		show()
	}

	private func layout() {
		view.addSubview(dimmedView)
		view.addSubview(contentView)

		dimmedView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		contentView.snp.makeConstraints { make in
			make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalTo(view.snp.bottom)

			// top safe area 부분 제외한 화면 나머지 높이 값
			let fullHeight = view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.bottom

			topPaddingConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(fullHeight).constraint
		}

		topPaddingConstraint?.activate()
	}

	private func show() {
		UIView.animate(withDuration: 0.25) {
			self.dimmedView.alpha = 0.7

			let fullHeight = self.view.safeAreaLayoutGuide.layoutFrame.height + self.view.safeAreaInsets.bottom

			let topPaddingWithoutContentHeight = fullHeight - self.defaultHeight

			self.topPaddingConstraint?.update(offset: topPaddingWithoutContentHeight)

			// 아래 코드 없으면 애니메이션 효과 적용 안돼나 위에 코드의 변경사항은 적용됨
			self.view.layoutIfNeeded()
		}
	}

	private func addGesture() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
		pan.delaysTouchesBegan = false
		pan.delaysTouchesEnded = false
		contentView.addGestureRecognizer(pan)
	}

	// top safe area 와의 최소 간격
	private var topLimit: CGFloat = 30

	// 컨텐츠 최소 높이
	private var bottomLimit: CGFloat {
		return self.view.safeAreaLayoutGuide.layoutFrame.height + self.view.safeAreaInsets.bottom - self.defaultHeight
	}

	// 현재 padding 크기를 담고 있는 값
	private var currentPaddingValue: CGFloat = 0

	@objc private func handleGesture(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: contentView)

		switch gesture.state {
		case .began:
			// 드래그 시작할 때 현재 크기 저장
			currentPaddingValue = topPaddingConstraint!.layoutConstraints[0].constant
		case .changed:
			let value = currentPaddingValue + translation.y
			if value > topLimit && value < bottomLimit {
				topPaddingConstraint?.update(offset: currentPaddingValue + translation.y)
			}
		case .ended:
			print("Done")
		default:
			print("Done2")
		}
	}
}


//
//  SmileView.swift
//  SmileDetector
//
//  Created by Yuki Ishii on 2015/07/19.
//  Copyright (c) 2015年 Yuki Ishii. All rights reserved.
//

import Foundation
import SpriteKit

class SmileView: SKScene {
	let width = UIScreen.mainScreen().bounds.width
	let height = UIScreen.mainScreen().bounds.height
	
	let mesis = ["mesi_1.png", "mesi_2.png", "mesi_3.png", "mesi_4.png",
					"mesi_5.png", "mesi_6.png", "mesi_7.png", "mesi_8.png", "mesi_9.png"]
	let smiles = ["kirin_a.png", "kirin_b.png", "kirin_c.png", "kirin_d.png",
					"ryo_a.png", "ryo_b.png", "ryo_c.png", "ryo_d.png",
					"shiina_a.png", "shiina_b.png"]
	let yokokumesis = ["yokoku1.png", "yokoku2.png", "yokoku3.png", "yokoku4.png"]
	
	lazy var mesi = SKSpriteNode()
	lazy var smile = SKSpriteNode()
	lazy var yokokumesi = SKSpriteNode()
	
	override init(size: CGSize) {
		super.init(size: size)
		setupMesi()
		setupSmile()
		setupYokokumesi()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setupMesi() {
		let size = width - 20
		let texture = returnNextMesi()
		mesi = SKSpriteNode(imageNamed: texture)
		mesi.size = CGSizeMake(size, size)
		mesi.position = CGPointMake(width / 2, height / 2)
		addChild(mesi)
	}
	
	func setupSmile() {
		let size = width - 20
		let texture = returnNextSmile()
		smile = SKSpriteNode(imageNamed: texture)
		smile.size = CGSizeMake(size, size)
		smile.position = CGPointMake(width / 2, height / 2)
		addChild(smile)
		smile.hidden = true
	}
	
	func setupYokokumesi() {
		let size = width - 20
		let texture = returnNextYokokumesi()
		yokokumesi = SKSpriteNode(imageNamed: texture)
		yokokumesi.size = CGSizeMake(size, size)
		yokokumesi.position = CGPointMake(width / 2, height / 2)
		addChild(yokokumesi)
		yokokumesi.hidden = true
	}
	
	func showSmile() {
		hideMesi()
		let nextSmile = returnNextSmile()
		println("nextSmile: \(nextSmile)")
		smile.texture = SKTexture(imageNamed: nextSmile)
		smile.hidden = false
	}
	
	func showMesi() {
		hideYokokumesi()
		let nextMesi = returnNextMesi()
		println("nextMesi: \(nextMesi)")
		mesi.texture = SKTexture(imageNamed: nextMesi)
		mesi.hidden = false
	}
	
	func showYokokumesi() {
		hideSmile()
		let nextYokokumesi = returnNextYokokumesi()
		yokokumesi.texture = SKTexture(imageNamed: nextYokokumesi)
		yokokumesi.hidden = false
	}
	
	func hideMesi() {
		mesi.hidden = true
	}
	
	func hideSmile() {
		smile.hidden = true
	}
	
	func hideYokokumesi() {
		yokokumesi.hidden = true
	}
	
	func returnNextMesi() -> String {
		let len = (UInt32)(mesis.count)
		let index = (Int)(arc4random_uniform(len))
		return mesis[index]
	}

	func returnNextSmile() -> String {
		let len = (UInt32)(smiles.count)
		let index = (Int)(arc4random_uniform(len))
		return smiles[index]
	}
	
	func returnNextYokokumesi() -> String {
		let len = (UInt32)(yokokumesis.count)
		let index = (Int)(arc4random_uniform(len))
		return yokokumesis[index]
	}
	
}

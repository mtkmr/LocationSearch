//
//  BalloonView.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/08/15.
//

import UIKit

final class BalloonView: UIView {
    
    private let triangleSideLength: CGFloat = 20
    private let triangleHeight: CGFloat = 17.3

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //グラフィックコンテキストの作成
        let context = UIGraphicsGetCurrentContext()
        //描画の設定
        context?.setFillColor(cyan: 1, magenta: 1, yellow: 1, black: 1, alpha: 0.8)
        //パスを作成して描画
        contextBalloonPath(context: context!, rect: rect)
    }
    
    private func contextBalloonPath(context: CGContext, rect: CGRect) {
        let triangleLeftCorner = (x: CGFloat(0), y: rect.size.height / 2)
        let triangleTopCorner = (x: triangleHeight, y: (rect.size.height - triangleSideLength) / 2)
        let triangleBottomCorner = (x: triangleHeight, y: (rect.size.height + triangleSideLength) / 2)
        //塗りつぶし
        context.addRect(CGRect(x: triangleHeight, y: 0, width: 300, height: rect.size.height))
        context.fillPath()
        context.move(to: CGPoint(x: triangleLeftCorner.x, y: triangleLeftCorner.y))
        context.addLine(to: CGPoint(x: triangleTopCorner.x, y: triangleTopCorner.y))
        context.addLine(to: CGPoint(x: triangleBottomCorner.x, y: triangleBottomCorner.y))
        context.fillPath()
    }

}

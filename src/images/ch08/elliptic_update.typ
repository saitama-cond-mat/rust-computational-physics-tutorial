#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 18pt)

#cetz.canvas({
    import cetz.draw: *

    // グリッドパラメータ
    let s = 1.3  // セルサイズを少し大きく
    let dx = 2.2
    let dy = 2.2

    // Jacobi Method
    group({
        // タイトル
        content((dx*3.5, 7.0), text(size: 20pt, weight: "bold")[Jacobi Method])

        // 説明：すべての点を同時に更新
        content((dx*3.5, 6.2), text(size: 14pt, fill: gray)[Simultaneous update of all points])

        // 古い値のグリッド
        for x in (0, 1, 2, 3) {
            for y in (0, 1, 2) {
                let p = (x*dx, y*dy)
                rect(p, (x*dx+s, y*dy+s), fill: white, stroke: 1.2pt)
                content((x*dx+s/2, y*dy+s/2), text(size: 16pt)[$u^k$])
            }
        }

        // ステップラベル
        content((dx*1.5, -0.8), text(size: 14pt, weight: "bold")[Step $k$])

        // 矢印（左右対称に配置するため、グリッド間の中央に）
        let arrow_gap = 0.5  // 矢印の両側の間隔
        line((dx*3 + s + arrow_gap, dy), (dx*4.25 + arrow_gap, dy), mark: (end: "stealth"), stroke: 2pt + gray)
        content((dx*3.55 + s/2 + arrow_gap, dy + 0.4), text(size: 13pt)[update])

        // 新しい値のグリッド（矢印に近づける）
        group({
            set-origin((dx*3.5 + s + 2*arrow_gap, 0))
            for x in (0, 1, 2, 3) {
                for y in (0, 1, 2) {
                    let p = (x*dx, y*dy)
                    rect(p, (x*dx+s, y*dy+s), fill: rgb("#E3F2FD"), stroke: 1.5pt + blue)
                    content((x*dx+s/2, y*dy+s/2), text(size: 16pt, fill: blue)[$u^(k+1)$])
                }
            }
            content((dx*1.5, -0.8), text(size: 14pt, weight: "bold", fill: blue)[Step $k+1$])
        })

        // フッター説明
        content((dx*3.5, -2.0), text(size: 14pt, style: "italic")[
            All values at step $k+1$ computed using only values from step $k$
        ])
    })

    // Gauss-Seidel Method
    group({
        set-origin((0, -11.5))

        // タイトル
        content((dx*1.5, 7.0), text(size: 20pt, weight: "bold")[Gauss-Seidel Method])

        // 説明：逐次更新
        content((dx*1.5, 6.2), text(size: 14pt, fill: gray)[Sequential update using latest values])

        // グリッド描画
        for x in (0, 1, 2, 3) {
            for y in (0, 1, 2) {
                let p = (x*dx, y*dy)
                // スキャン順序: 上から下へ (y=2 to 0)、左から右へ
                // (2,1)が現在更新中のポイント
                let is_done = (y > 1) or (y == 1 and x < 2)
                let is_current = (y == 1 and x == 2)

                let f = if is_done { rgb("#E3F2FD") } else { white }
                let s_color = if is_done { blue } else { black }
                let s_width = if is_current { 2.5pt } else { 1.2pt }

                rect(p, (x*dx+s, y*dy+s), fill: f, stroke: s_width + s_color)

                if not is_current {
                    let label = if is_done {
                        text(size: 16pt, fill: blue)[$u^(k+1)$]
                    } else {
                        text(size: 16pt)[$u^k$]
                    }
                    content((x*dx+s/2, y*dy+s/2))[#label]
                }
            }
        }

        // 現在更新中のポイント (2, 1)
        let curr = (2*dx, 1*dy)
        rect(curr, (2*dx+s, 1*dy+s), stroke: 3pt + red)
        content((2*dx+s/2, 1*dy+s/2), text(size: 16pt, weight: "bold", fill: red)[
            $u^(k+1)$
        ])

        // 依存関係の矢印（更新済みの値を使用）
        // 上の隣接点から（すでに更新済み）
        line((2*dx+s/2, 2*dy+0.0), (2*dx+s/2, 1*dy+s),
             mark: (end: "stealth"), stroke: 1.5pt + red)
        content((2*dx+s/2 + 0.5, 2*dy - 0.5), text(size: 12pt, fill: red)[new])

        // 左の隣接点から（すでに更新済み）
        line((1*dx+s, 1*dy+s/2), (2*dx+0.0, 1*dy+s/2),
             mark: (end: "stealth"), stroke: 1.5pt + red)
        content((1*dx+s + 0.5, 1*dy+s/2 + 0.4), text(size: 12pt, fill: red)[new])

        // 右と下の隣接点の矢印（古い値を使用）
        // 右
        line((3*dx+0.0, 1*dy+s/2), (2*dx+s, 1*dy+s/2),
             mark: (end: "stealth"), stroke: 1.5pt + rgb("#D35400"))
        content((3*dx - 0.5, 1*dy+s/2 + 0.4), text(size: 12pt, fill: rgb("#D35400"))[old])

        // 下
        line((2*dx+s/2, 0*dy+s+0.0), (2*dx+s/2, 1*dy+0.0),
             mark: (end: "stealth"), stroke: 1.5pt + rgb("#D35400"))
        content((2*dx+s/2 + 0.5, 0*dy+s + 0.5), text(size: 12pt, fill: rgb("#D35400"))[old])

        // スキャン順序の説明
        content((dx*1.5, -0.8), text(size: 14pt, weight: "bold")[Scan order: top→bottom, left→right])

        // フッター説明
        content((dx*3.0, -2.0), text(size: 14pt, style: "italic")[
            Uses newly computed values immediately (typically faster convergence)
        ])
    })
})

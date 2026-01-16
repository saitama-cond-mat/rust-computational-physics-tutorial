#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 1cm)

#cetz.canvas({
    import cetz.draw: *
    
    let f(x) = 0.5 * calc.sin(x) + 1.5
    let a = 1
    let b = 3
    let mid = (a + b) / 2
    
    // X-axis
    line((0, 0), (4, 0), mark: (end: ">"), name: "x")
    content("x.end", anchor: "north-west", padding: .1)[$x$]

    // Function
    let domain = range(0, 35).map(x => x/10)
    line(..domain.map(x => (x, f(x))), stroke: blue, name: "f")

    // Simpson points
    let p1 = (a, f(a))
    let p2 = (mid, f(mid))
    let p3 = (b, f(b))
    
    // Lagrange polynomial P(x)
    let P(x) = {
        let L0 = (x - mid) * (x - b) / ((a - mid) * (a - b))
        let L1 = (x - a) * (x - b) / ((mid - a) * (mid - b))
        let L2 = (x - a) * (x - mid) / ((b - a) * (b - mid))
        f(a) * L0 + f(mid) * L1 + f(b) * L2
    }
    
    let parabola_domain = range(10, 31).map(x => x/10)
    let parabola_pts = parabola_domain.map(x => (x, P(x)))
    
    // Fill area under parabola
    let area_pts = ((a,0),) + parabola_pts + ((b,0),)
    line(..area_pts, close: true, fill: orange.lighten(90%), stroke: none)
    
    line(..parabola_pts, stroke: orange + 2pt)
    
    line((a, 0), p1, stroke: (dash: "dashed"))
    line((mid, 0), p2, stroke: (dash: "dashed"))
    line((b, 0), p3, stroke: (dash: "dashed"))

    // Ticks
    line((a, 0.1), (a, -0.1))
    content((a, -0.2))[$x_i$]
    line((mid, 0.1), (mid, -0.1))
    content((mid, -0.2))[$x_(i+1)$]
    line((b, 0.1), (b, -0.1))
    content((b, -0.2))[$x_(i+2)$]
})

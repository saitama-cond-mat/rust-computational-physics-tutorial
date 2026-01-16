#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 1cm)

#cetz.canvas({
    import cetz.draw: *
    
    let f(x) = 0.1 * x * x + 0.5
    let a = 1
    let b = 3
    
    // X-axis
    line((0, 0), (4, 0), mark: (end: ">"), name: "x")
    content("x.end", anchor: "north-west", padding: .1)[$x$]

    // Function
    let domain = range(0, 35).map(x => x/10)
    line(..domain.map(x => (x, f(x))), stroke: blue, name: "f")
    content("f.end", anchor: "south-west", padding: .1)[$f(x)$]

    // Trapezoid
    let p1 = (a, f(a))
    let p2 = (b, f(b))
    line((a, 0), p1, p2, (b, 0), close: true, fill: blue.lighten(90%), stroke: none)
    line((a, 0), p1, stroke: (dash: "dashed"))
    line((b, 0), p2, stroke: (dash: "dashed"))
    line(p1, p2, stroke: orange + 2pt)

    // Ticks
    line((a, 0.1), (a, -0.1))
    content((a, -0.2))[$x_i$]
    line((b, 0.1), (b, -0.1))
    content((b, -0.2))[$x_(i+1)$]
})

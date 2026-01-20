#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let s = 2.5

    let f(x) = 0.5 * calc.sin(x) + 1.5
    let a = 1
    let b = 3
    let mid = (a + b) / 2

    // X-axis
    line((0, 0), (4 * s, 0), mark: (end: ">", size: 0.5), name: "x", stroke: 1.5pt)
    content("x.end", anchor: "west", padding: 0.2)[$x$]

    // Function
    let domain = range(0, 35).map(x => x/10)
    line(..domain.map(x => (x * s, f(x) * s)), stroke: blue + 2.5pt, name: "f")

    // Simpson points
    let p1 = (a * s, f(a) * s)
    let p2 = (mid * s, f(mid) * s)
    let p3 = (b * s, f(b) * s)

    // Lagrange polynomial P(x)
    let P(x) = {
        let L0 = (x - mid) * (x - b) / ((a - mid) * (a - b))
        let L1 = (x - a) * (x - b) / ((mid - a) * (mid - b))
        let L2 = (x - a) * (x - mid) / ((b - a) * (b - mid))
        f(a) * L0 + f(mid) * L1 + f(b) * L2
    }

    let parabola_domain = range(10, 31).map(x => x/10)
    let parabola_pts = parabola_domain.map(x => (x * s, P(x) * s))

    // Fill area under parabola
    let area_pts = ((a * s,0),) + parabola_pts + ((b * s,0),)
    line(..area_pts, close: true, fill: orange.lighten(90%), stroke: none)

    // Parabola curve
    line(..parabola_pts, stroke: orange + 3.5pt)

    // Vertical lines
    line((a * s, 0), p1, stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
    line((mid * s, 0), p2, stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
    line((b * s, 0), p3, stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))

    // Ticks
    line((a * s, 0.1 * s), (a * s, -0.1 * s), stroke: 1.5pt)
    content((a * s, -0.2* s))[$x_i$]
    line((mid * s, 0.1 * s), (mid * s, -0.1 * s), stroke: 1.5pt)
    content((mid * s, -0.2* s))[$x_(i+1)$]
    line((b * s, 0.1 * s), (b * s, -0.1 * s), stroke: 1.5pt)
    content((b * s, -0.2* s))[$x_(i+2)$]
})

#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let s = 2.5

    let f(x) = 0.1 * x * x + 0.5
    let a = 1
    let b = 3

    // X-axis
    line((0, 0), (4 * s, 0), mark: (end: ">", size: 0.5), name: "x", stroke: 1.5pt)
    content("x.end", anchor: "west", padding: .2)[$x$]

    // Function
    let domain = range(0, 35).map(x => x/10)
    line(..domain.map(x => (x * s, f(x) * s)), stroke: blue + 3pt, name: "f")
    content("f.end", anchor: "south-west", padding: .2)[$f(x)$]

    // Trapezoid
    let p1 = (a * s, f(a) * s)
    let p2 = (b * s, f(b) * s)
    line((a * s, 0), p1, p2, (b * s, 0), close: true, fill: blue.lighten(90%), stroke: none)
    line((a * s, 0), p1, stroke: (dash: "dashed", thickness: 1.5pt))
    line((b * s, 0), p2, stroke: (dash: "dashed", thickness: 1.5pt))
    line(p1, p2, stroke: orange + 3pt)

    // Ticks
    line((a * s, 0.1 * s), (a * s, -0.1 * s), stroke: 1.5pt)
    content(((a + 0.05) * s , -0.2 * s))[$x_i$]
    line((b * s, 0.1 * s), (b * s, -0.1 * s), stroke: 1.5pt)
    content(((b + 0.15) * s, -0.2 * s))[$x_(i+1)$]
})

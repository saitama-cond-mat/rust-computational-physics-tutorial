#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let s = 2.5

    let f(x) = 0.2 * (x * x) - 1.5
    let df(x) = 0.4 * x

    let x_min = -1
    let x_max = 6

    // Axis
    line((x_min * s, 0), (x_max * s, 0), mark: (end: ">", size: 0.5), name: "axis", stroke: 1.5pt)
    content("axis.end", anchor: "west", padding: .2)[$x$]

    // Curve
    let domain = range(-10, 60).map(x => x/10)
    line(..domain.map(x => (x * s, f(x) * s)), stroke: blue + 3pt, name: "f")
    content((5.5 * s + 0.2 * s, f(5.5) * s), anchor: "south-west")[$f(x)$]

    // Newton Step
    let x0 = 4.5
    let y0 = f(x0)
    let slope = df(x0)
    let x1 = x0 - y0 / slope

    // Point x0
    line((x0 * s, 0), (x0 * s, y0 * s), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
    circle((x0 * s, y0 * s), radius: 0.15, fill: red, stroke: none)
    content(((x0 + 0.1) * s, -0.2 * s))[$x_n$]

    // Tangent line
    let t_start = 2.0
    let t_end = 5.5
    let tangent_y(x) = slope * (x - x0) + y0
    line((t_start * s, tangent_y(t_start) * s), (t_end * s, tangent_y(t_end) * s), stroke: orange + 3pt)

    // Point x1 (intersection)
    circle((x1 * s, 0), radius: 0.15, fill: green, stroke: none)
    content(((x1 + 0.3) * s, -0.2 * s))[$x_(n+1)$]

    // Annotations
    content((x0 * s + 0.1 * s, y0 * s), anchor: "north-west", padding: 0.1)[$f(x_n)$]

    content((3.5 * s, tangent_y(3.5) * s), anchor: "south-east", padding: 0.2)[Tangent line \ (slope $f'(x_n)$)]

})

#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    // Scaling factors
    let s = 2.5 // Uniform scaling for simplicity

    let f(x) = 0.1 * x * x + 0.5
    let df(x) = 0.2 * x

    let x0 = 1.0
    let y0 = f(x0)
    let h = 1.5
    let x1 = x0 + h
    let y1_exact = f(x1)
    let y1_euler = y0 + df(x0) * h

    // Axis
    line((0, 0), (3.5 * s, 0), mark: (end: ">", size: 0.5), name: "x_axis", stroke: 1.5pt)
    content("x_axis.end", anchor: "west", padding: 0.2)[$t$]
    line((0, 0), (0, 2.5 * s), mark: (end: ">", size: 0.5), name: "y_axis", stroke: 1.5pt)
    content("y_axis.end", anchor: "south", padding: 0.2)[$x(t)$]

    // True curve
    let domain = range(0, 30).map(x => x/10)
    line(..domain.map(x => (x * s, f(x) * s)), stroke: blue + 3pt, name: "curve")
    content((3.8 * s, f(3.8) * s - 1.5), anchor: "south-east", padding: 0.3)[True Solution]

    // Euler step (Tangent line)
    line((x0 * s, y0 * s), (x1 * s, y1_euler * s), stroke: (paint: orange, thickness: 3pt), name: "euler")

    // Points
    circle((x0 * s, y0 * s), radius: 0.15, fill: black)
    content((x0 * s, y0 * s), anchor: "south", padding: 0.4)[$(t_n, x_n)$]

    circle((x1 * s, y1_exact * s), radius: 0.15, fill: blue, stroke: none)
    content((x1 * s, y1_exact * s), anchor: "south-east", padding: 0.2)[True]

    circle((x1 * s, y1_euler * s), radius: 0.15, fill: orange, stroke: none)
    content((x1 * s, y1_euler * s), anchor: "north-east", padding: 0.5)[Euler]

    // Projections and h
    line((x0 * s, 0), (x0 * s, y0 * s), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
    line((x1 * s, 0), (x1 * s, y1_exact * s), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))

    let h_height = 0.2 * s
    line((x0 * s, h_height), (x1 * s, h_height), mark: (start: "|", end: "|"), stroke: 1.5pt)
    content(((x0+x1)/2 * s, h_height + 0.3))[$h$]

    // Error
    line((x1 * s, y1_euler * s), (x1 * s, y1_exact * s), stroke: (paint: red, thickness: 2.5pt), mark: (start: "|", end: "|"))
    content(((x1 * s) + 0.3, (y1_euler + y1_exact)/2 * s), anchor: "west", padding: 0.1)[Error]
})

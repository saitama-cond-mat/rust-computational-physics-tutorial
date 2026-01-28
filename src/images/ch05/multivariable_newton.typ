#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let s = 2.0 // Scaling factor

    // Draw Grid / Axis
    line((-2.2 * s, 0), (2.2 * s, 0), mark: (end: ">", size: 0.3), name: "xaxis", stroke: 1pt)
    line((0, -1.2 * s), (0, 3.2 * s), mark: (end: ">", size: 0.3), name: "yaxis", stroke: 1pt)
    content("xaxis.end", anchor: "west", padding: .1)[$x$]
    content("yaxis.end", anchor: "south", padding: .1)[$y$]

    // Circle x^2 + y^2 = 1
    // Approximate with points
    let circle_pts = ()
    let steps = 100
    for i in range(0, steps + 1) {
        let theta = i / steps * 2 * 3.14159
        circle_pts.push((calc.cos(theta) * s, calc.sin(theta) * s))
    }
    line(..circle_pts, stroke: blue + 2pt, close: true)
    content(((1.1 + 0.4) * s, -0.8 * s), text(fill: blue)[$x^2 + y^2 = 1$])

    // Parabola y = x^2
    let parabola_pts = ()
    let p_steps = 100
    let x_start = -1.8
    let x_end = 1.8
    for i in range(0, p_steps + 1) {
        let x = x_start + (x_end - x_start) * i / p_steps
        let y = x * x
        parabola_pts.push((x * s, y * s))
    }
    line(..parabola_pts, stroke: red + 2pt)
    content(((-1.5 + 0.5) * s, 2.5 * s), text(fill: red)[$y = x^2$])

    // Initial point (1, 2)
    let start_pt = (1.0 * s, 2.0 * s)
    circle(start_pt, radius: 0.1, fill: black)
    content(start_pt, anchor: "east", padding: 0.2)[Start\ $(1, 2)$]

    // Step 1 point (1, 1)
    let step1_pt = (1.0 * s, 1.0 * s)
    circle(step1_pt, radius: 0.1, fill: gray)
    content(step1_pt, anchor: "west", padding: 0.2)[Step 1 $(1, 1)$]

    // Solution point (approx 0.786, 0.618)
    let sol_x = 0.786
    let sol_y = 0.618
    let sol_pt = (sol_x * s, sol_y * s)
    circle(sol_pt, radius: 0.1, fill: green)
    content(sol_pt, anchor: "west", padding: 0.2)[Solution]

    // Arrow from Start to Step 1
    line(start_pt, step1_pt, mark: (end: ">"), stroke: (paint: gray, thickness: 1.5pt))

    // Arrow from Step 1 to Solution (schematic)
    line(step1_pt, sol_pt, mark: (end: ">"), stroke: (paint: gray, thickness: 1.5pt))
})

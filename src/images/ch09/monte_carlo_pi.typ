#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    // Scale factor
    let s = 2.0
    let r_base = 4
    let r = r_base * s

    // Define geometric elements explicitly to avoid coordinate system confusion

    // Square: (0,0) to (r, r)
    rect((0, 0), (r, r), stroke: black + 2pt)

    // Quarter Circle Sector
    // Explicitly calculate points to ensure it overlaps with the square in the first quadrant (+x, +y)
    let steps = 100
    let arc_pts = range(0, steps + 1).map(i => {
        let theta = i * 90deg / steps
        (r * calc.cos(theta), r * calc.sin(theta))
    })

    // Fill the sector
    line((0,0), ..arc_pts, close: true, fill: blue.lighten(90%), stroke: none)

    // Stroke the arc curve
    line(..arc_pts, stroke: blue + 3pt)

    // Axis
    let axis_len = 4.5 * s
    line((0, 0), (axis_len, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
    content((axis_len, 0), anchor: "north")[$x$]

    line((0, 0), (0, axis_len), mark: (end: ">", size: 0.5), stroke: 1.5pt)
    content((0, axis_len), anchor: "south-east")[$y$]

    // Random points
    // We scale the original random points
    let raw_points = (
        (0.5, 0.5), (1.2, 3.4), (2.1, 1.1), (3.5, 0.2), (0.8, 2.5),
        (3.1, 3.1), (2.5, 2.8), (1.5, 1.5), (0.2, 3.8), (3.9, 1.5),
        (2.2, 3.5), (1.1, 0.8), (3.3, 2.2), (0.5, 1.9), (2.8, 0.5),
        (1.8, 2.2), (3.6, 3.2), (0.9, 0.3), (1.4, 2.9), (2.6, 1.2),
        // Outside points
        (3.5, 3.5), (3.8, 2.5), (2.5, 3.8), (3.2, 2.8)
    )

    for p in raw_points {
        let (rx, ry) = p
        let x = rx * s
        let y = ry * s

        // Check condition on original scale (r_base = 4)
        // x_raw^2 + y_raw^2 <= 16
        let inside = rx*rx + ry*ry <= 16.0
        let color = if inside { red } else { black }

        circle((x, y), radius: 0.15, fill: color, stroke: none)
    }

    content((2 * s, -0.5 * s))[$r=1$]
    content((-0.5 * s, 2 * s))[$r=1$]

    content((2 * s, 2 * s))[Hit]
    content((3.5 * s, 3.8 * s))[Miss]
})

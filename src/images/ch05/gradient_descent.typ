#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *
    
    let s = 2.0

    // Draw contours for f(x,y) = x^2 + y^2
    // Circles centered at (0,0)
    
    let x_center = 0
    let y_center = 0
    
    for r in (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5) {
        circle((x_center, y_center), radius: r * s, stroke: gray.lighten(50%) + 1.5pt)
    }
    
    // Optimization path
    let path = (
        (-3, 2),
        (-2, 0.5),
        (-1, -0.2),
        (-0.2, 0.1),
        (0, 0)
    )
    
    // Draw path
    for i in range(0, path.len() - 1) {
        let (x1, y1) = path.at(i)
        let (x2, y2) = path.at(i+1)
        let p1 = (x1 * s, y1 * s)
        let p2 = (x2 * s, y2 * s)
        line(p1, p2, mark: (end: ">", size: 0.5), stroke: (paint: blue, thickness: 3pt))
        circle(p1, radius: 0.15, fill: red, stroke: none)
    }
    circle((0, 0), radius: 0.2, fill: green, stroke: none)
    
    // Labels
    content((-3 * s, 2 * s), anchor: "south-east", padding: 0.2)[Start]
    content((0, 0), anchor: "north", padding: 0.3)[Minimum]
    content((2.5 * s, 2.0 * s))[Contour Lines]
    
})
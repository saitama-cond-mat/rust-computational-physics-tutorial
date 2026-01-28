#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let sx = 3.2
    let sy = 1.0

    // Function definition
    let f(x) = 0.5 * (x - 2) * (x - 2) * (x - 2) + 0.5 * (x - 2) + 1

    // Plotting range
    let x_min = 0
    let x_max = 4.5

    // Points
    let a = 0.5
    let b = 3.5
    let c = (a + b) / 2

    // Axis
    line((x_min, 0), (x_max * sx, 0), mark: (end: ">", size: 0.5), name: "axis", stroke: 1.5pt)
    content("axis.end", anchor: "west", padding: .2)[$x$]

    // Curve
    let domain = range(0, 45).map(x => x/10)
    line(..domain.map(x => (x * sx, f(x) * sy)), stroke: blue + 3pt, name: "f")
    content((4 * sx, f(4) * sy), anchor: "west", padding: 0.2)[$f(x)$]

    // Points and vertical lines
    // Added parameters for label position to customize for a, b, and c
    let draw_point(x, label_text, color, label_y: -0.6, label_anchor: "north") = {
        let y = f(x)
        line((x * sx, 0), (x * sx, y * sy), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
        circle((x * sx, y * sy), radius: 0.15, fill: color, stroke: none)
        line((x * sx, 0.15 * sy), (x * sx, -0.15 * sy), stroke: gray + 1.5pt)
        content((x * sx, label_y * sy), anchor: label_anchor)[#label_text]
    }

    // a: dashed line goes down, so put label ABOVE axis
    draw_point(a, $a$, red, label_y: 0.6, label_anchor: "south")

    // b, c: dashed line goes up, so put label BELOW axis (default)
    draw_point(b, $b$, red)
    draw_point(c, $c$, green)

    // Signs
    content((a * sx + 0.15 * sx, f(a) * sy), anchor: "west")[$f(a) < 0$]
    content((b * sx + 0.1 * sx, f(b) * sy), anchor: "west", padding: 0.1)[$f(b) > 0$]
    content((c * sx - 0.5 * sx, f(c) * sy + 0.2 * sy), anchor: "south")[$f(c) > 0$]

    // New interval arrow
    let arrow_y = -2.5
    line((a * sx, arrow_y * sy), (c * sx, arrow_y * sy), mark: (start: "|", end: ">", size: 0.5), stroke: red + 2.5pt)
    content(((a+c)/2 * sx, arrow_y * sy - 0.3 * sy), anchor: "north")[Next Interval]

})

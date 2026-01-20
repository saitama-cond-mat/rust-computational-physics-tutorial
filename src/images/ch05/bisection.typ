#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let s = 2

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
    line((x_min, 0), (x_max * s, 0), mark: (end: ">", size: 0.5), name: "axis", stroke: 1.5pt)
    content("axis.end", anchor: "west", padding: .2)[$x$]

    // Curve
    let domain = range(0, 45).map(x => x/10)
    line(..domain.map(x => (x * s, f(x) * s)), stroke: blue + 3pt, name: "f")
    content((4 * s, f(4) * s), anchor: "west", padding: 0.2)[$f(x)$]

    // Points and vertical lines
    // Added parameters for label position to customize for a, b, and c
    let draw_point(x, label_text, color, label_y: -0.4, label_anchor: "north") = {
        let y = f(x)
        line((x * s, 0), (x * s, y * s), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))
        circle((x * s, y * s), radius: 0.15, fill: color, stroke: none)
        line((x * s, 0.1 * s), (x * s, -0.1 * s), stroke: gray + 1.5pt)
        content((x * s, label_y * s), anchor: label_anchor)[#label_text]
    }

    // a: dashed line goes down, so put label ABOVE axis
    draw_point(a, $a$, red, label_y: 0.4, label_anchor: "south")

    // b, c: dashed line goes up, so put label BELOW axis (default)
    draw_point(b, $b$, red)
    draw_point(c, $c$, green)

    // Signs
    content((a * s + 0.15 * s, f(a) * s), anchor: "west")[$f(a) < 0$]
    content((b * s + 0.1 * s, f(b) * s), anchor: "west", padding: 0.1)[$f(b) > 0$]
    content((c * s - 0.5 * s, f(c) * s + 0.2 * s), anchor: "south")[$f(c) > 0$]

    // New interval arrow
    let arrow_y = -2.2
    line((a * s, arrow_y * s), (c * s, arrow_y * s), mark: (start: "|", end: ">", size: 0.5), stroke: red + 2.5pt)
    content(((a+c)/2 * s, arrow_y * s - 0.2 * s), anchor: "north")[Next Interval]

})

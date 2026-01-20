#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt) // Increased text size

#cetz.canvas({
    import cetz.draw: *

    // Scaling factors to make the graph larger
    let x_scale = 4.0
    let y_scale = 2.5

    let f(t) = 0.7 * calc.sin(2 * 3.14 * t) + 0.3 * calc.sin(5 * 3.14 * t)

    // Time domain plot
    let t_max = 2.0
    let x_max = t_max * x_scale
    let y_lim = 1.2 * y_scale

    // Axes
    line((0, 0), (x_max + 0.5, 0), mark: (end: ">", size: 0.5), name: "t_axis", stroke: 1.5pt)
    content("t_axis.end", anchor: "west", padding: 0.2)[$t$]

    line((0, -y_lim), (0, y_lim), mark: (end: ">", size: 0.5), name: "y_axis", stroke: 1.5pt)
    content("y_axis.end", anchor: "south", padding: 0.2)[$x(t)$]

    // Function Curve
    let domain = range(0, 200).map(x => x/100 * t_max)
    line(..domain.map(t => (t * x_scale, f(t) * y_scale)), stroke: blue + 3pt)

    // Sampling points
    let n_samples = 15
    for i in range(0, n_samples) {
        let t = i * t_max / n_samples
        let x_pos = t * x_scale
        let y_val = f(t) * y_scale

        // Vertical dashed lines
        line((x_pos, 0), (x_pos, y_val), stroke: (dash: "dashed", paint: gray, thickness: 1.5pt))

        // Points
        circle((x_pos, y_val), radius: 0.15, fill: red, stroke: none)
    }

    // Annotation
    content((1.0 * x_scale, 1.4 * y_scale))[Sampled Signal]
})

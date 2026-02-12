#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *
    
    let s = 2.0
    let dx = 1.5
    let dt = 1.5
    
    // Axis
    line((-0.5, 0), (2.5*dx*s, 0), mark: (end: "stealth"), stroke: 1pt)
    content((2.5*dx*s, 0), anchor: "west")[$x$]
    line((0, -0.5), (0, 1.8*dt*s), mark: (end: "stealth"), stroke: 1pt)
    content((0, 1.8*dt*s), anchor: "south")[$t$]

    // Grid points
    for i in (0, 1, 2) {
        for n in (0, 1) {
            circle((i*dx*s + dx*s/2, n*dt*s + dt*s/2), radius: 0.1*s, fill: gray.lighten(80%))
        }
    }
    
    // Dependency lines
    let center_n = (dx*s + dx*s/2, dt*s/2)
    let center_np1 = (dx*s + dx*s/2, dt*s + dt*s/2)
    let left_n = (dx*s/2, dt*s/2)
    let right_n = (2*dx*s + dx*s/2, dt*s/2)
    
    line(center_np1, left_n, stroke: 1.5pt + blue)
    line(center_np1, center_n, stroke: 1.5pt + blue)
    line(center_np1, right_n, stroke: 1.5pt + blue)
    
    // Points of interest
    circle(center_np1, radius: 0.15*s, fill: red)
    content(center_np1, anchor: "south", padding: 0.2*s)[$u_i^(n+1)$]
    
    circle(center_n, radius: 0.12*s, fill: blue)
    content(center_n, anchor: "north-west", padding: 0.1*s)[$u_i^n$]
    
    circle(left_n, radius: 0.12*s, fill: blue)
    content(left_n, anchor: "north", padding: 0.2*s)[$u_(i-1)^n$]
    
    circle(right_n, radius: 0.12*s, fill: blue)
    content(right_n, anchor: "north", padding: 0.2*s)[$u_(i+1)^n$]
    
    content((1.5*dx*s, -0.8*s))[FTCS Scheme (Diffusion)]
})

#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *
    
    let s = 2.0
    let dx = 1.5
    let dt = 1.2
    
    // Axis
    line((-0.5, 0), (2.5*dx*s, 0), mark: (end: "stealth"), stroke: 1pt)
    content((2.5*dx*s, 0), anchor: "west")[$x$]
    line((0, -0.5), (0, 2.5*dt*s), mark: (end: "stealth"), stroke: 1pt)
    content((0, 2.5*dt*s), anchor: "south")[$t$]

    // Grid points
    for i in (0, 1, 2) {
        for n in (0, 1, 2) {
            circle((i*dx*s + dx*s/2, n*dt*s + dt*s/2), radius: 0.1*s, fill: gray.lighten(80%))
        }
    }
    
    let p_nm1 = (dx*s + dx*s/2, 0*dt*s + dt*s/2)
    let p_n_left = (0*dx*s + dx*s/2, 1*dt*s + dt*s/2)
    let p_n_mid = (1*dx*s + dx*s/2, 1*dt*s + dt*s/2)
    let p_n_right = (2*dx*s + dx*s/2, 1*dt*s + dt*s/2)
    let p_np1 = (1*dx*s + dx*s/2, 2*dt*s + dt*s/2)
    
    // Dependency lines
    line(p_np1, p_n_left, stroke: 1.5pt + green.darken(20%))
    line(p_np1, p_n_mid, stroke: 1.5pt + green.darken(20%))
    line(p_np1, p_n_right, stroke: 1.5pt + green.darken(20%))
    line(p_np1, p_nm1, stroke: 1.5pt + green.darken(20%))
    
    // Points
    circle(p_np1, radius: 0.15*s, fill: red)
    content(p_np1, anchor: "south", padding: 0.2*s)[$u_i^(n+1)$]
    
    circle(p_n_mid, radius: 0.12*s, fill: blue)
    content(p_n_mid, anchor: "south-west", padding: 0.1*s)[$u_i^n$]
    circle(p_n_left, radius: 0.12*s, fill: blue)
    content(p_n_left, anchor: "north", padding: 0.2*s)[$u_(i-1)^n$]
    circle(p_n_right, radius: 0.12*s, fill: blue)
    content(p_n_right, anchor: "north", padding: 0.2*s)[$u_(i+1)^n$]
    
    circle(p_nm1, radius: 0.12*s, fill: orange)
    content(p_nm1, anchor: "north", padding: 0.2*s)[$u_i^(n-1)$]
    
    content((1.5*dx*s, -0.8*s))[3-level Scheme (Wave)]
})

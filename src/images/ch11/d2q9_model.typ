#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let s = 2.0
  let r = 2

  // 1. Grid lines background
  rect((-r * s, -r * s), (r * s, r * s), stroke: (paint: gray, dash: "dotted", thickness: 1.5pt))

  // Directions
  let dirs = (
    (1, 0, "e_1"), (0, 1, "e_2"), (-1, 0, "e_3"), (0, -1, "e_4"),
    (1, 1, "e_5"), (-1, 1, "e_6"), (-1, -1, "e_7"), (1, -1, "e_8")
  )

  // 2. Velocity vectors
  for (dx, dy, label) in dirs {
    line((0, 0), (dx * r * s, dy * r * s), mark: (end: ">", size: 0.6), stroke: 2.5pt)
  }

  // 3. Center Point
  circle((0, 0), radius: 0.15 * s, fill: black)

  // 4. Center Label e0
  content((0.5 * s, -0.2 * s), anchor: "center")[
    #box(fill: white, inset: 1pt)[$e_0$]
  ]

  // 5. End Points and Outer Labels
  for (dx, dy, label) in dirs {
    circle((dx * r * s, dy * r * s), radius: 0.1 * s, fill: gray)

    // Closer position (1.1 instead of 1.2)
    let lx = dx * r * s * 1.1
    let ly = dy * r * s * 1.1

    let anch = "center"
    if dx > 0 { anch = "west" }
    else if dx < 0 { anch = "east" }

    if dy > 0 {
        if dx == 0 { anch = "south" }
    } else if dy < 0 {
        if dx == 0 { anch = "north" }
    }

    content((lx, ly), anchor: anch)[
        #box(fill: white, inset: 1pt)[$#label$]
    ]
  }
})

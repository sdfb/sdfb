# Demo for Group Network

Goal: to display the network of group members (in such a way as to encourage users to find and record new group members)

This demo uses the Virginia Company, one of the larger groups in our dataset. (This group also happens to include our pal, Francis Bacon.)

### Features

- Use dropdown to go between two views:
  1. Group members and all 1-degree connections from each group member (well-connected graph)
  2. Only group members (very sparse graph)

- Use slider for confidence level (currently only configured for 60% and above)
- Scroll to zoom
- Click on a node to see ego network & metadata
- Group members are on a single color gradient based on degree centrality in the *full* graph (the bluer and larger the node, the more connections it has)
- One-degree connected nodes are set to a fixed size and color (gray)

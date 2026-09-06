import 'package:flutter/material.dart';
import '../../../../core/models/journey_node.dart';
import 'roadmap_node_widget.dart';
import 'winding_path_painter.dart';

class WindingRoadmap extends StatelessWidget {
  final List<JourneyNode> nodes;
  final Function(JourneyNode) onNodeTap;

  const WindingRoadmap({
    super.key,
    required this.nodes,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double centerX = width / 2;
        final double horizontalOffset = width * 0.25;
        const double verticalSpacing = 160.0;
        
        final List<Offset> positions = [];
        for (int i = 0; i < nodes.length; i++) {
          final double y = 80.0 + (i * verticalSpacing);
          double x;
          if (i % 2 == 0) {
            x = centerX - horizontalOffset;
          } else {
            x = centerX + horizontalOffset;
          }
          positions.add(Offset(x, y));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: SizedBox(
            height: nodes.length * verticalSpacing + 200,
            width: width,
            child: Stack(
              children: [
                // Path
                CustomPaint(
                  size: Size(width, nodes.length * verticalSpacing + 200),
                  painter: WindingPathPainter(
                    nodePositions: positions,
                    pathColor: Colors.orange.withOpacity(0.4),
                  ),
                ),
                // Nodes
                ...List.generate(nodes.length, (index) {
                  final node = nodes[index];
                  final pos = positions[index];
                  
                  return Positioned(
                    left: pos.dx - 60, // Center the widget (approximate width 120)
                    top: pos.dy - 40,  // Vertical alignment
                    child: SizedBox(
                      width: 120,
                      child: RoadmapNodeWidget(
                        node: node,
                        onTap: () => onNodeTap(node),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/models/journey_node.dart';
import 'roadmap_node_widget.dart';
import 'winding_path_painter.dart';

class WindingRoadmap extends StatelessWidget {
  final List<JourneyNode> nodes;
  final Function(JourneyNode) onNodeTap;
  final Function(String pathId, String nodeId)? onPrewarmHorizon;

  const WindingRoadmap({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.onPrewarmHorizon,
  });

  void _checkHorizonListener(int currentIndex) {
    if (onPrewarmHorizon == null) return;
    // Check node N+1 and N+2
    for (int step = 1; step <= 2; step++) {
      final nextIdx = currentIndex + step;
      if (nextIdx < nodes.length) {
        final candidate = nodes[nextIdx];
        if (!candidate.isElaborated) {
          final effectivePathId = candidate.journeyId.isNotEmpty
              ? candidate.journeyId
              : (nodes[currentIndex].journeyId.isNotEmpty
                  ? nodes[currentIndex].journeyId
                  : 'active-path');
          onPrewarmHorizon!(effectivePathId, candidate.id);
        }
      }
    }
  }

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
          if (nodes[i].isRemediation) {
            // Remediation nodes branch out in an outward detour lateral arch
            x = (i % 2 == 0)
                ? centerX - (horizontalOffset * 1.35)
                : centerX + (horizontalOffset * 1.35);
          } else if (i % 2 == 0) {
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
                // Winding Path with Remediation Detour Splines
                CustomPaint(
                  size: Size(width, nodes.length * verticalSpacing + 200),
                  painter: WindingPathPainter(
                    nodePositions: positions,
                    nodes: nodes,
                    pathColor: Colors.orange.withOpacity(0.4),
                  ),
                ),
                // Nodes with Detour and Fast-Track Badges
                ...List.generate(nodes.length, (index) {
                  final node = nodes[index];
                  final pos = positions[index];

                  return Positioned(
                    left: pos.dx - 60, // Center the node widget
                    top: pos.dy - 40,
                    child: SizedBox(
                      width: 120,
                      child: RoadmapNodeWidget(
                        node: node,
                        onTap: () {
                          // Horizon listener triggers background pre-warm on N+1 and N+2
                          _checkHorizonListener(index);
                          onNodeTap(node);
                        },
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

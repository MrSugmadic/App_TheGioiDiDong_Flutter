import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String specs;
  final String price;

  const ProductCard({super.key, required this.name, required this.specs, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(child: Icon(Icons.laptop, size: 80, color: Colors.grey[300])),
                Positioned(
                  top: 8, right: 8,
                  child: Icon(Icons.compare_arrows, size: 18, color: Colors.blue[300]),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                  child: Text(specs, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
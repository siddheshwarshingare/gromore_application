import 'package:flutter/material.dart';

class ManageVegetablesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Vegetable Prices")),
      body: ListView(
        children: [
          // List of vegetables, use ListView.builder to show vegetables
          ListTile(
            title: Text("Carrot"),
            subtitle: Text("₹ 40"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Show dialog to edit price
              },
            ),
          ),
          // Add other vegetables here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add New Vegetable Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

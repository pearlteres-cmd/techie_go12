import 'package:flutter/material.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const _StaffDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF7209B7).withOpacity(0.1),
                  child: const Icon(
                    Icons.person_outline,
                    size: 30,
                    color: Color(0xFF7209B7),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Admin User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF7209B7)),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              children: const [
                _StatCard(
                  icon: Icons.pending_actions,
                  value: '12',
                  label: 'New Complaints',
                  color: Color(0xFFF72585),
                ),
                _StatCard(
                  icon: Icons.build,
                  value: '8',
                  label: 'In Progress',
                  color: Color(0xFF4CC9F0),
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  value: '45',
                  label: 'Resolved Today',
                  color: Color(0xFF06D6A0),
                ),
                _StatCard(
                  icon: Icons.timer,
                  value: '2.3',
                  label: 'Avg. Days',
                  color: Color(0xFF7209B7),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending Assignments
            const Text(
              'Complaints Pending Assignment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildPendingComplaintsTable(),

            const SizedBox(height: 24),

            // Available Technicians
            const Text(
              'Available Technicians',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildTechniciansList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingComplaintsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Complaint ID',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Service',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Priority',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            _buildComplaintRow(
              id: '#TC2025010',
              service: 'Data Recovery',
              priority: 'High',
              priorityColor: const Color(0xFFF72585),
            ),
            _buildComplaintRow(
              id: '#TC2025009',
              service: 'Hardware Upgrade',
              priority: 'Medium',
              priorityColor: const Color(0xFFFFD166),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintRow({
    required String id,
    required String service,
    required String priority,
    required Color priorityColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(service)),
          Expanded(
            child: Text(
              priority,
              style:
                  TextStyle(color: priorityColor, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Assign'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniciansList() {
    final technicians = [
      {
        'id': 'TECH101',
        'name': 'Alex Johnson',
        'specialization': 'Laptop Repair',
        'load': '3 tasks',
        'rating': '4.5 ★',
        'status': 'Available',
        'statusColor': const Color(0xFF06D6A0),
      },
      {
        'id': 'TECH102',
        'name': 'Sarah Miller',
        'specialization': 'Software/OS',
        'load': '2 tasks',
        'rating': '4.8 ★',
        'status': 'Available',
        'statusColor': const Color(0xFF06D6A0),
      },
      {
        'id': 'TECH103',
        'name': 'Mike Chen',
        'specialization': 'Data Recovery',
        'load': '5 tasks',
        'rating': '4.2 ★',
        'status': 'Busy',
        'statusColor': const Color(0xFFF72585),
      },
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: technicians.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade200,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final tech = technicians[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF7209B7).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF7209B7),
              ),
            ),
            title: Text(
              tech['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${tech['id']}'),
                Text('Specialization: ${tech['specialization']}'),
                Row(
                  children: [
                    Text('Load: ${tech['load']}'),
                    const SizedBox(width: 16),
                    Text('Rating: ${tech['rating']}'),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                tech['status'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: tech['statusColor'] as Color,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffDrawer extends StatelessWidget {
  const _StaffDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Color(0xFF4361EE),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Staff Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Admin User',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Complaints'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Assign Technician'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Technicians'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

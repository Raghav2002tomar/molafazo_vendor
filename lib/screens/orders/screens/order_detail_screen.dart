import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../chat/screens/chat_detail_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final bool awaitingPickup;

  const OrderDetailScreen({super.key, this.awaitingPickup = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
        body: SafeArea(
          child: Column(
            children: [
              // 🔹 SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _orderIdCard(),
                      const SizedBox(height: 16),
                      _customerInfo(context),
                      const SizedBox(height: 16),
                      _orderItems(),
                      const SizedBox(height: 16),
                      _totalRow(),
                      if (awaitingPickup) ...[
                        const SizedBox(height: 20),
                        _agentInfo(),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // 🔹 FIXED BOTTOM BUTTON
              if (!awaitingPickup)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _processButton(),
                ),
            ],
          ),
        )
    );
  }

  // ================= ORDER ID =================

  Widget _orderIdCard() {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Order ID",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Text(
            "#ORD-092384",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ================= CUSTOMER INFO =================

  Widget _customerInfo(context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, "Customer Information",true),
          const SizedBox(height: 10),
          _infoRow("Name", "Raiden Lord"),
          _infoRow("Phone", "08092345678"),
          const SizedBox(height: 12),
          _sectionTitle(context,"Delivery Address",false),
          const SizedBox(height: 8),
          const Text(
            "16, First Love Estate,\nIkorodu, Lagos State",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ================= ORDER ITEMS =================

  Widget _orderItems() {
    return _card(
      child: Column(
        children: [
          _item("Mama Gold Rice", "2 bags", "₦90,000"),
          _divider(),
          _item("Tatashe", "1 Paint rubber", "₦25,000"),
          _divider(),
          _item("Mama Gold Rice", "2 bags", "₦90,000"),
          _divider(),
          _item("Tomatoes", "1 Basket", "₦30,000"),
        ],
      ),
    );
  }

  Widget _item(String title, String subtitle, String price) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.image_not_supported),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ================= TOTAL =================

  Widget _totalRow() {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Total", style: TextStyle(fontWeight: FontWeight.w600)),
          Text("₦275,000", style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= AGENT =================

  Widget _agentInfo() {
    return _card(
      child: Row(
        children: [
          const CircleAvatar(radius: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Order awaiting pickup · 9:00 am\nAdekunte is on his way",
              style: TextStyle(fontSize: 12),
            ),
          ),
          Icon(Icons.call, color: Colors.green.shade700),
        ],
      ),
    );
  }

  // ================= BUTTON =================

  Widget _processButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: () {},
        child: const Text("Process Order"),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(context, String text, ischat) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
     if(ischat)   InkWell(onTap: (){
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => ChatDetailScreen(
             name: "raghav",
             image: "raghav",
           ),
         ),
       );
     }, child: SvgPicture.asset("assets/images/chat.svg"))
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1),
    );
  }
}

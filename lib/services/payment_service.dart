import 'package:flutter/material.dart';
import 'package:tss_razorpay_plugin/tss_razorpay_plugin.dart';
import 'package:techie_go/services/api_service.dart';

class PaymentService {
  static Future<void> payForComplaint({
    required BuildContext context,
    required String complaintId,
    required double amount,
    required String buyerEmail,
    required String buyerPhone,
    required String complaintTitle,
  }) async {
    final token = await ApiService.getToken();
    if (token == null) {
      _showSnackBar(context, 'Please login again', Colors.red);
      return;
    }

    // 1. Create order via backend
    final orderResponse = await ApiService.createPaymentOrder(
      token: token,
      complaintId: complaintId,
    );

    if (!orderResponse['success']) {
      _showSnackBar(
        context,
        orderResponse['message'] ?? 'Failed to create order',
        Colors.red,
      );
      return;
    }

    // 2. Extract data from response (with null safety)
    final data = orderResponse['data'] ?? {};
    final orderId = data['orderId']?.toString() ?? '';
    final amountInPaise = data['amount'] ?? 0; // amount is in paise (int)
    final isMock = data['mock'] == true;

    // 3. If mock mode, simulate success directly
    if (isMock) {
      // Simulate payment success
      final verifyResponse = await ApiService.verifyPayment(
        token: token,
        razorpayOrderId: orderId,
        razorpayPaymentId: 'mock_payment_id',
        razorpaySignature: 'mock_signature',
      );

      if (verifyResponse['success']) {
        _showSnackBar(context, 'Payment successful! (Mock)', Colors.green);
      } else {
        _showSnackBar(
          context,
          verifyResponse['message'] ?? 'Mock verification failed',
          Colors.red,
        );
      }
      return;
    }

    // 4. Real Razorpay flow (requires valid key)
    // IMPORTANT: Replace with your actual Razorpay test/live key
    const razorpayKey = 'rzp_test_xxxxxxxxxxxx'; // ← set your test key here

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RzPage(
          amt: amountInPaise.toString(),
          companyName: 'TechieGo',
          orderDescription: 'Payment for complaint: $complaintTitle',
          razorpayKeyId: razorpayKey,
          orderId: orderId,
          buyerPhNo: buyerPhone,
          buyerEmail: buyerEmail,
          callbacks: RzCallbacks(
            onPaymentSuccess: () {
              // This is called after successful UI, but we still need to verify
            },
            onPaymentError: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Payment cancelled', Colors.orange);
            },
          ),
          onPaymentUpdate: (status, data) async {
            print('Payment status: $status, data: $data');
            if (status == 'SUCCESS') {
              final paymentId = data['razorpay_payment_id']?.toString() ?? '';
              final signature = data['razorpay_signature']?.toString() ?? '';

              final verifyResponse = await ApiService.verifyPayment(
                token: token,
                razorpayOrderId: orderId,
                razorpayPaymentId: paymentId,
                razorpaySignature: signature,
              );

              if (verifyResponse['success']) {
                Navigator.pop(context); // close RzPage
                _showSnackBar(context, 'Payment successful!', Colors.green);
              } else {
                _showSnackBar(
                  context,
                  verifyResponse['message'] ?? 'Verification failed',
                  Colors.red,
                );
              }
            }
          },
        ),
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

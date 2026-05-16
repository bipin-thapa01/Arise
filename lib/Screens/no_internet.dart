// no_internet.dart
import 'package:flutter/material.dart';
import 'package:fitness/connectivity_service.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    await ConnectivityService.instance.checkNow();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 100,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 32),
              Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Please check your Wi-Fi or mobile data and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRetrying
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Retry', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../Core/Const/app_color.dart';
import '../Model/ccavenue_init_response.dart';

class CcAvenueCheckoutResult {
  final bool callbackReached;
  final bool cancelled;
  final String? encResp;
  final String? finalUrl;

  const CcAvenueCheckoutResult({
    required this.callbackReached,
    required this.cancelled,
    this.encResp,
    this.finalUrl,
  });
}

class CcAvenueCheckoutScreen extends StatefulWidget {
  final CcAvenueInitData initData;

  const CcAvenueCheckoutScreen({super.key, required this.initData});

  @override
  State<CcAvenueCheckoutScreen> createState() => _CcAvenueCheckoutScreenState();
}

class _CcAvenueCheckoutScreenState extends State<CcAvenueCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _callbackDetected = false;
  bool _isClosing = false;
  String? _lastUrl;
  String? _error;

  bool _isCallbackUrl(String url) {
    final redirect = widget.initData.redirectUrl.trim();
    final cancel = widget.initData.cancelUrl.trim();

    if (redirect.isNotEmpty && url.startsWith(redirect)) return true;
    if (cancel.isNotEmpty && url.startsWith(cancel)) return true;

    return false;
  }

  String _buildAutoPostHtml({
    required String action,
    required String encRequest,
    required String accessCode,
  }) {
    final a = htmlEscape.convert(action);
    final enc = htmlEscape.convert(encRequest);
    final ac = htmlEscape.convert(accessCode);

    return '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="utf-8">
    <title>CCAvenue</title>
  </head>
  <body onload="document.forms[0].submit()">
    <form action="$a" method="POST">
      <input type="hidden" name="encRequest" value="$enc" />
      <input type="hidden" name="access_code" value="$ac" />
      <noscript>
        <button type="submit">Continue</button>
      </noscript>
    </form>
  </body>
</html>
''';
  }

  @override
  void initState() {
    super.initState();

    final init = widget.initData;

    final html = _buildAutoPostHtml(
      action: init.form.action,
      encRequest: init.form.fields.encRequest,
      accessCode: init.form.fields.accessCode,
    );

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                _lastUrl = url;
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                if (_isCallbackUrl(url)) _callbackDetected = true;
              },
              onPageFinished: (url) async {
                _lastUrl = url;
                setState(() => _isLoading = false);

                if (_isClosing) return;
                if (!_callbackDetected) return;
                if (!_isCallbackUrl(url)) return;

                await _closeWithBestEffortEncResp(url);
              },
              onNavigationRequest: (request) {
                final url = request.url;
                _lastUrl = url;
                if (_isCallbackUrl(url)) _callbackDetected = true;
                return NavigationDecision.navigate;
              },
              onWebResourceError: (err) {
                setState(() {
                  _isLoading = false;
                  _error = err.description;
                });
              },
            ),
          )
          ..loadHtmlString(html);
  }

  Future<void> _closeWithBestEffortEncResp(String url) async {
    if (!mounted || _isClosing) return;
    _isClosing = true;

    String? encResp;

    // 1) Query param (if backend returns it in URL)
    try {
      final uri = Uri.parse(url);
      final qp = uri.queryParameters['encResp'];
      if (qp != null && qp.trim().isNotEmpty) encResp = qp.trim();
    } catch (_) {
      // ignore
    }

    // 2) Hidden input on the callback page (best-effort)
    if (encResp == null || encResp.isEmpty) {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 250));

        final js = '''
(() => {
  const el = document.querySelector('input[name="encResp"]');
  return el ? el.value : '';
})()
''';

        final v = await _controller.runJavaScriptReturningResult(js);
        final s = v?.toString() ?? '';

        // Some platforms wrap string results in quotes.
        final normalized =
            s.startsWith('"') && s.endsWith('"') && s.length >= 2
                ? s.substring(1, s.length - 1)
                : s;

        if (normalized.trim().isNotEmpty) encResp = normalized.trim();
      } catch (_) {
        // ignore
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      CcAvenueCheckoutResult(
        callbackReached: true,
        cancelled: false,
        encResp: encResp,
        finalUrl: url,
      ),
    );
  }

  Future<void> _retry() async {
    final init = widget.initData;
    final html = _buildAutoPostHtml(
      action: init.form.action,
      encRequest: init.form.fields.encRequest,
      accessCode: init.form.fields.accessCode,
    );

    setState(() {
      _error = null;
      _callbackDetected = false;
      _isClosing = false;
      _isLoading = true;
    });

    await _controller.loadHtmlString(html);
  }

  void _cancel() {
    if (_isClosing) return;
    _isClosing = true;
    Navigator.of(context).pop(
      CcAvenueCheckoutResult(
        callbackReached: _callbackDetected,
        cancelled: true,
        encResp: null,
        finalUrl: _lastUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 0,
          title: const Text('Payment'),
          leading: IconButton(
            onPressed: _cancel,
            icon: const Icon(Icons.close, color: Colors.black),
          ),
          actions: [
            if (_error != null)
              TextButton(
                onPressed: _retry,
                child: const Text('Retry'),
              ),
          ],
        ),
        body: Stack(
          children: [
            if (_error == null) WebViewWidget(controller: _controller),
            if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 44),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retry,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _cancel,
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading && _error == null)
              const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}


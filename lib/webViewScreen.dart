// PWVS.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

// void main() async {
//   var url = await iCreditGetUrl(
//       buyer_name: 'IDAN TEST',
//       city: 'Gedera test',
//       street: 'Hedera',
//       email: 'idan@test.cocom',
//       phone: '0543232761',
//       total_price: 301);
//   print(url);
//   runApp(MaterialApp(home: PaymentWebview(url: url)));
// }


class PaymentWebView extends StatefulWidget {
  final String? url;

  const PaymentWebView({super.key, this.url});

  @override
  State<PaymentWebView> createState() => PaymentWebViewState();
}

class PaymentWebViewState extends State<PaymentWebView> {

  /*
  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    initWebView();
  }


  void initWebView() {
    final flutterWebviewPlugin = FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('/order-received/')) {
        final items = url.split('/order-received/');
        if (items.length > 1) {
          final number = items[1].split('/')[0];
          widget.onFinish!(number);
          Navigator.of(context).pop();
        }
      }
      if (url.contains('checkout/success')) {
        widget.onFinish!('0');
        Navigator.of(context).pop();
      }

      // shopify url final checkout
      if (url.contains('thank_you')) {
        widget.onFinish!('0');
        Navigator.of(context).pop();
      }
    });

    // this code to hide some classes in website, change site-header class based on the website
    flutterWebviewPlugin.onStateChanged.listen((viewState) {
      if (viewState.type == WebViewState.finishLoad) {
        flutterWebviewPlugin.evalJavascript(
            'document.getElementsByClassName(\'site-header\')[0].style.display=\'none\';');
        flutterWebviewPlugin.evalJavascript(
            'document.getElementsByClassName(\'site-footer\')[0].style.display=\'none\';');
      }
    });

//    var givenJS = rootBundle.loadString('assets/extra_webview.js');
//    // ignore: missing_return
//    givenJS.then((String js) {
//      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
//        if (viewState.type == WebViewState.finishLoad) {
//          await flutterWebviewPlugin.evalJavascript(js);
//        }
//      });
//    });
  }

   */

  bool hideLoader = false;
  bool isLoading = true;
  bool firstSucceedRedirect = true;
  var _controller;
  var click_checkoutButton = true;

  var isErrStop = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 45)).then((_) {
      // print('Start Future');
      isErrStop = true;
      setState(() {});
    });

    // בעיקרון כדי לאפשר תשלומים
    // if (cartModel.getTotal()!.toDouble() > 1000.0) click_checkoutButton = false;
    // print('click_checkoutButton is $click_checkoutButton');

    var checkoutMap = <dynamic, dynamic>{'url': '', 'headers': <String, String>{}};
    // checkoutMap['headers'] = Map<String, String>.from(paymentInfo['headers']);

    return Scaffold(
      appBar: AppBar(
        title: Text(isErrStop ? 'חזור אחורה!' : 'תשלום מתבצע'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 3.0,
      ),
      body: Stack(
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: checkoutMap['url'],
            onProgress: (progress) async {
              var url = await _controller.currentUrl() ?? '';
              succeedRedirect(url); // if Based
            },
            onPageStarted: succeedRedirect,
            // Every new page.
            onWebViewCreated: (controller) async {
              // On first time.

              // Redirect when success = https://www.spider3d.co.il/תודה/ - https://www.spider3d.co.il/%D7%AA%D7%95%D7%93%D7%94/
              var url = await controller.currentUrl() ?? '';
              // print('url $url');
              succeedRedirect(url); // if Based

              setState(() => isLoading = true);
              _controller = controller;
              ;
              await controller.evaluateJavascript('console.log("Print TEST by JS")');

              // print('onWebViewCreated');
              await controller.getTitle();

              /*        await _controller.evaluateJavascript(
                  'var mainNodeList = document.getElementsByName("cardNum");'
                  'var mainArray = Array.from(mainNodeList);'
                  'mainNodeList.forEach(item => item.value = "C");'
                  'mainNodeList.forEach(item => console.log(item));'
                  'console.log("document.body");'
                  'console.log(document.body);'
                  'console.log("----------");'
                  'console.log(mainArray);');*/
            },
            onPageFinished: (url) async {
              succeedRedirect(url); // if Based

              setState(() => isLoading = false);
              // print('Current url $url');

              if (url.contains('icredit')) {
                var _month = '12';
                var _year = '2026';

                // await _controller.evaluateJavascript(
                //     'console.log("Scrolling page to bottom..");'
                //         'window.scrollTo(0,document.body.scrollHeight);'
                //     //
                //         "iframe_doc = document.getElementById('frame').contentDocument;"
                //     // iframe_doc.getElementsByTagName('input').cvv2.value = '1'
                //         "inputs = iframe_doc.getElementsByTagName('input');"
                //         "inputs.cardNum.value = '4580458045804580';" // '4600000000000000';"
                //         "inputs.id.value = '325245355';" // 325245355
                //     // "inputs.cvv2.value = '${addressModel.cardCvv}';" // 319
                //         "selects = iframe_doc.getElementsByTagName('select');"
                //     // "selects.ddlMonth.value = '$_month';" // So 03 -> 3
                //         "selects.ddlMonth.value = '$_month';" // So 03 -> 3
                //     // "selects.ddlYear.value  = '20$_year';" // 2021
                //         "selects.ddlYear.value  = '20$_year';" // 2021
                //   // "selects.ddlPayments.value = '2';" // תשלומים
                // );
              }

              if (url.contains('icredit') && click_checkoutButton) {
                await _controller.evaluateJavascript(
                    "iframe_doc = document.getElementById('frame').contentDocument;"
                    "payButton = document.getElementById('cardsubmitbtn');"
                    'payButton.click();');
              }
            },
          ),
          Offstage(
            offstage: hideLoader,
            child: buildMyLoader(context, isErr: isErrStop),
          )
          // isLoading ? Center(child: kLoadingWidget(context)) : Container()
        ],
      ),
    );

    /*
    return WebviewScaffold(
      withJavascript: true,
      appCacheEnabled: true,
      geolocationEnabled: true,
      url: checkoutMap['url'],
      headers: checkoutMap['headers'],
      // it's possible to add the Agent to fix the payment in some cases
      // userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish!(null);
              Navigator.of(context).pop();

              if (widget.onClose != null) {
                widget.onClose!();
              }
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );

     */
  }

  bool success = false;

  void succeedRedirect(url) {
    // print('Checking if url is succeed url: $url');
    // print('firstSucceedRedirect $firstSucceedRedirect');
    // if(firstSucceedRedirect) {
    //   print('Started');
    if ((url.contains('%D7%AA%D7%95%D7%93%D7%94') ||
            url.contains('spider') ||
            // url.contains('icredit') && kDebugMode || // For Tests ONLY! (AutoRedirect)
            url.contains('תודה')) &&
        success == false) {
      success = true;
      // print('Payment done succefully! Redirect..');

      // widget.onFinish!('Success');

      // Navigator.of(context).pop();
/*      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(
              builder: (_) => SuccessScreen()));*/
      return;
      // }
    }
  }
}

Container buildMyLoader(BuildContext context, {bool isErr = false}) {
  return Container(
    color: Colors.black26,
    child: Center(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
          width: 130,
          height: 120,
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 5),
              if (!isErr) ...[
                // kLoadingWidget(context),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 20, color: Colors.black),
                      const SizedBox(width: 5),
                      const Text(
                        'טוען...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.75,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'אירעה שגיאה',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.75,
                    ),
                  ),
                ),
              Text(
                isErr ? 'חזור בדוק והתקן את הפרטים' : 'אנא המתן',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isErr ? Colors.red[700] : Colors.black,
                  fontSize: 12,
                  letterSpacing: 0.75,
                ),
              ),
            ],
          )),
    )),
  );
}

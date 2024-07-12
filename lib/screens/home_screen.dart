import 'dart:developer';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/screens/load_screen.dart';
import 'package:velayo_flutterapp/screens/misc_screen.dart';
import 'package:velayo_flutterapp/screens/shopee_screen.dart';
import 'package:velayo_flutterapp/screens/wallet_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/home_button.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  late final AnimationController animationController;
  double _scaleTransformValue = 1;
  String selectedTransaction = "";
  String branchId = "";
  bool isValidating = false;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  initBluetooth() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      log("Bluetooth start here");
      devices = await bluetooth.getBondedDevices();
      print(devices);
      log("Bluetooth end here");
      if (devices.isEmpty) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "No nearby bluetooth printer detected",
            ),
            snackBarPosition: SnackBarPosition.bottom,
            animationDuration: const Duration(milliseconds: 700),
            displayDuration: const Duration(seconds: 1));
        return;
      } else {
        BluetoothDevice? printerDevice =
            devices.where((e) => e.name == "BlueTooth Printer").firstOrNull;
        if (printerDevice != null) {
          bluetooth.isConnected.then((e) => bluetooth.connect(printerDevice));
        } else {
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: "Not connected to printer",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 0));
        }
      }
    } on PlatformException {}
  }

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((b) {
        BlocProvider.of<BranchBloc>(context).add(GetBranches(onDone: () {
          if (b != "") {
            branchId = b;
            BlocProvider.of<AppBloc>(context).add(SetSelectedBranch(
                branch: BlocProvider.of<BranchBloc>(context)
                    .state
                    .branches
                    .firstWhere((e) => e.id == b)));
            BlocProvider.of<UtilBloc>(context).add(GetLastQueue(branchId: b));

            setState(() {});
          }
        }));
      });
    });

    initBluetooth();
    super.initState();
  }

  Widget showNoOfferSelected() {
    final utilBloc = context.watch<UtilBloc>();

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Printer printer = Printer();
              printer.sample();
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  barrierDismissible: !isValidating,
                  builder: (BuildContext context) =>
                      StatefulBuilder(builder: (context, setState) {
                        return Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: BlocBuilder<AppBloc, AppState>(
                              builder: (context, state) {
                                return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    width: 500,
                                    height: 400,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Administrative Area",
                                          style: TextStyle(
                                              fontFamily: "abel",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 32.0),
                                        ),
                                        const SizedBox(height: 16.0),
                                        if (isValidating)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 10.0),
                                                  child: const Text(
                                                      "Validating....")),
                                              const SizedBox(width: 15.0),
                                              const SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          const Text(
                                            "Please enter a pin code to access this area",
                                            style: TextStyle(
                                                fontFamily: "abel",
                                                fontSize: 22.0),
                                          ),
                                        const SizedBox(height: 16.0),
                                        Pin(
                                          length: 6,
                                          disabled: isValidating,
                                          onComplete: (pin) {
                                            String adminPin =
                                                state.selectedBranch != null
                                                    ? state.selectedBranch
                                                            ?.pin ??
                                                        ""
                                                    : state.settings?.pin ?? "";

                                            isValidating = true;

                                            if (adminPin == pin) {
                                              isValidating = false;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                  context, "/admin");
                                            } else {
                                              isValidating = false;
                                              showTopSnackBar(
                                                  Overlay.of(context),
                                                  const CustomSnackBar.error(
                                                    message: "PIN is incorrect",
                                                  ),
                                                  snackBarPosition:
                                                      SnackBarPosition.bottom,
                                                  animationDuration:
                                                      const Duration(
                                                          milliseconds: 700),
                                                  displayDuration:
                                                      const Duration(
                                                          seconds: 1));
                                            }

                                            setState(() {});
                                          },
                                        ),
                                        Text(
                                            "Current Selected Branch: ${state.selectedBranch != null ? state.selectedBranch!.name : "None"}")
                                      ],
                                    ));
                              },
                            ));
                      }));
            },
            child: const Image(
              image: AssetImage('assets/images/image-home1.png'),
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 15.0),
          const Text(
            "Welcome to Velayo Customer Queue App",
            style: TextStyle(
                fontSize: 42, fontFamily: 'abel', fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15.0),
          const Text(
            "Please select an offer list to the left side to continue or just print a queue",
            style: TextStyle(fontSize: 22, fontFamily: 'abel'),
          ),
          const SizedBox(height: 5.0),
          Transform.scale(
              scale: _scaleTransformValue,
              child: Button(
                label: branchId == "" ? "No Branch Selected" : "PRINT A QUEUE",
                textColor: Colors.black87,
                isLoading: utilBloc.state.status.isLoading,
                width: 200,
                onPress: branchId == ""
                    ? null
                    : () async {
                        animationController.forward();
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => animationController.reverse(),
                        );

                        Map<String, dynamic> request = {
                          "branchId": branchId,
                          "queue": utilBloc.state.lastQueue + 1,
                        };

                        utilBloc.add(NewQueue(
                            request: request,
                            branchId: branchId,
                            callback: (resp) {
                              if (resp) {
                                Navigator.pushNamed(
                                    context, '/request-success');
                                // showTopSnackBar(
                                //     Overlay.of(context),
                                //     const CustomSnackBar.success(
                                //       message:
                                //           "Print Successfully. Please get you queue. Thank you",
                                //     ),
                                //     snackBarPosition: SnackBarPosition.bottom,
                                //     animationDuration:
                                //         const Duration(milliseconds: 700),
                                //     displayDuration: const Duration(seconds: 1));
                              }
                            }));
                      },
              ))
        ],
      ),
    );
  }

  Widget showSelectedOffer() {
    return Expanded(
      child: Container(
          margin: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(25.0),
                width: MediaQuery.of(context).size.width * 0.72,
                decoration: BoxDecoration(
                    color: ACCENT_PRIMARY,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  selectedTransaction.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 28.0),
                )),
            if (selectedTransaction == "miscellaneous")
              MiscScreen(scaffoldKey: globalKey),
            if (selectedTransaction == "bills payment") const Bills(),
            if (selectedTransaction == "e-money") const Wallets(),
            if (selectedTransaction == "load") const LoadScreen(),
            if (selectedTransaction == "shopee collect")
              const ShopeeCollectScreen()
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawerEnableOpenDragGesture: false,
        resizeToAvoidBottomInset: true,
        // endDrawer: const CartDrawer(),
        key: globalKey,
        body: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(18.0),
              width: MediaQuery.of(context).size.width * 0.204,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 5,
                  childAspectRatio: 16 / 9,
                  crossAxisCount: 1,
                ),
                itemCount: home_offers.length,
                itemBuilder: (context, index) => HomeButton(
                  value: home_offers[index],
                  isSelected: home_offers[index].title.toLowerCase() ==
                      selectedTransaction,
                  onClick: () {
                    if (selectedTransaction ==
                        home_offers[index].title.toLowerCase()) {
                      setState(() {
                        selectedTransaction = "";
                      });
                      return;
                    }

                    setState(() {
                      selectedTransaction =
                          home_offers[index].title.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            if (selectedTransaction != "")
              showSelectedOffer()
            else
              showNoOfferSelected(),
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';
import 'package:velayo_flutterapp/screens/widgets/error_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  String searchedBiller = "";
  Widget showBillsList(List<Bill> bills) {
    var _bills = [...bills];

    if (searchedBiller != "") {
      _bills.removeWhere(
          (e) => !e.name.toLowerCase().contains(searchedBiller.toLowerCase()));
    } else {
      _bills = bills;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SELECT BILLER",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  onChanged: (val) => setState(() => searchedBiller = val),
                  decoration: textFieldStyle(
                      label: "Search Biller",
                      prefixIcon: const Icon(Icons.search),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                ),
              ),
            ],
          ),
          const Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 16 / 9,
              crossAxisCount: 4,
            ),
            itemCount: _bills.length,
            itemBuilder: (context, index) => Column(
              children: [
                Material(
                  color: ACCENT_PRIMARY,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {},
                    hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          "Image is here",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _bills[index].name,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillsBloc, BillState>(builder: (context, state) {
      return state.status.isSuccess
          ? showBillsList(state.bills)
          : state.status.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.8,
                  margin: const EdgeInsets.only(top: 15),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : state.status.isError
                  ? const ErrorScreen(title: "Fetching Bills Error")
                  : const SizedBox();
    });
  }
}
import 'package:another_flushbar/flushbar.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/cubit/cubit.dart';
import 'package:task/cubit/states.dart';
import 'models/product.dart';

Widget defaultButtom({
  double? width = double.infinity,
  Color? backgroundColor = Colors.deepOrange,
  required void Function()? function,
  required String? text,
  bool? isButtonDisabled,
}) =>
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isButtonDisabled! ? Colors.grey : backgroundColor,
      ),
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: function,
        style: ButtonStyle(
          backgroundColor: isButtonDisabled
              ? MaterialStateProperty.all<Color>(Colors.grey)
              : MaterialStateProperty.all<Color>(Colors.deepOrange),
        ),
        child: Text(
          text!,
        ),
      ),
    );
Widget defaultFormField(
  BuildContext context, {
  TextEditingController? controller,
  required TextInputType? type,
  Widget? suffix,
  required Widget? label,
  BorderRadius? borderRadius,
  Color? color = Colors.white,
  String? Function(String?)? validate,
  String? Function(String?)? onChange,
}) =>
    TextFormField(
        autovalidateMode: AutovalidateMode.always,
        style: TaskCubit.get(context).isDark
            ? const TextStyle(color: Colors.white)
            : const TextStyle(color: Colors.black),
        onChanged: onChange,
        validator: validate,
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
            suffixIcon: suffix,
            label: label,
            fillColor: color,

            // style: TextStyle(backgroundColor: Colors.white),
            border: OutlineInputBorder(borderRadius: borderRadius!),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 3, color: Colors.deepOrange),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.deepOrange),
            ),
            labelStyle: TaskCubit.get(context).isDark
                ? const TextStyle(
                    color: Colors.white,
                  )
                : const TextStyle(color: Colors.black)));
Widget BuildProductsItem(Product product, context) =>
    BlocConsumer<TaskCubit, TaskStates>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return ConditionalBuilder(
          condition: state is! GetDatabaseLoadingStates,
          builder: (context) => Container(
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            width: double.infinity,
            height: 100,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    // BuildProductsItem();
                    Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            overflow: TextOverflow.clip,
                            product.name,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              product.price.toString(),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 120,
                    ),
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(product.image),
                    ),
                  ],
                )),
          ),
          fallback: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      },
    );

void showFlushBar(BuildContext context, String message) {
  Flushbar(
    message: message,
    flushbarPosition: FlushbarPosition.TOP,
    duration: const Duration(seconds: 3),
  ).show(context);
}

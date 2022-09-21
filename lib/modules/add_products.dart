import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/cubit/states.dart';
import 'package:task/input.dart';
import 'package:task/network/dio_helper.dart';
import 'package:task/reusable_components.dart';
import 'package:task/cubit/cubit.dart';

class AddProdcuts extends StatefulWidget {
  final TaskCubit cubit;
  final Function(AddProductsInputData itemAdded) onAdd;

  const AddProdcuts({Key? key, required this.cubit, required this.onAdd})
      : super(key: key);

  @override
  State<AddProdcuts> createState() => _AddProdcutsState();
}

class _AddProdcutsState extends State<AddProdcuts> {
  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final priceController = TextEditingController();

  final _inputData = AddProductsInputData();

  @override
  Widget build(BuildContext context) {
    final cubit = TaskCubit.get(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Add Products"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: cubit.formKey,
          onChanged: cubit.changeButtonState,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BlocBuilder<TaskCubit, TaskStates>(
                      builder: (context, state) {
                        return CircleAvatar(
                          backgroundImage: cubit.image == null
                              ? null
                              : FileImage(cubit.image!),
                          radius: 80,
                        );
                      },
                    ),
                    GestureDetector(
                        onTap: cubit.pickImage,
                        child: const Icon(Icons.camera_alt))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                defaultFormField(context,
                    controller: nameController,
                    type: TextInputType.text,
                    label: const Text("Product Name"),
                    validate: (String? value) {
                  if (value!.isEmpty) {
                    return "Product Name Must not be Empty";
                  }
                  return null;
                }, onChange: (String? value) {
                  _inputData.name = value;
                  return null;
                }, borderRadius: BorderRadius.circular(20)),
                const SizedBox(
                  height: 20,
                ),
                defaultFormField(context,
                    controller: descriptionController,
                    type: TextInputType.text,
                    label: const Text("Product Descprition"),
                    validate: (String? value) {
                  if (value!.isEmpty) {
                    return "Description Must not be Empty";
                  }
                  return null;
                }, onChange: (String? value) {
                  _inputData.description = value;
                  return null;
                }, borderRadius: BorderRadius.circular(20)),
                const SizedBox(
                  height: 20,
                ),
                defaultFormField(context,
                    controller: priceController,
                    validate: (String? value) {
                      if (value!.isEmpty) {
                        return "price Must not be Empty";
                      }
                      return null;
                    },
                    type: const TextInputType.numberWithOptions(decimal: true),
                    label: const Text("price"),
                    onChange: (String? value) {
                      _inputData.price = value;
                      return null;
                    },
                    borderRadius: BorderRadius.circular(20)),
                const SizedBox(
                  height: 20,
                ),
                BlocBuilder<TaskCubit, TaskStates>(
                  builder: (context, state) {
                    return defaultButtom(
                        isButtonDisabled: !cubit.isButtonActive,
                        function: cubit.isButtonActive
                            ? () {
                                if (cubit.image == null) {
                                  showFlushBar(
                                    context,
                                    "Image is required",
                                  );
                                  return;
                                } else if (!cubit.isConnected) {
                                  widget.cubit
                                      .insertToDatabase(
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          price: priceController.text,
                                          image: cubit.image!.path)
                                      .then((value) => {
                                            Navigator.pop(context),
                                            showFlushBar(
                                              context,
                                              "Product Inserted Successfully local",
                                            ),
                                          });
                                } else {
                                  final data = {
                                    'name': nameController.text,
                                    'description': descriptionController.text,
                                    'price': priceController.text,
                                    "image": cubit.image == null
                                        ? null
                                        : MultipartFile.fromFileSync(
                                            cubit.image!.path,
                                            filename: cubit.image!.path,
                                          )
                                  };

                                  log("-=-=-=--=-==-=-$data");
                                  DioHelper.postData(
                                    'product/store',
                                    data: data,
                                  ).then((value) {
                                    if (value.statusCode == 200) {
                                      debugPrint("-=-==--==- success");
                                      Navigator.of(context).pop();

                                      showFlushBar(
                                        context,
                                        "Product Inserted Successfully to server",
                                      );
                                    } else {
                                      debugPrint(
                                          " ==-=---==--==-=-= ${value.statusCode}");
                                    }
                                  });
                                }
                              }
                            : null,
                        text: "Submit");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

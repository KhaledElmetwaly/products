import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/cubit/cubit.dart';
import 'package:task/cubit/states.dart';
import 'package:task/models/product.dart';
import 'package:task/modules/details_screen.dart';
import 'package:task/reusable_components.dart';

import 'add_products.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});
  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  var SearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  String _keyword = "";
  @override
  Widget build(BuildContext ctx) {
    return BlocConsumer<TaskCubit, TaskStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = TaskCubit.get(context);
        // cubit.getHome();

        return Scaffold(
          extendBody: true,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
                width: double.infinity,
                height: 40,
                child: defaultButtom(
                    isButtonDisabled: false,
                    function: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProdcuts(
                            cubit: cubit,
                            onAdd: (itemAdded) {},
                          ),
                        ),
                      ).then((value) {
                        cubit.getHome();
                      });
                    },
                    text: "Add Product")),
          ),
          appBar: AppBar(
            title: const Center(
              child: Text(
                "Manage Products",
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(children: [
                const SizedBox(
                  height: 10,
                ),
                // Text(ThemeMode.system.runtimeType.toString()),
                defaultFormField(context,
                    type: TextInputType.text,
                    label: const Text(
                      "Search",
                    ), onChange: (String? value) {
                  setState(() {
                    _keyword = value!;
                  });
                  return null;
                },
                    controller: SearchController,
                    borderRadius: BorderRadius.circular(20)),
                const SizedBox(
                  height: 20,
                ),

                if (state is getHomeLoadingState)
                  const CircularProgressIndicator(
                    color: Colors.deepOrange,
                  )
                else if (state is getHomeSuccessState)
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.separated(
                      shrinkWrap: true,
                      primary: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        final item = cubit.homeItems[index];

                        final productItem = Product(
                            name: item.name,
                            description: item.description,
                            price: item.price,
                            image: item.image);
                        return !item.name.contains(_keyword)
                            ? const SizedBox.shrink()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        product: productItem,
                                      ),
                                    ),
                                  ).then((value) {});
                                  return;
                                },
                                child: BuildProductsItem(productItem, context),
                              );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 20,
                          width: double.infinity,
                        );
                      },
                      itemCount: cubit.homeItems.length,
                    ),
                  ),

                if (state is GetDatabaseStates)
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.separated(
                      shrinkWrap: true,
                      primary: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return cubit.homeModel != null
                            // cubit.products[index].name.contains(_keyword) دا في حالة اللوكال داتا بيز
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        product: cubit.products[index],
                                      ),
                                    ),
                                  ).then((value) {});
                                  return;
                                },
                                child: BuildProductsItem(
                                    cubit.products[index], context),
                              )
                            : const SizedBox.shrink();
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 20,
                          width: double.infinity,
                        );
                      },
                      itemCount: cubit.products.length,
                    ),
                  ),

                // cubit.products.isEmpty
                //     ? const SizedBox.shrink()
                //     :
                const SizedBox(
                  height: 20,
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

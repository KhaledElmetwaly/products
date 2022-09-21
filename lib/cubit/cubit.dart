import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task/cubit/states.dart';
import 'package:task/models/home_model.dart';
import 'package:task/models/product.dart';
import 'package:task/network/dio_helper.dart';

class TaskCubit extends Cubit<TaskStates> {
  TaskCubit() : super(initialState());
  Database? database;
  File? image;
  final connectivity = Connectivity();

  List<Product> products = [];
  bool isButtonActive = false;
  final formKey = GlobalKey<FormState>();
  bool isConnected = true;

  static TaskCubit get(context) => BlocProvider.of(context);

  void initConnectionChecker() {
    connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.mobile) {
        isConnected = true;
        print(isConnected);
      } else {
        isConnected = false;
        print(isConnected);
      }
    });
  }

  void changeButtonState() {
    isButtonActive = formKey.currentState!.validate();
    emit(ChangeButton());
  }

  void pickImage() async {
    await ImagePicker.platform
        .pickImage(source: ImageSource.camera)
        .then((value) {
      image = File(value!.path);
    });

    emit(imagePickedState());
  }

  void createDatabase() async {
    print("-=-=-=before open");
    openDatabase(
      'products_db',
      version: 2,
      onCreate: (database, version) {
        print("Database Created");
        database
            .execute(
                'CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, description TEXT, price DOUBLE, image TEXT)')
            .then((value) {
          print("table created");
        }).catchError((error) {
          print("error when creating table ${error.toString()}");
        });
      },
      onOpen: (database) {
        this.database = database;
        getDataFromDatabase();
      },
    );
  }

  Future insertToDatabase(
      {required String name,
      required String description,
      required String price,
      required String image}) async {
    print(" name is $name");
    print(" price is $price");
    print(" desc is $description");
    print(" desc is $image");

    await database!.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO products (name, description, price, image) VALUES ("$name","$description","$price", "$image")')
          .then((value) {
        print("${value.runtimeType} inserted Successfully");
        emit(productInsertToDatabaseState());

        getDataFromDatabase();
      }).catchError((error) {
        print("error when inserting data ${error.toString()}");
      });
    });
  }

  bool isDark = false;
  void changeModes() {
    isDark = !isDark;
    emit(TaskChangeModeState());
  }

  getDataFromDatabase() async {
    products = [];
    emit(GetDatabaseLoadingStates());
    database!.rawQuery('SELECT * FROM products ').then((value) {
      for (var product in value) {
        products.add(Product.fromJson(product));
      }
      print("number of items ${products.length}");
      emit(GetDatabaseStates());
    });
  }

  HomeModel? homeModel;
  void getHome() {
    emit(getHomeLoadingState());
    DioHelper.getData(
      url: "product/index",
    ).then((value) {
      final model = HomeModel.fromJson(value.data);
      homeModel = model;
      homeItems = model.data.data.reversed.toList(growable: false);
      // print(value.data.toString());
      emit(getHomeSuccessState());
    }).catchError((error) {
      print("error when getting product ${error.toString()}");
      emit(getHomeErrorState(error.toString()));
    });
  }

  List<Datum> homeItems = [];
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd(); // Create a timedate object in format year-month-date

const uuid = Uuid(); // Generates a random ID in form of a string 

enum Category { food, travel, work, leisure } // enum like in sql, creates an enum that allows a list of default selection

const categoryIcon = { // A map function that works like a dictionary in python Key => Value
    Category.food : Icons.lunch_dining,
    Category.leisure : Icons.movie,
    Category.travel: Icons.flight_takeoff,
    Category.work: Icons.work
};

// Expense class that is later used to create objects based off the properties of the class
class Expense {

  // Class constructor that takes several arguments
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  })  : id = uuid.v4(); // uuid is used to generate random ID's for every object created in expenses.dart at default

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;


String get formattedDate { // Creates a getter to return a formatted date of a given argument 
    return formatter.format(date);
}

}
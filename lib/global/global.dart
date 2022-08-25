
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users/models/user_model_drawer.dart';
import '../models/directionDetailsInfo.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
userModel ? userModelCurrentInfo;
List driverList = []; //driversKeyInfo
DirectionDetailsInfo ?  tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken = "key=AAAAABJqWKs:APA91bGtTAAkYciOvuNFwe7kP5EflfJ1ZGsg8P-EsbJYm3ezJoXvpGj78OzeEVegmzKCZkLU636RXqoC2rYjxcDPVD8BjhFR3bQ0YXP30tBYazPvmAYNfEPbho_sZr1wSIQyQVEZfKYE";
String userDropOffAddress = "";
String driverCarDetails="";
String driverName="";
String driverPhone="";
double countRatingStars=0.0;
String titleStarsRating="";
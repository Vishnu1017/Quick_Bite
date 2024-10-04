import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  UpdateUserWallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({"wallet": amount});
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Stream<QuerySnapshot> getFoodItem(String name) {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future addFoodtoCart(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }

  Stream<QuerySnapshot> getFoodCart(String id) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .snapshots();
  }

  Future<void> addOrder(
      String userId, List<Map<String, dynamic>> cartItems, int total) async {
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'Cart': cartItems,
        'Total': total,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .get();

    List<Map<String, dynamic>> cartItems = cartSnapshot.docs.map((doc) {
      return {
        'Name': doc['Name'],
        'Quantity': doc['Quantity'],
        'Total': doc['Total'],
        'Image': doc['Image'], // Include other fields as necessary
      };
    }).toList();

    return cartItems;
  }

  Future<void> clearUserCart(String userId) async {
    // Reference to the user's cart
    CollectionReference cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart'); // Use the same casing as above

    // Get all items in the cart and delete them
    var snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await cartRef.doc(doc.id).delete();
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String itemId, int quantity) async {
    // Update the quantity of the specified cart item
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .doc(itemId)
        .update({"Quantity": quantity});
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getFoodCartSnapshot(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .get();
  }

  Future<void> removeItemFromCart(String userId, String itemId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .doc(itemId)
        .delete();
  }

//ADMIN
  Stream<QuerySnapshot> getAllUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }
}

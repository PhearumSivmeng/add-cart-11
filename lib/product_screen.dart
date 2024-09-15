import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_11/cart_screent.dart';
import 'package:flutter_11/product_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.title});

  final String title;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  CollectionReference product_datas =
      FirebaseFirestore.instance.collection('products');
  CollectionReference cart_datas =
      FirebaseFirestore.instance.collection('carts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CartScreen()));
                },
                icon: Icon(
                  Icons.shopping_cart_checkout,
                  size: 30,
                )),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                '${2}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: StreamBuilder(
            stream: product_datas.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              var list_datas = snapshot.data!.docs;
              List<Product> products = list_datas.map((each) {
                return Product.fromMap(
                    each.id, each.data() as Map<String, dynamic>);
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        childAspectRatio: 3 / 5),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            Image.network(
                              '${products[index].imageUrl}',
                              width: 125,
                              height: 125,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${products[index].name}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              '${products[index].price} \$',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.red),
                            ),
                            Text(
                              '${products[index].qty}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.red),
                            ),
                            IconButton(
                                onPressed: () async {
                                  DocumentSnapshot doc = await cart_datas
                                      .doc(products[index].id)
                                      .get();
                                  if (doc.exists) {
                                    Map<String, dynamic> map =
                                        doc.data() as Map<String, dynamic>;
                                    var newQty = ++map['qty'];
                                    // print(newQty);
                                    if (newQty > products[index].qty) {
                                      newQty = products[index].qty;
                                      //  print("Out of Stock");
                                    }
                                    // print(newQty);
                                    cart_datas
                                        .doc(products[index].id)
                                        .update({'qty': newQty});

                                    setState(() {});
                                  } else {
                                    cart_datas.doc(products[index].id).set({
                                      'name': products[index].name,
                                      'price': products[index].price,
                                      'qty': 1,
                                      'imageUrl': products[index].imageUrl,
                                      'max-qty': products[index].qty
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.add_shopping_cart,
                                  size: 30,
                                ))
                          ],
                        ),
                      );
                    }),
              );
            }));
  }
}

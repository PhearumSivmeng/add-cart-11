import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_11/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CartScreen> {
  CollectionReference cart_datas =
      FirebaseFirestore.instance.collection('carts');

  double total = 0.0;
  double discount = 0.0;
  double payment = 0.0;

  void calculate(List<Product> carts) {
    total = 0.0;
    for (int i = 0; i < carts.length; i++) {
      total += carts[i].qty * carts[i].price;
    }

    if (total > 50) {
      discount = 10;
    } else if (total > 100) {
      discount = 20;
    } else if (total > 200) {
      discount = 30;
    } else if (total > 500) {
      discount = 40;
    } else {
      discount = 0.0;
    }

    payment = total - (discount * total / 100);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Products List'),
      ),
      body: StreamBuilder(
          stream: cart_datas.snapshots(),
          builder: (context, snapshot) {
            var carts_product = snapshot.data!.docs;
            var carts = carts_product.map((each) {
              return Product.fromMap(
                  each.id, each.data() as Map<String, dynamic>);
            }).toList();

            calculate(carts);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                              leading: Image.network(carts[index].imageUrl,
                                  width: 100, height: 100, fit: BoxFit.cover),
                              title: Text('${carts[index].name}'),
                              subtitle: Text('${carts[index].price}'),
                              trailing: SizedBox(
                                width: 110,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          var newQty = --carts[index].qty;
                                          if (newQty == 0) {
                                            await cart_datas
                                                .doc(carts[index].id)
                                                .delete();
                                            setState(() {});
                                          }
                                          await cart_datas
                                              .doc(carts[index].id)
                                              .update({'qty': newQty});
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.remove,
                                          color: Colors.black,
                                        )),
                                    Text(
                                      '${carts[index].qty}',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          var newQty = ++carts[index].qty;

                                          DocumentSnapshot doc =
                                              await cart_datas
                                                  .doc(carts[index].id)
                                                  .get();
                                          if (doc.exists) {
                                            Map<String, dynamic> map = doc
                                                .data() as Map<String, dynamic>;

                                            if (newQty > map['max-qty']) {
                                              newQty = map['max-qty'];
                                              //  print("Out of Stock");
                                            }
                                          }
                                          await cart_datas
                                              .doc(carts[index].id)
                                              .update({'qty': newQty});
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                        )),
                                  ],
                                ),
                              )),
                        );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Total:'),
                          Text('\$ ${total.toStringAsFixed(2)}')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [Text('Discount:'), Text('% ${discount}')],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Payment:'),
                          Text('\$ ${payment.toStringAsFixed(2)}')
                        ],
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}

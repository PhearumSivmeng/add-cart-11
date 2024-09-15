import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Products List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: cart_datas.snapshots(),
                builder: (context, snapshot) {
                  var carts_product = snapshot.data!.docs;
                  var carts = carts_product.map((each) {
                    return Product.fromMap(
                        each.id, each.data() as Map<String, dynamic>);
                  }).toList();

                  total = 0.0;
                  for (int i = 0; i < carts.length; i++) {
                    total += carts[i].price;
                  }

                  if (total > 100) {
                    discount = 0.1;
                  } else if (total > 200) {
                    discount = 0.2;
                  } else if (total > 300) {
                    discount = 0.3;
                  } else if (total > 500) {
                    discount = 0.4;
                  } else {
                    discount = 0.0;
                  }

                  payment = total - (discount * total);
                  // setstate()

                  return ListView.builder(
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: Image.network(carts[index].imageUrl,
                                width: 100, height: 100, fit: BoxFit.cover),
                            title: Text('${carts[index].name}'),
                            subtitle: Text('${carts[index].price}'),
                            trailing: IconButton(
                                onPressed: () async {
                                  await cart_datas
                                      .doc(carts[index].id)
                                      .delete();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ),
                        );
                      });
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
      ),
    );
  }
}
